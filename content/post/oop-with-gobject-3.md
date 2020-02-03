---
date: "2009-08-18T00:00:00Z"
tags:
- Agile
- Coding
- GLib
- GTK+
title: GObject 객체 지향 프로그래밍 (3)
---

이 글은 회사 개발팀 내부 세미나를 위해 작성중인 글입니다. 하지만, 블로그란 매체의 특성상 외부에도 공개되고 있는데, 댓글은 달지 않아도 접속하는 사람들 대부분이 제가 아는 분일 거라 생각하고 한마디 하자면, 세상에 공짜가 어디 있는가, 주저하지 말고 내게 연락해서 술 한 잔 사게! (언젠가부터 술 강요 청탁 협박 블로그가 되어 가고 있군...)

**속성 (Properties) 추가하기**

이제, GObject 속성(properties) 기능을 추가하려고 하는데, 왜 쓸데없이 일을 만들어서 하냐고 물으면 할 말이 있어야할 것 같아서, GObject 속성의 특징을 요약해 봤습니다.

1.  단일 API로 모든 속성 값을 얻어오거나 변경하기
2.  속성 변경시 자동으로 호출되는 함수 등록하기 (시그널 이용)
3.  실행 중에 속성에 대한 정보 얻어내기

물론 이미 많은 언어와 라이브러리가 그 이상의 기능을 지원하기도 하고, 일정 능력 이상의 개발자라면 직접 구현하는게 아주 어려운 것도 아닙니다. 하지만 이미 잘 구현되어 검증받은 라이브러리가 있는데 굳이 새로운 바퀴를 만들 필요는 없겠지요? 아무튼, 정확한 내용은 글을 적으면서 하나씩 설명해 나가겠습니다.

GObject 객체에 속성을 추가하려면 속성의 값(value)이 어떤 형(type)인지, 이름이 무엇인지, 값의 범위는 어떻게 되는지, 기본값은 무엇인지 등을 정의해서 알려주어야 합니다. (C++이나 Java에서 클래스 멤버 변수를 정의하는 것과 비슷합니다) 이러한 정보를 줄임말로 스펙(spec.)이라고 한다면, 속성을 추가한다는 건 다른 말로, 스펙으로 명시한 속성 정보를 클래스에 설치(install)하는 것을 의미합니다. 객체 인스턴스마다 속성의 실제 값(value)은 모두 다르겠지만, 어떤 속성이 있는지 그 속성은 어떻게 구성되어는지는 모두 동일하겠지요. (참고로 GObject 관련 API를 훑어보시면 정확히 모르더라도 지금 언급한 개념의 단어로 이루어진 API가 꽤 많은 걸 아시게 될 겁니다) 그렇기 때문에, 속성을 추가하는 작업은 클래스 초기화 함수에서 이루어집니다.

다음은 기존 예제에서 속성을 추가한 코드입니다. (변경된 부분만 보여드립니다)

