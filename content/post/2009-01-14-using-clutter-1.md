---
date: "2009-01-14T00:00:00Z"
tags:
- Clutter
- GTK+
title: 클러터(Clutter) 사용하기 (1)
---

[클러터(Clutter)](http://www.clutter-project.org/)는 C 언어로 구현한 2D 그래픽 사용자 인터페이스 라이브러리입니다. 2D임에도 불구하고 OpenGL 또는 OpenGL ES를 렌더링에 사용하며, GLib의 GObject 기반으로 API가 구성되어 있습니다. 뭐, 소개하자면 끝이 없고, 더 궁금한 분은 공식 홈페이지를 참고하기 바랍니다. 이 글은 [클러터 튜토리얼](http://www.openismus.com/documents/clutter_tutorial/0.8/docs/tutorial/html/index.html)을 중심으로 실제 사용하는 방법을 몇 차례에 나누어 정리하려 합니다. (현재 1.0 버전이 활발하게 개발 중이지만, 일단 0.8 버전을 기준으로 작성합니다)

**소개 / 설치 / 컴파일
**

제일 먼저, 클러터 세상에서 존재하는 몇가지 개념부터 설명해야겠군요. 첫번째로 설명할 녀석은 액터(actors)입니다. 말 그대로 배우 역할을 하는 다양한 객체입니다. 그 다음에는 스테이지(stage), 즉 무대입니다. 배우가 온갖 연기를 펼치는 공간(canvas)입니다. 클러터는 카이로(cairo) 라이브러리처럼 공간이 보여질때마다 매번 그려야 하는 방식이 아니라 모든 액터의 상태가 유지되는 방식으로, 프로그래머는 액터를 움직이거나 회전시키기만 하면 그려주는 건 클러터 라이브러리가 알아서 합니다. (부분적으로 Z축 이동도 가능합니다)

3D 엔진을 사용함에도 클러터 라이브러리가 2D 라이브러리라고 표방하는 이유는 사용자 인터페이스에는 아직까지 3D 효과가 가미된 2D 인터페이스가 더 실용적이기 때문입니다. 미려한 2D 인터페이스를 쉽게 구현하도록 애니메이션과 타임라인 등과 같은 기능도 제공합니다. 그리고 임베디드 시스템에서 사용 가능하도록 OpenGL ES를 사용하기 때문에 데스크탑 뿐 아니라 다양한 플랫폼에 적용할 수 있습니다. (물론 아직까지는 리눅스 기반일 뿐입니다)

클러터를 설치하는 가장 쉬운 방법은 우분투 최신 배포판을 설치하고 libclutter\* 패키지를 모두 설치하는 것입니다. 아니라면 각 배포판의 패키지를 찾아보거나 홈페이지에서 언급한 방법대로 설치하시기 바랍니다. (보통 대부분의 라이브러리 설명 문서나 책은 설치에만 몇십 페이지를 할애하지만, 지금 이 글은 목적이 다르기 때문에...)

컴파일에 필요한 옵션은 '`pkg-config clutter-0.8 --cflags`', 링크에 필요한 옵션은 '`pkg-config clutter-0.8 --libs`' 명령으로 얻을 수 있습니다. 따라서 이 내용을 적당히 Makefile이나 관련 빌드 스크립트에 추가하면 됩니다.

**스테이지 (Stage) - 무대**

클러터 어플리케이션은 최소한 하나의 ClutterStage 객체가 있어야 합니다. 이 스테이지는 사각형, 이미지, 텍스트와 같은 액터(actors)를 가집니다. 아이러니하게도(?) ClutterStage 객체는 ClutterActor 객체에서 파생되었습니다. 따라서 모든 GTK+ 위젯이 GtkWidget 객체를 상속받기 때문에 `gtk_widget_*()` API를 사용할 수 있듯이, ClutterStage 객체에도 모든 `clutter_actor_*()` API를 사용할 수 있습니다.

클러터를 초기화하기 위해서 항상 제일 먼저 [`clutter_init()`](http://clutter-project.org/docs/clutter/stable/clutter-General.html#clutter-init)을 호출합니다. 그러면 [`clutter_stage_get_default()`](http://clutter-project.org/docs/clutter/stable/ClutterStage.html#clutter-stage-get-default)를 이용하여 기본 스테이지를 얻을 수 있으며, 하나의 윈도우와 연결되어 있습니다. 물론 GtkClutterEmbed 위젯을 이용하면 GTK+ 어플리케이션에서 하나의 위젯처럼 마음껏 스테이지를 사용할 수 있습니다. (하지만 실제로 마음껏은 아니고, 백엔드 엔진이 다중 스테이지를 지원하지는 여부를 `clutter_feature_available()`를 이용해 확인해야 합니다)

너무 설명이 길었군요. 마우스 버튼에 반응하는 클러터 스테이지를 한번 만들어 봅시다. (여담이지만, 튜토리얼 코드는 무조건 직접 입력해보시기 바랍니다. 가장 빨리 익숙해지는 방법입니다)

    #include <clutter/clutter.h>
    #include <stdlib.h>

    static gboolean
    on_stage_button_press (ClutterStage *stage, ClutterEvent *event, gpointer data)
    {
      gint x = 0;
      gint y = 0;

      clutter_event_get_coords (event, &x, &y);

      g_print ("Stage clicked at (%d, %d)n", x, y);

      return TRUE; /* 다른 핸들러가 이 이벤트를 처리하지 않게 합니다. */
    }

    int main(int argc, char *argv[])
    {
      ClutterColor stage_color = { 0x00, 0x00, 0x00, 0xff }; /* 검정색 */

      clutter_init (&argc, &argv);

      /* 스테이지를 얻어 크기와 색상을 정합니다. */
      ClutterActor *stage = clutter_stage_get_default ();
      clutter_actor_set_size (stage, 200, 200);
      clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);

      /* 스테이지를 보이게 합니다. */
      clutter_actor_show (stage);

      /* 스테이지를 마우스 버튼으로 클릭하면 처리할 시그널 핸들러를 연결합니다. */
      g_signal_connect (stage, "button-press-event",
                        G_CALLBACK (on_stage_button_press), NULL);

      /* 메인 이벤트 루프를 시작합니다. */
      clutter_main ();

      return EXIT_SUCCESS;
    }

컴파일하는 방법은 다음과 같습니다. (파일 이름이 `stage.c`일 경우)

    gcc -Wall -g stage.c -o stage `pkg-config clutter-0.8 --cflags --libs`

뭐 싱겁지만, 이렇게 클러터 프로그래밍이 시작되었습니다.

**(참고)** 몇몇 그래픽 카드에서 Compiz 환경에서 실행시 오동작한다면 Compiz를 사용하지 않도록 설정을 변경해야 합니다. 왜냐하면 클러터도 3D 하드웨어 가속을 사용하고 Compiz도 사용하기 때문에 충돌이 발생할 수 있기 때문입니다.

**스테이지 위젯 (Stage Widget) - GTK+ 어플리케이션 속으로**

앞에서 잠깐 언급한 것처럼, GtkClutterEmbed 위젯은 ClutterStage 객체를 GTK+ 윈도우 안에 하나의 위젯처럼 넣을 수 있게 합니다. [`gtk_clutter_embed_new()`](http://www.clutter-project.org/docs/clutter-gtk/stable/GtkClutterEmbed.html#gtk-clutter-embed-new)로 위젯을 만들어 다른 위젯처럼 컨테이너 안에 넣은 뒤, [`gtk_clutter_embed_get_stage()`](http://www.clutter-project.org/docs/clutter-gtk/stable/GtkClutterEmbed.html#gtk-clutter-embed-get-stage)로 ClutterStage 객체를 얻을 수 있습니다. 다만 GtkClutterEmbed 위젯을 사용할때는 `clutter_init()` 대신 [`gtk_clutter_init()`](http://www.clutter-project.org/docs/clutter-gtk/stable/clutter-gtk-Utility-Functions.html#gtk-clutter-init)를 호출해서 초기화해야 하고, `clutter_main()` 대신 `gtk_main()` 함수로 메인 루프를 실행합니다.

다음 예제는 앞의 예제를 조금 확장해서 GtkClutterEmbed 위젯을 사용하고 버튼을 클릭할때마다 배경 색상을 바꿉니다.

    #include <gtk/gtk.h>
    #include <clutter/clutter.h>
    #include <clutter-gtk/gtk-clutter-embed.h>
    #include <stdlib.h>

    ClutterActor *stage = NULL;

    static gboolean
    on_button_clicked (GtkButton *button, gpointer user_data)
    {
      static gboolean already_changed = FALSE;

      if(already_changed)
        {
          ClutterColor stage_color = { 0x00, 0x00, 0x00, 0xff }; /* 검정 */
          clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);
        }
      else
        {
          ClutterColor stage_color = { 0x20, 0x20, 0xA0, 0xff }; /* 파랑? */
          clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);
        }

      already_changed = !already_changed;

      return TRUE; /* 다른 핸들러가 이 이벤트를 처리하지 않게 합니다. */
    }

    static gboolean
    on_stage_button_press (ClutterStage *stage, ClutterEvent *event, gpointer user_data)
    {
      gint x = 0;
      gint y = 0;

      clutter_event_get_coords (event, &x, &y);

      g_print ("Stage clicked at (%d, %d)n", x, y);

      return TRUE; /* 다른 핸들러가 이 이벤트를 처리하지 않게 합니다. */
    }

    int main(int argc, char *argv[])
    {
      ClutterColor stage_color = { 0x00, 0x00, 0x00, 0xff }; /* 검정색 */

      gtk_clutter_init (&argc, &argv);

      /* 윈도우와 자식 위젯을 만듭니다. */
      GtkWidget *window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

      GtkWidget *vbox = gtk_vbox_new (FALSE, 6);
      gtk_container_add (GTK_CONTAINER (window), vbox);
      gtk_widget_show (vbox);

      GtkWidget *button = gtk_button_new_with_label ("Change Color");
      gtk_box_pack_end (GTK_BOX (vbox), button, FALSE, FALSE, 0);
      gtk_widget_show (button);

      g_signal_connect (button, "clicked",
                        G_CALLBACK (on_button_clicked), NULL);

      /* 윈도우가 닫히면 어플리케이션을 종료합니다. */
      g_signal_connect (window, "hide",
                        G_CALLBACK (gtk_main_quit), NULL);

      /* 클러터 위젯을 만들어 넣습니다. */
      GtkWidget *clutter_widget = gtk_clutter_embed_new ();
      gtk_box_pack_start (GTK_BOX (vbox), clutter_widget, TRUE, TRUE, 0);
      gtk_widget_show (clutter_widget);

      /* 클러터 위젯 크기를 변경합니다.
       * 왜냐하면 GtkClutterEmbed 위젯을 사용할때는 직접 변경할 수 없기 때문입니다.
       */
      gtk_widget_set_size_request (clutter_widget, 200, 200);

      /* 스테이지를 얻어 크기와 색상을 정합니다. */
      stage = gtk_clutter_embed_get_stage (GTK_CLUTTER_EMBED (clutter_widget));
      clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);

      /* 스테이지를 보이게 합니다. */
      clutter_actor_show (stage);

      /* 스테이지를 마우스 버튼으로 클릭하면 처리할 시그널 핸들러를 연결합니다. */
      g_signal_connect (stage, "button-press-event",
                        G_CALLBACK (on_stage_button_press), NULL);

      /* GTK+ 윈도우를 보이게 합니다. */
      gtk_widget_show (GTK_WIDGET (window));

      /* 메인 이벤트 루프를 시작합니다. */
      gtk_main ();

      return EXIT_SUCCESS;
    }

컴파일하는 방법은 다음과 같습니다. (파일 이름이 `stage-embed.c`일 경우)

    gcc -Wall -g stage-embed.c -o stage-embed 
        `pkg-config clutter-0.8 clutter-gtk-0.8--cflags --libs`

뭐 싱겁지만, 이렇게 클러터 프로그래밍이 시작되었습니다.
