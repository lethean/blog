---
date: "2009-08-10T00:00:00Z"
tags:
- Agile
- Coding
- GLib
- GTK+
title: GObject 객체 지향 프로그래밍 (1)
---

GTK+, Clutter 등과 같은 라이브러리는 C 언어로 구현되었지만 객체 지향 개념을 충실히 따르고 있는데, 그 중심에는 GLib 라이브러리의 GObject가 있습니다. 따라서 이러한 라이브러리를 제대로 이해하고 사용하려면 필수적으로 GObject 개념을 잘 이해하고 있어야 합니다. 그런데, 생각보다 GObject 개념은 이해하기 어렵습니다. 이해하더라도 이를 응용하려면 그만큼 시간이 또 필요합니다.

그래서 이번 글을 시작으로 GObject 라이브러리를 이용한 C 언어에서 객체 지향 프로그래밍이라는 거창한 주제를 예제 형식을 이용해 다루어 보려고 합니다. 바로 새 GTK+ 위젯을 구현하거나 클러터 객체를 분석하는 방식이 아니라 왜 GObject가 이런 방식으로 설계되었는지 그 철학을 따라가 보려고 합니다. 그리고, 가능한 기존 GObject 튜토리얼의 어려운 설명이 아니라 실제 사용하는 코드를 중심으로 설명할 예정이니, 그래도 무슨 말인지 모르겠거나 더 풀어서 설명을 하는 게 좋을 것 같을 경우 의견 주시기 바랍니다.

여기서 예제로 사용할 개념은 네트워크 카메라 호스트와 호스트 목록입니다. (하는 일이 이쪽 분야라서... :)

네트워크 카메라 호스트는 이름(name), 주소(address), 포트번호(port), 사용자(user), 비밀번호(password) 등과 같은 항목을 포함합니다. 필요한 함수로는 새 객체를 만들거나 해제, 그리고 각 필드값을 얻어오거나 변경하는 정도입니다. (아마도 나중에는 값이 변경되면 자동으로 호출되는 콜백 함수도 추가할 겁니다)

모든 코드는 GLib API를 이용하여 작성합니다.

**객체 (Objects) + 참조 카운터 (Reference Counter)
**

소프트웨어 공학자들이 객체라고 부르기 전부터 C 언어에는 구조체(struct)가 있었습니다. GObject 시스템 역시 기본 바탕은 구조체입니다. 그러면 GObject 프로그래밍을 하기 전에, 일반 C 언어 구조체를 이용해 네트워크 카메라 호스트를 정의하면, 다음과 같은 코드가 나오지 않을까요?

    typedef struct _EdcHost EdcHost;
    struct _EdcHost
    {
      gchar *name;
      gchar *address;
      gint   port;
      gchar *user;
      gchar *password;
    };

만일 상속이나 함수 오버로딩(overloading)을 전혀 사용하지 않는다면, 굳이 새로운 함수를 추가할 필요를 못 느끼는 분들이 많을 겁니다. 왜냐하면, 직접 구조체 크기만큼 메모리를 할당한 뒤 해제하고, 직접 모든 필드를 접근하면 되니까요. 하지만, 할당하고 해제하는 코드가 여러 곳에 분산되어 있다면 디버깅도 힘들고 유지 보수도 힘드니까 최소한 객체를 생성하고 해제하는 함수만이라도 만들어 봅시다.

    EdcHost *
    edc_host_new (void)
    {
      EdcHost *host;

      host = g_new0 (EdcHost, 1);

      return host;
    }

    void
    edc_host_destroy (EdcHost *host)
    {
      g_return_if_fail (host != NULL);

      g_free (host->name);
      g_free (host->address);
      g_free (host->user);
      g_free (host->password);
      g_free (host);
    }

