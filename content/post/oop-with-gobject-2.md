---
date: "2009-08-14T00:00:00Z"
tags:
- Agile
- Coding
- GLib
- GTK+
title: GObject 객체 지향 프로그래밍 (2)
---

첫번째 글이 당연한 내용을 너무 길게 설명했다는 의견이 있어서, 이번 글부터는 더 짧고 간결하게 정리해 보려고 노력하고 있습니다. 그리고, 이 글의 대상은 한 번이라도 GTK+ / GLib 라이브러리를 사용한 경험이 있는 개발자입니다. 그래서 정말로 기초적인 내용은 피하고 있습니다.

**접근자 (Accessors)**

소프트웨어 공학에서 모듈이나 객체 설계시 기본적으로 강조하는 정보은닉(information hiding), 캡슐화(encapsulation), 결합도(coupling) 등과 같은 개념에 의하면, C 언어처럼 구조체의 필드 변수를 외부로 직접 공개하는 건 좋지 않다고 합니다. 그리고 대부분의 경우 직접 접근 방식보다 읽고 쓰는 접근자(accessors)를 제공하는 게 여러모로 좋다고 하지요. 물론 성능 문제로 직접 접근 방식을 고려해야 하는 경우도 있지만, 지금까지 경험에 비춰보면, 병목을 일으키는 부분은 프로파일러를 돌려서 정확하게 파악한 다음에 해결하는 게 대부분 좋기 때문에 처음부터 그럴 필요는 없을 것 같습니다.

참고로 현재 개발 중인 [GTK+ 3.0](http://live.gnome.org/GTK%2B/3.0/Roadmap)에서도 기존에 공개되었던 변수들을 모조리 안으로 숨기고, GTK+ 2.x 어플리케이션의 이전(migration)을 위해 [GSEAL() 매크로](http://live.gnome.org/GnomeGoals/UseGseal)를 2.14 버전부터 제공하고 있습니다.

아무튼 그래서, 일단 지난 글에서 예제로 사용한 호스트 객체의 필드를 숨기고 접근 API를 구현해 보았습니다. (변경되거나 수정한 부분만 보여드립니다)

**edc-host.h**

    typedef struct _EdcHostClass EdcHostClass;
    typedef struct _EdcHost      EdcHost;

    struct _EdcHost
    {
      GObject parent;
    };

    struct _EdcHostClass
    {
      GObjectClass parent_class;
    };

    GType        edc_host_get_type     (void) G_GNUC_CONST;
    EdcHost     *edc_host_new          (void);
    const gchar *edc_host_get_name     (EdcHost     *host);
    void         edc_host_set_name     (EdcHost     *host,
                                        const gchar *name);
    const gchar *edc_host_get_address  (EdcHost     *host);
    void         edc_host_set_address  (EdcHost     *host,
                                        const gchar *address);
    gint         edc_host_get_port     (EdcHost     *host);
    void         edc_host_set_port     (EdcHost     *host,
                                        gint         port);
    const gchar *edc_host_get_user     (EdcHost     *host);
    void         edc_host_set_user     (EdcHost     *host,
                                        const gchar *user);
    const gchar *edc_host_get_password (EdcHost     *host);
    void         edc_host_set_password (EdcHost     *host,
                                        const gchar *password);

**edc-host.c**

    #include "edc-host.h"

    typedef struct _EdcHostPrivate EdcHostPrivate;
    struct _EdcHostPrivate
    {
      gchar *name;
      gchar *address;
      gint   port;
      gchar *user;
      gchar *password;
    };

    #define EDC_HOST_GET_PRIVATE(host) 
     G_TYPE_INSTANCE_GET_PRIVATE (host, EDC_TYPE_HOST, EdcHostPrivate)

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
      EdcHostPrivate *priv;

      priv = EDC_HOST_GET_PRIVATE (host);

      priv->name = g_strdup ("");
      priv->address = g_strdup ("");
      priv->port = 0;
      priv->user = g_strdup ("");
      priv->password = g_strdup ("");
    }

    /* object finalizer */
    static void
    edc_host_finalize (GObject *self)
    {
      EdcHost *host = EDC_HOST (self);
      EdcHostPrivate *priv;

      priv = EDC_HOST_GET_PRIVATE (host);

      g_free (priv->name);
      g_free (priv->address);
      g_free (priv->user);
      g_free (priv->password);

      /* call our parent method (always do this!) */
      G_OBJECT_CLASS (edc_host_parent_class)->finalize (self);
    }

    /* class initializer */
    static void
    edc_host_class_init (EdcHostClass *klass)
    {
      GObjectClass *gobj_class;

      gobj_class = G_OBJECT_CLASS (klass);
      gobj_class->finalize = edc_host_finalize;

      g_type_class_add_private (gobj_class, sizeof (EdcHostPrivate));
    }

    const gchar *
    edc_host_get_name (EdcHost *host)
    {
      EdcHostPrivate *priv;

      g_return_val_if_fail (EDC_IS_HOST (host), NULL);

      priv = EDC_HOST_GET_PRIVATE (host);

      return priv->name;
    }

    void
    edc_host_set_name (EdcHost     *host,
                       const gchar *name)
    {
      EdcHostPrivate *priv;

      g_return_if_fail (EDC_IS_HOST (host));
      g_return_if_fail (name != NULL);

      priv = EDC_HOST_GET_PRIVATE (host);

      g_free (priv->name);
      priv->name = g_strdup (name);
    }