**edc-host.c**

    /* ...[snip]... */

    enum
    {
      EDC_HOST_PROP_0, /* ignore */
      EDC_HOST_PROP_NAME,
      EDC_HOST_PROP_ADDRESS,
      EDC_HOST_PROP_PORT,
      EDC_HOST_PROP_USER,
      EDC_HOST_PROP_PASSWORD
    };

    /* ...[snip]... */

    static void
    edc_host_get_property (GObject    *object,
                           guint       property_id,
                           GValue     *value,
                           GParamSpec *pspec)
    {
      EdcHost *host = EDC_HOST (object);
      EdcHostPrivate *priv;

      priv = EDC_HOST_GET_PRIVATE (host);

      switch (property_id)
        {
        case EDC_HOST_PROP_NAME:
          g_value_set_string (value, priv->name);
          break;
        case EDC_HOST_PROP_ADDRESS:
          g_value_set_string (value, priv->address);
          break;
        case EDC_HOST_PROP_PORT:
          g_value_set_int (value, priv->port);
          break;
        case EDC_HOST_PROP_USER:
          g_value_set_string (value, priv->user);
          break;
        case EDC_HOST_PROP_PASSWORD:
          g_value_set_string (value, priv->password);
          break;
        default:
          /* We don't have any other property... */
          G_OBJECT_WARN_INVALID_PROPERTY_ID (object,
                                             property_id,
                                             pspec);
          break;
        }
    }

    static void
    edc_host_set_property (GObject      *object,
                           guint         property_id,
                           const GValue *value,
                           GParamSpec   *pspec)
    {
      EdcHost *host = EDC_HOST (object);
      EdcHostPrivate *priv;

      priv = EDC_HOST_GET_PRIVATE (host);

      switch (property_id)
        {
        case EDC_HOST_PROP_NAME:
          g_free (priv->name);
          priv->name = g_value_dup_string (value);
          break;
        case EDC_HOST_PROP_ADDRESS:
          g_free (priv->address);
          priv->address = g_value_dup_string (value);
          break;
        case EDC_HOST_PROP_PORT:
          priv->port = g_value_get_int (value);
          break;
        case EDC_HOST_PROP_USER:
          g_free (priv->user);
          priv->user = g_value_dup_string (value);
          break;
        case EDC_HOST_PROP_PASSWORD:
          g_free (priv->password);
          priv->password = g_value_dup_string (value);
          break;
        default:
          /* We don't have any other property... */
          G_OBJECT_WARN_INVALID_PROPERTY_ID (object,
                                             property_id,
                                             pspec);
          break;
        }
    }

    /* ...[snip]... */

    /* class initializer */
    static void
    edc_host_class_init (EdcHostClass *klass)
    {
      GObjectClass *gobj_class;
      GParamSpec *pspec;

      gobj_class = G_OBJECT_CLASS (klass);
      gobj_class->finalize = edc_host_finalize;
      gobj_class->set_property = edc_host_set_property;
      gobj_class->get_property = edc_host_get_property;

      g_type_class_add_private (gobj_class,
                                sizeof (EdcHostPrivate));

      pspec =
        g_param_spec_string ("name",               /* name */
                             "Name",               /* nick */
                             "the name of a host", /* blurb */
                             "",                   /* default */
                             G_PARAM_READWRITE);
      g_object_class_install_property (gobj_class,
                                       EDC_HOST_PROP_NAME,
                                       pspec);

      pspec = g_param_spec_string ("address",
                                   "Address",
                                   "the address of a host",
                                   "",
                                   G_PARAM_READWRITE);
      g_object_class_install_property (gobj_class,
                                       EDC_HOST_PROP_ADDRESS,
                                       pspec);

      pspec = g_param_spec_int ("port",
                                "Port",
                                "the port number of a host",
                                0,     /* minimum */
                                65535, /* maximum */
                                0,     /* default */
                                G_PARAM_READWRITE);
      g_object_class_install_property (gobj_class,
                                       EDC_HOST_PROP_PORT,
                                       pspec);

      pspec = g_param_spec_string ("user",
                                   "User",
                                   "password for authetication",
                                   "",
                                   G_PARAM_READWRITE);
      g_object_class_install_property (gobj_class,
                                       EDC_HOST_PROP_USER,
                                       pspec);

      pspec = g_param_spec_string ("password",
                                   "Password",
                                   "password for authetication",
                                   "",
                                   G_PARAM_READWRITE);
      g_object_class_install_property (gobj_class,
                                       EDC_HOST_PROP_PASSWORD,
                                       pspec);
    }