간단한 코드라서 설명할 필요는 없을 것 같습니다. 참고로 [`g_free()`](http://library.gnome.org/devel/glib/stable/glib-Memory-Allocation.html#g-free) 함수는 인수가 NULL일 경우 무시하므로 NULL 검사 코드는 필요없습니다.

그런데, 이 객체는 단순히 목록 관리 뿐 아니라 여러 다른 모듈에서도 사용할 예정입니다. 여기서 갑자기, 모든 모듈이 하나의 객체를 공유하고 싶은 욕망이 꿈틀대기 시작합니다. 모듈 간에 객체를 전달할때 복사할 필요도 없고, 모듈 별로 객체를 따로 만들어 정보를 보관하는 것보다 메모리를 절약할 수 있으며, 필드 하나가 변경되었을 경우 그 정보를 모든 관련 객체에 반영할 수고도 덜 수 있기 때문입니다. 그렇다고 무턱대고 모든 모듈에서 객체 주소(pointer)만 참조하게 하면 객체를 어느 시점에 할당하고 해제해야 하는지 매우 까다로워집니다. 특히 동적으로 임시 객체를 생성해 다른 모듈에게 넘겨주는 경우라면, 객체를 어느 시점에서 해제해야 하는지도 실수하기 딱 좋습니다. 더 나아가 멀티 쓰레드 환경까지 고려한다면, 단순히 포인터만 가리키는 방식은, 아마추어나 사용하는 옛날 UML 클래스 빌더가 자동으로 생성해주는 코드만으로는, 힘들 수 밖에 없습니다.

이런 경우 자주 사용하는 방식이 참조 카운터(reference counter) 기법입니다. 짧게 설명하자면, 모든 모듈에서 몇 가지 원칙만 지키면 됩니다. 첫번째 원칙은, 객체(메모리)를 할당한 모듈에서 반드시 해제하기입니다. 두번째는, 모듈 관점에서 내가 필요한 시점부터 객체의 참조 카운터를 증가하고, 더이상 사용하지 않으면 객체의 참조 카운터를 감소합니다. 새로 생성된 객체는 참조 카운터 값이 1이고, 참조 카운터가 감소되어 0이 되면 객체는 자동으로 해제됩니다. 참고로, 참조 카운터 기법은 멀티미디어 프레임 버퍼, 네트워크 패킷 등과 같은 버퍼 관리에도 널리 사용하는 것은 물론, 오브젝티브-C 언어(Objective-C)의 NSObject 객체가 기본적으로 제공하는 기능이기도 합니다.

자 이제, 호스트 객체를 참조 카운터 기법을 적용해 수정해 보면 다음과 같습니다.

**edc-host.h**

    #ifndef __EDC_HOST_H__
    #define __EDC_HOST_H__

    #include <glib.h>

    #ifdef __cplusplus
    extern "C" {
    #endif

    typedef struct _EdcHost EdcHost;
    struct _EdcHost
    {
      gchar *name;
      gchar *address;
      gint   port;
      gchar *user;
      gchar *password;

      gint   ref_count;
    };

    EdcHost *edc_host_new   (void);
    EdcHost *edc_host_ref   (EdcHost *host);
    void     edc_host_unref (EdcHost *host);

    #ifdef __cplusplus
    }
    #endif

    #endif /* __EDC_HOST_H__ */

**edc-host.c**

    #include "edc-host.h"

    EdcHost *
    edc_host_new (void)
    {
      EdcHost *host;

      host = g_new0 (EdcHost, 1);
      if (!host)
        return NULL;

      host->ref_count = 1;

      return host;
    }

    static void
    edc_host_destroy (EdcHost *host)
    {
      g_return_if_fail (host != NULL);

      g_free (host->name);
      g_free (host->address);
      g_free (host->user);
      g_free (host->password);
      g_free (host);
    }

    EdcHost *
    edc_host_ref (EdcHost *host)
    {
      g_return_val_if_fail (host != NULL, NULL);

      g_atomic_int_inc (&host->ref_count);

      return host;
    }

    void
    edc_host_unref (EdcHost *host)
    {
      g_return_if_fail (host != NULL);

      if (g_atomic_int_dec_and_test (&host->ref_count))
        edc_host_destroy (host);
    }

제일 먼저 설명할 부분은 역시 [`g_atomic_int_inc()`](http://library.gnome.org/devel/glib/stable/glib-Atomic-Operations.html#g-atomic-int-inc) / [`g_atomic_int_dec_and_test()`](http://library.gnome.org/devel/glib/stable/glib-Atomic-Operations.html#g-atomic-int-dec-and-test) 함수입니다. 멀티 쓰레드에서 안전하게 카운터 변수를 증가하고 감소할 수 있게 도와주는 GLib API입니다. 이를 이용해 위에서 설명한 참조 카운터 개념을 구현하고 있습니다. 공개했던 `edc_host_destroy()` 함수는 모듈 내부에서만 접근할 수 있도록 `static` 키워드를 붙였습니다. 또한 C++ 소스에서 포함(include)할때 문제를 일으키지 않도록 헤더파일에 '`extern "c" {}`' 키워드도 추가했습니다.

그런데 참조 카운터가 필요한 객체마다 이렇게 구현하면 비슷한 작업을 하는 코드가 중복될 수 밖에 없습니다. 이를 일반적인 API로 분리해 다시 구현하면 재활용이 가능할테니, 다음과 같이 수정해 보겠습니다.

**edc-object.h**

    #ifndef __EDC_OBJECT_H__
    #define __EDC_OBJECT_H__

    #include <glib.h>

    #ifdef __cplusplus
    extern "C" {
    #endif

    typedef struct _EdcObject EdcObject;
    struct _EdcObject
    {
      gint           ref_count;
      GDestroyNotify finalize;
    };

    static inline gpointer
    edc_object_alloc (GDestroyNotify finalize,
                      gint           obj_size)
    {
      EdcObject *obj;

      obj = g_malloc (obj_size);
      if (!obj)
        return NULL;

      obj->ref_count = 1;
      obj->finalize = finalize;

      return obj;
    }

    static inline gpointer
    edc_object_ref (gpointer obj)
    {
      EdcObject *object = obj;

      if (object)
        g_atomic_int_inc (&object->ref_count);

      return object;
    }

    static inline void
    edc_object_unref (gpointer obj)
    {
      EdcObject *object = obj;

      if (!obj)
        return;

      if (g_atomic_int_dec_and_test (&object->ref_count))
        {
          if (object->finalize)
            object->finalize (object);
          g_free (object);
        }
    }

    #ifdef __cplusplus
    }
    #endif

    #endif /* __EDC_OBJECT_H__ */

**edc-host.h**

    #ifndef __EDC_HOST_H__
    #define __EDC_HOST_H__

    #include "edc-object.h"

    #ifdef __cplusplus
    extern "C" {
    #endif

    typedef struct _EdcHost EdcHost;
    struct _EdcHost
    {
      EdcObject parent;

      gchar *name;
      gchar *address;
      gint   port;
      gchar *user;
      gchar *password;
    };

    EdcHost *edc_host_new (void);

    #ifdef __cplusplus
    }
    #endif

    #endif /* __EDC_HOST_H__ */

**edc-host.c**

    #include "edc-host.h"

    static void
    edc_host_finalize (gpointer obj)
    {
      EdcHost *host = obj;

      g_free (host->name);
      g_free (host->address);
      g_free (host->user);
      g_free (host->password);
    }

    EdcHost *
    edc_host_new (void)
    {
      EdcHost *host;

      host = edc_object_alloc (edc_host_finalize,
                               sizeof (EdcHost));
      if (!host)
        return NULL;

      host->name = NULL;
      host->address = NULL;
      host->user = NULL;
      host->password = NULL;

      return host;
    }

객체 지향 상속(또는 파생 객체)을 C 언어로 구현하는 가장 쉬운 방법은 위 코드에서 보는 것처럼 부모(또는 원본 객체)를 구조체 맨 앞에 두는 겁니다. 그러면 부모와 자식 API 모두 사용할 수 있게 되죠. 위 코드의 경우 개념상으로 보면 EdcObject 객체를 상속 받아 EdcHost 객체를 구현한 셈이 되죠. 따라서 다음과 같이 사용할 수 있습니다.

    void
    func_a (EdcHost *host)
    {
      edc_object_ref (host);
      // do some stuff for long time...
      edc_object_unref (host);
    }

    {
      EdcHost *host;

      host = edc_host_new ();
      ...
      func_a (host);
      ...
      edc_object_unref (host); /* destroy */
    }

참고로 C 언어에서 \``void *`' 형은 어떤 포인터와도 양방향 대입(assignment)을 할 수 있으므로 컴파일 경고를 피하기 위해 불필요한 형변환을 할 필요가 없습니다. ([`gpointer`](http://library.gnome.org/devel/glib/stable/glib-Basic-Types.html#gpointer) / [`GDestroyNotify`](http://library.gnome.org/devel/glib/stable/glib-Datasets.html#GDestroyNotify) API도 설명도 확인해 보시기 바랍니다)

이제 지금까지 구현한 부분을 GObject 객체 기반으로 옮겨 봅니다. 자세히 보시면, 지금까지 프로그래밍한 내용과 거의 비슷한 점을 알아챌 수 있을 겁니다.

**edc-host.h**

    #ifndef __EDC_HOST_H__
    #define __EDC_HOST_H__

    #include <glib-object.h>

    G_BEGIN_DECLS

    #define EDC_TYPE_HOST 
     (edc_host_get_type ())
    #define EDC_HOST(obj) 
     (G_TYPE_CHECK_INSTANCE_CAST ((obj), EDC_TYPE_HOST, EdcHost))
    #define EDC_HOST_CLASS(obj) 
     (G_TYPE_CHECK_CLASS_CAST ((obj), EDC_TYPE_HOST, EdcHostClass))
    #define EDC_IS_HOST(obj) 
     (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EDC_TYPE_HOST))
    #define EDC_IS_HOST_CLASS(obj) 
     (G_TYPE_CHECK_CLASS_TYPE ((obj), EDC_TYPE_HOST))
    #define EDC_GET_HOST_CLASS(obj) 
     (G_TYPE_INSTANCE_GET_CLASS ((obj), EDC_TYPE_HOST, EdcHostClass))

    typedef struct _EdcHostClass EdcHostClass;
    typedef struct _EdcHost      EdcHost;

    struct _EdcHost
    {
     GObject parent;

     gchar  *name;
     gchar  *address;
     gint    port;
     gchar  *user;
     gchar  *password;
    };

    struct _EdcHostClass
    {
     GObjectClass parent_class;
    };

    GType    edc_host_get_type (void) G_GNUC_CONST;
    EdcHost *edc_host_new      (void);

    G_END_DECLS

    #endif /* __EDC_HOST_H__ */

**edc-host.c**

    #include "edc-host.h"

    G_DEFINE_TYPE (EdcHost, edc_host, G_TYPE_OBJECT);

    EdcHost *
    edc_host_new (void)
    {
     return EDC_HOST (g_object_new (EDC_TYPE_HOST, NULL));
    }

    /* object initializer */
    static void
    edc_host_init (EdcHost *host)
    {
     host->name = NULL;
     host->address = NULL;
     host->port = 0;
     host->user = NULL;
     host->password = NULL;
    }

    /* object finalizer */
    static void
    edc_host_finalize (GObject *self)
    {
     EdcHost *host = EDC_HOST (self);

     g_free (host->name);
     g_free (host->address);
     g_free (host->user);
     g_free (host->password);

     /* call our parent method (always do this!) */
     G_OBJECT_CLASS (edc_host_parent_class)->finalize (self);
    }

    /* class initializer */
    static void
    edc_host_class_init (EdcHostClass *klass)
    {
     GObjectClass *gobject_class;

     gobject_class = G_OBJECT_CLASS (klass);
     gobject_class->finalize = edc_host_finalize;
    }

갑자기 코드량이 증가했다고 놀랄 필요는 없습니다. 뭐든지 다 그렇지만, 알고 보면 별 거 아닙니다.

먼저 헤더 파일을 설명하면,  GObject 객체를 사용하기 위해 glib-object.h 파일을 포함했습니다. 이는 EdcHost 객체가 GObject 객체만 사용하기 때문에, 더 정확히는 GObject의 파생 객체(derived objects), 다른 말로는 GObject 객체만 상속(inheritance)하기 때문에 그렇습니다. 만일 다른 객체에서 파생한다면 그 객체를 정의하는 헤더 파일을 포함해야 합니다. '`extern "c" {}`' 키워드는 GLib의 [`G_BEGIN_DECLS`](http://library.gnome.org/devel/glib/stable/glib-Miscellaneous-Macros.html#G-BEGIN-DECLS--CAPS) / [`G_END_DECLS`](http://library.gnome.org/devel/glib/stable/glib-Miscellaneous-Macros.html#G-END-DECLS--CAPS) API로 대체했습니다.

EdcHost 인스턴스와 EdcHostClass 클래스를 정의하고 있는 부분을 설명하면, 클래스 객체는 전역으로 하나만 존재하고 그냥 객체는 인스턴스(instance) 역할을 합니다. 또한 여기서는 인스턴스 객체의 모든 필드가 공개되어 있지만, 물론 외부에 공개하지 않는(private) 필드를 정의할 수도 있습니다. (이는 다른 글에서 따로 설명하겠습니다)

복잡해 보이는 몇몇 매크로는 자주 사용하는 긴 API를 간편화한 것입니다. 런타임 중에 인스턴스가 유효하고 EdcHost 객체로 형변환까지 해주거나[`EDC_HOST(obj)`], 인스턴스가 EdcHost 객체인지 확인하거나[`EDC_IS_HOST(obj)`], 인스턴스의 클래스 객체를 얻어오거나[`EDC_GET_HOST_CLASS(obj)`] 하는 등 일종의 [RTTI](http://en.wikipedia.org/wiki/Run-time_type_information) 관련 매크로입니다. 아마 제일 많이 사용하는 매크로는 \``EDC_HOST(obj)`'일 겁니다.

소스를 살펴 보면, 제일 먼저 나오는게 \`[`G_DEFINE_TYPE(TN, t_n, T_P)`](http://library.gnome.org/devel/gobject/stable/gobject-Type-Information.html#G-DEFINE-TYPE--CAPS)' 입니다. 여담이지만, 이 매크로가 추가되기 전에 작성한 GObject 기반 코드는 귀찮은 작업을 많이 해야 했는데, 이 매크로가 자동으로 해주는 기능이 많아서 불필요하게 중복되는 코드가 많이 줄어들었습니다. 그래서 GTK+ 소스 코드 중에도 가끔 그렇게 작성한 코드도 있고, GObject 관련 초기 문서를 보면 이 매크로를 사용하지 않고 구현되어 있는 경우도 있습니다.

이 매크로가 하는 일은 다음과 같습니다. 지정한 \``t_n`\` 이름으로 시작하는 클래스 초기화 함수[`*_class_init()`] / 인스턴스 초기화 함수[`*_init()`] 모두 구현되어 있다고 가정하고 \``*_get_type()`' 함수를 자동으로 삽입해 줍니다. 더불어 부모 클래스 객체를 가리키는 \``*_parent_class`' 전역 변수도 만들어 줍니다. 따라서 프로그래머는 최소한 함수 두 개만 구현해 주면 되는 셈입니다. [`edc_host_init()` / `edc_host_class_init()`]

하지만 위 예제에서는 클래스 초기화 함수에서 인스턴스 객체가 해제될때 호출되는 finalize 함수를 교체하고 있습니다. 이를 통해 객체가 해제될때 사용하던 리소스를 해제해 줍니다. 그리고, 반드시 상위 클래스의 finalize 함수를 호출해 주어야 정상적으로 부모 객체의 해제 함수가 차례대로 호출될 수 있습니다.

자 이제 GObject의 핵심 기능 중 하나인 객체 참조 카운터(object reference counter) 기능을 쉽게 이용할 수 있습니다. 이렇게 작성한 객체는 [`g_object_ref()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-ref) / [`g_object_unref()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-unref) 함수 등을 이용해 참조 카운터를 제어할 수 있습니다. GObject 소스 코드를 확인해 보시면 알겠지만, 실제 객체 참조 카운터 기능은 거의 비슷하게 구현되어 있습니다. 더 많은 경우의 수를 고려하고 더 많은 기능을 제공하다보니 코드가 더 복잡한 것 뿐입니다.

더 중요한 점은 모든 GObject 기반 객체, 예를 들어 GTK+ 위젯이나 클러터 객체 모두 GObject 기반이기 때문에 객체간 연결(부모-자식, 컨테이너-아이템 등)시 객체에 대한 포인터를 유지하면서 동시에 참조 카운터를 유지하여 메모리를 관리한다는 점입니다. 이 부분에 대한 더 자세한 설명은 [GTK+ 메모리 관리](/2008/12/28/gtk-memory-management/) 글에서 확인하시기 바랍니다.

오늘은 일단 여기까지만... ;)