먼저 헤더 파일을 보면, `EdcHost` 구조체에서 공개되었던 객체 변수가 모두 사라지고, 대신 `edc_host_{get,set}_*()` 형태의 API 선언이 추가되었습니다. 소스 파일에는 새로 `EdcHostPrivate` 구조체를 정의하고 모든 비공개 변수를 집어 넣은 뒤, 클래스 초기화 함수[`edc_host_class_init ()`] 마지막 부분에서 이 크기만큼의 공간을 확보하도록 합니다.[[`g_type_class_add_private()`](http://library.gnome.org/devel/gobject/stable/gobject-Type-Information.html#g-type-class-add-private)] 그리고 모든 함수에서 이 구조체를 쉽게 얻어오기 위해 정의한 `EDC_HOST_GET_PRIVATE()` 매크로를 사용해 필요한 작업을 수행합니다.

부가적으로 조금만 더 설명하면, 모든 문자열을 넘겨주는 API는 문자열을 복사해서 넘겨주어 원본 문자열을 보호합니다. 따라서 API 문서에 넘겨받은 문자열을 반드시 해제하라고 명시되어 있어야 하겠죠. 또한 지난 글에서 잠시 언급한 것처럼, 공개된 함수 진입 시점에서 인수 적합성 검사를 할때 `EDC_IS_HOST()` 매크로를 사용해 NULL 여부 뿐 아니라 정확하게 해당 객체인지 검사하도록 합니다.

참고로 위 예제에서 비공개(private) 객체에 접근하는 방법은 설명을 위해 오버헤드가 존재하는 단순한 방식입니다. 따라서 실제로 사용하려면 반드시 이 [포스트](/2008/12/23/reduce-accesing-overhead-for-gobject-private-data/)를 참고하시기 바랍니다.

이렇게 해서 기본적인 객체 속성에 대한 접근자를 구현했습니다. 물론 이게 다는 아니고, 다음에 설명할 GObject 속성(properties) 기능을 이용하면 사실 접근자를 구현할 필요도 없습니다. 하지만, GTK+와 같은 대부분의 GObject 기반 객체는 함수 API 기반의 접근자를 동시에 제공하고 있으므로 관례를 따르는 게 나쁘지는 않겠지요.

글머리에서 언급했듯이, 계속 적다 보면 내용도 길어지고 포스팅 주기도 길어질 것 같아 오늘은 일단 여기까지만 적습니다. 다음에는 본격적으로 GObject 속성(properties)을 추가할 예정인데, 설명할 게 많아서... ;)
