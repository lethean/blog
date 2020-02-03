---
date: "2009-09-21T00:00:00Z"
tags:
- Coding
- GLib
- GTK+
title: GLib 메인루프 이용하기
---

GLib API를 이용한 멀티쓰레드 프로그래밍에서 비동기 메시지 큐를 이용하는 방법은 지난 [포스트](/2008/08/06/glib-thread-programming/)에서 설명한 적이 있는데, 이번에는 [애플 GCD의 libdispatch와 비교되는 GLib의 메인루프](/2009/09/17/glib-mainloop-vs-libdispatch-of-apple-gcd/)를 이용하는 방법을 정리해 보았습니다. 이 방법은 어떤 관점에서 보면 더 쉽고, 이미 많은 기능이 기본적으로 지원되기 때문에 몇몇 경우를 제외하면 더 좋은 방법입니다. 다만 API 사용법을 이해하기가 처음에 조금 까다롭다는 점이 걸림돌입니다.

일반적으로 GLib / GTK 어플리케이션은 메인 쓰레드에서 실행되는 메인 이벤트 루프 기반에서 동작합니다. 키보드 / 마우스 이벤트 처리, 화면 표시, 사용자가 등록한 Idle / Timeout 함수 처리 등이 모두 이 메인 이벤트 루프에서 처리됩니다. 그런데 이 메인 이벤트 루프라는 건 마냥 개념적인게 아니라, 실제로 [GMainLoop](http://library.gnome.org/devel/glib/stable/glib-The-Main-Event-Loop.html#GMainLoop) 객체를 기반으로 동작합니다. 그런데 `g_main_loop_*()` 계열 함수를 살펴보면 몇 개 안됩니다. 루프 객체를 생성하고, 참조하고, 해제하고, 돌리고[`g_main_loop_run()]`, 종료하고[`g_main_loop_quit()]`, 돌아가는 중인지 확인하기 등의 함수만 있습니다. 아, 하나 더 있군요. 객체를 생성할때 전달하는 [GMainContext](http://library.gnome.org/devel/glib/stable/glib-The-Main-Event-Loop.html#GMainContext) 객체를 얻어오는 함수[`g_main_loop_get_context()]`가 있군요.

모든 GMainLoop는 하나의 GMainContext와 함께 사용됩니다. GMainContext 객체는 실행할 소스[[GSource](http://library.gnome.org/devel/glib/stable/glib-The-Main-Event-Loop.html#GSource)] 목록을 관리합니다. 소스는 파일, 파이프, 소켓 등의 디스크립터를 기반으로 한 이벤트 소스일 수도 있고, Idle / Timeout 등과 같은 시간 소스일 수도 있습니다. 컨텍스트는 실행 소스 각각을 검사해서 원하는 이벤트가 발생했는지, 아니면 실행할 시간이 되었는지를 판단해 등록한 콜백함수를 호출합니다. 참고로, 메인 쓰레드에서 동작하기 위한 컨텍스트[`g_main_context_default()`]는 기본적으로 제공합니다. 이 기본 컨텍스트는 `gtk_main()` 함수가 사용하는 것은 물론, `g_idle_add()`, `g_timeout_add()` 등과 같은 함수도 이 기본 컨텍스트를 사용합니다.

아무튼 조금 더 구체적이고 자세한 내용은 [공식 문서](http://library.gnome.org/devel/glib/stable/glib-The-Main-Event-Loop.html)를 참고하시고, 이제 이를 이용한 멀티쓰레드 프로그래밍을 해보겠습니다. 말이 길었으니 코드를 먼저 보여드리겠습니다.

    #include <glib.h>

    static GThread *my_thread;
    static GMainLoop *my_loop;

    static void
    add_idle_to_my_thread (GSourceFunc    func,
                           gpointer       data)
    {
      GSource *src;

      src = g_idle_source_new ();
      g_source_set_callback (src, func, data, NULL);
      g_source_attach (src,
                       g_main_loop_get_context (my_loop));
      g_source_unref (src);
    }

    static void
    add_timeout_to_my_thread (guint          interval,
                              GSourceFunc    func,
                              gpointer       data)
    {
      GSource *src;

      src = g_timeout_source_new (interval);
      g_source_set_callback (src, func, data, NULL);
      g_source_attach (src,
                       g_main_loop_get_context (my_loop));
      g_source_unref (src);
    }

    static gpointer
    loop_func (gpointer data)
    {
      GMainLoop *loop = data;

      g_main_loop_run (loop);

      return NULL;
    }

    static void
    start_my_thread (void)
    {
      GMainContext *context;

      context = g_main_context_new ();
      my_loop = g_main_loop_new (context, FALSE);
      g_main_context_unref (context);

      my_thread = g_thread_create (loop_func, my_loop, TRUE, NULL);
    }

    static void
    stop_my_thread (void)
    {
      g_main_loop_quit (my_loop);
      g_thread_join (my_thread);
      g_main_loop_unref (my_loop);
    }

함수 먼저 설명하면, `start_my_thread()` 함수는 쓰레드를 시작하고, `stop_my_thread()` 함수는 쓰레드를 중지합니다. `add_idle_to_my_thread()` 함수는 바로 실행되는 Idle 콜백 함수를 추가하고, `add_timeout_to_my_thread()` 함수는 주기적으로 실행되는 Timeout 콜백 함수를 추가합니다. 마지막 두 함수의 인수는 `g_idle_add()`, `g_timeout_add()` 함수와 각각 동일합니다. 따라서, 콜백 함수가 `TRUE`를 리턴하면 자동으로 반복해서 계속 실행되고, `FALSE`를 리턴하면 한번만 실행되고 종료합니다.

위 코드의 핵심은 GMainContext 객체를 만들고 이를 기반으로 GMainLoop 객체를 만든 뒤 별도 쓰레드에서 실행하도록 하는 부분입니다. 그리고, 필요한 모든 작업은 Idle / Timeout 소스 객체를 만들어 컨텍스트에 추가(attach)해서 동작하도록 하는 겁니다. 참고로, 관련 API는 모두 쓰레드에 안전합니다.

물론 위 함수를 조금 더 확장하면 콜백함수가 종료될때 자동으로 호출되는 notify 함수도 등록할 수 있고, 우선순위도 조절할 수 있습니다. 또한 여러 쓰레드를 종류별로 만들어 필요한 쓰레드에게 해당 작업만 전달해도 됩니다. 하지만 그 정도는 응용하는데 별로 어려움이 없을 거라 생각하고 한가지만 더 설명하겠습니다.

예를 들어 네트워크 소켓(socket)을 하나 만들고 이 소켓에 읽을 데이터가 도착했을 경우에만 호출되는 함수를 등록하고 싶은 경우, 다음과 같은 코드를 사용하면 됩니다.

    static gboolean
    socket_read (GIOChannel  *source,
                 GIOCondition condition,
                 gpointer data)
    {
      /* Use g_io_channel_read_chars() to read data... */

      return TRUE;
    }

    static void
    add_socket_to_my_thread (gint sock_fd)
    {
      GIOChannel *channel;
      GSource *src;

      channel = g_io_channel_unix_new (sock_fd);
      src = g_io_create_watch (channel, G_IO_IN);
      g_source_set_callback (src,
                             (GSourceFunc) read_socket,
                             NULL,
                             NULL);
      g_source_attach (src,
                       g_main_loop_get_context (my_loop));
      g_source_unref (src);
    }

자세한 내용은 위 코드와 비슷하지만 기본 메인 이벤트 루프에서 동작하도록 하는 `g_io_add_watch()` API 설명 부분을 참고하시기 바랍니다. 어쨌든, 기본적으로 GMainContext 객체는 유닉스 시스템의 폴링(polling) 메카니즘을 사용하기 때문에 이론적으로는 거의 모든 파일 디스크립터를 사용할 수 있습니다. 물론 비슷한 방식으로 윈도우 운영체제에서 이벤트 핸들이나 소켓 핸들도 사용할 수도 있습니다.

글머리에서 적은 것처럼 비동기 메시지 큐를 이용하는 방식보다 아주 약간의 오버헤드는 있겠지만, 훨씬 더 많은 기능을 제공하는 것 같지 않나요?