제일 먼저 정의된 열거형 타입에 대해 설명하자면, 클래스 내부에서 속성은 정수형 숫자로 관리됩니다. 예를 들어 1번 속성, 3번 속성처럼 직접 정수형을 사용해도 되지만, 관례적으로 가독성을 위해 열거형으로 정의합니다. 이렇게 정의한 번호를 클래스에 속성을 설치할때 지정하면 [[`g_object_class_install_property()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-install-property)],  `edc_host_{get/set}_property() `속성 읽기 / 쓰기 함수의 인자로 \``property_id`'가 전달되는데, 이 ID가 바로 속성 번호입니다. 물론 속성 번호는 [`g_object_class_override_property()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-override-property) 같은 다른 API에서도 사용합니다.[](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-override-property)

`edc_host_class_init()` 클래스  초기화 함수를 보면, [`g_param_spec_*()`](http://library.gnome.org/devel/gobject/stable/gobject-Standard-Parameter-and-Value-Types.html) 함수를 이용하여 각 속성의 스펙을 정의해서 [`g_object_class_install_property()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-install-property)함수를 이용해 클래스 객체에 설치합니다. 그리고,속성 읽기 /쓰기 메쏘드를 재정의합니다. 참고로 API 문서를 확인하시면, 다양한 형(type)을 위한 스펙 정의 함수가 있는 걸 알 수 있습니다. 속성 스펙을 정의할때 마지막에 넣어주는 플래그(flags)는 속성의 특성을 정의하는데, [GParamFlags](http://library.gnome.org/devel/gobject/stable/gobject-GParamSpec.html#GParamFlags) 설명을 한 번 읽어보시면 어렵지 않게 이해할 수 있습니다. 여기서는 모든 속성을 읽고 쓰기 가능하게 했습니다.

재정의된 `edc_host_{get/set}_property() `속성 읽기 / 쓰기 메쏘드 함수를 보면, 접근자(accessor) 함수와 동일한 작업을 합니다. 다른 점이라면 속성 ID에 따라 [GValue](http://library.gnome.org/devel/gobject/stable/gobject-Generic-values.html) 객체에서 값을 읽거나, 값을 할당한다는 점입니다. GValue 객체는 쉽게 말해 어떤 형(type)의 값이라도 담을 수 있는 일반적인 값(generic values)입니다. 참고로 이 역시 다양한 형(type)을 위한 [`g_value_{set,get}_*()`](http://library.gnome.org/devel/gobject/stable/gobject-Standard-Parameter-and-Value-Types.html) 형태의 함수가 존재하므로 이를 그대로 이용하면 됩니다. (물론 더 능숙하게 사용하려면 API 문서를 한 번 훑어보는게 좋겠지요)

여기까지 이해하셨다면 아시겠지만, GObject 시스템은 속성에 전반적인 틀과 관리 체계만 제공할 뿐 실제 속성을 다루는 작업은 대부분 직접 구현해야 합니다. 이는 프로그래머의 자유도를 높여 주기도 하지만, 불필요한 반복 작업을 유발하기도 합니다. 그리고 이 때문에 [Vala](http://live.gnome.org/Vala) 같은 GObject 기반 언어가 새로 만들어지기도 했습니다.

**속성 (Properties) 사용하기
**

이렇게 정의한 속성을 객체 외부에서 사용하기 위해 몇 가지 방법이 있지만, 가장 쉽고 많이 사용하는 방법은 [`g_object_get()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-get) / [`g_object_set()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-set) 함수를 이용하는 겁니다.

    {
      EdcHost *host;
      gchar *address;
      gint port;

      g_type_init ();

      host = edc_host_new ();

      g_object_set (host,
                    "address", "192.168.0.100",
                    "port", 8080,
                    NULL);

      address = edc_host_get_address (host);
      g_assert_cmpstr (address, ==, "192.168.0.100");
      g_free (address);

      g_object_get (host,
                    "address", &address,
                    "port", &port,
                    NULL);

      g_assert_cmpstr (address, ==, "192.168.0.100");
      g_assert_cmpint (port, ==, 8080);
      g_free (address);
      
      g_object_unref (host);
    }

[`g_object_new()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-new) 함수를 이용하여 객체를 생성할때 아예 속성을 함께 지정할 수도 있습니다.

    {
      EdcHost *host;
      gchar *address;
      gint port;

      g_type_init ();

      host = g_object_new (EDC_TYPE_HOST,
                           "address", "demo.emstone.com",
                           "port", 8081,
                           NULL);
      g_object_get (host,
                    "address", &address,
                    "port", &port,
                    NULL);
      g_assert_cmpstr (address, ==, "demo.emstone.com");
      g_assert_cmpint (port, ==, 8081);
      g_free (address);

      g_object_unref (host);  

    }

눈여겨 보신 분은 아시겠지만, `edc_host_new()` 함수는 `g_object_new (EDC_TYPE_HOST, NULL)` 호출로 만들어진 객체를 돌려주는 역할만 합니다.

이렇게 대략 GObject 속성 기본 사용법을 설명한 것 같습니다. 물론 이 예제 코드에는 몇 가지 오류가 남아있는데, 이는 위에서 언급한 것처럼 객체 속성을 다루는 다른 부분을 설명하면서 보완해 나갈 예정입니다.

오늘은 여기까지입니다.
