---
date: "2009-08-24T00:00:00Z"
tags:
- Agile
- Coding
- GLib
- GTK+
title: GObject 객체 지향 프로그래밍 (4)
---

이전 글에 계속 이어집니다.

**객체 속성 정보 얻기**

EdcHost 객체의 속성 정보를 실행 중에 얻어볼까 합니다.

왜 또 갑자기 불필요한 예제를 꺼내냐고 물어보실 분이 있을 것 같아 말하자면, 가끔 요긴한 경우가 있기 때문입니다. 예를 들어 EdcHost 객체를 상속받은 EdcHostDoosan, EdcHostKia, EdcHostLitte 객체가 여러 개 존재할 경우, 이 객체들은 EdcHost의 공통 속성 뿐 아니라 본인의 속성도 따로 가집니다. 이러한 여러 객체를 관리할때, 특정 속성이 있는지 여부를 검사해서 관련 UI를 활성 / 비활성하거나, 편집 UI 자체를 속성 스펙과 목록을 이용해 100% 자동화하는 게 가능합니다. (Glade 처럼 말이죠) 물론 옵션 같은 플래그(flags) 변수를 정의하는 방법 등 여러가지 대안이 가능하겠지만, 최초 객체 설계시 고려하지 못했던 기능이나 속성을 나중에 계속 추가해 나가야 하는 경우 기존에 만든 객체를 매번 다시 수정하고 업그레이드하는 것보다 더 안전하고 깔끔한 방법이 될 수 있습니다. 그리고 당연히 더많은 응용이 있겠지만, 일단 알아두면 나중에 어떤 식으로든 도움이 되리라 생각합니다.

일단, 다음 코드는 객체가 가지고 있는 속성 이름과 각 속성의 현재 값을 출력합니다.

    static void
    print_properties (GObject *object)
    {
      GObjectClass *oclass;
      GParamSpec **specs;
      guint n;
      guint i;

      oclass = G_OBJECT_GET_CLASS (object);
      specs = g_object_class_list_properties (oclass, &n);
      for (i = 0; i < n; i++)
        {
          GParamSpec *spec;
          GValue value = { 0 };
          gchar *str;

          spec = specs[i];

          g_value_init (&value, spec->value_type);
          g_object_get_property (G_OBJECT (object),
                                 spec->name,
                                 &value);
          str = g_strdup_value_contents (&value);

          g_print ("property '%s' is '%s'n",
                   spec->name,
                   str);

          g_value_unset (&value);
          g_free (str);
        }
      g_free (specs);
    }

    {
      EdcHost *host;

      /* ... */ 

      host = g_object_new (
               EDC_TYPE_HOST,
               "address", "demo.emstone.com",
               "port", 8081,
               NULL);
      print_properties (G_OBJECT (host));
      g_object_unref (host);

      /* ... */
    }

위 코드에서 분명하게 이해해야 하는 점은, 객체 인스턴스가 아닌 객체 클래스에게 속성 정보를 질의한다는 점입니다. 모든 속성의 스펙을 얻기 위해 [`g_object_class_list_properties()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-list-properties) 함수를 사용하고, GValue 객체에 속성 값을 가져온 다음, 문자열로 출력하기 위해 [`g_strdup_value_contents()`](http://library.gnome.org/devel/gobject/stable/gobject-Generic-values.html#g-strdup-value-contents) 함수를 이용해 변환하고 있습니다.

객체에 어떤 속성이 있는지 알아보려면 [`g_object_class_find_property()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-class-find-property) 함수를 이용하면 됩니다.

**속성 변경 알림 시그널 이용하기**

객체의 속성 값을 변경할 때 `g_object_set()` 함수를 이용하면 좋은 점은, 값을 변경하면 자동으로 시그널(signal)이 발생한다는 점입니다. GObject 시스템에서 시그널은 특정 사건(event)이 일어나면 발생(emit)합니다. 대부분의 경우 시그널은 객체 클래스 초기화시에 정의해야 하지만, 다행히도 속성 값이 변경될때 발생하는 시그널은 특별한 작업을 해주지 않아도 기본적으로 동작합니다. 따라서 "`notify::property-name`" 형식의 이름을 가지는 시그널에 콜백 함수를 연결하면 객체 값이 변경될때 자동으로 호출되는 함수를 등록할 수 있습니다.

    static void
    property_notified (GObject    *object,
                       GParamSpec *pspec,
                       gpointer    data)
    {
      GValue value = { 0 };
      gchar *str;

      g_value_init (&value, pspec->value_type);
      g_object_get_property (object, pspec->name, &value);
      str = g_strdup_value_contents (&value);

      g_print ("property '%s' is set to '%s'n",
                 pspec->name, str);

      g_value_unset (&value);
      g_free (str);
    }

    {
      EdcHost *host;

      host = g_object_new (EDC_TYPE_HOST, NULL);

      g_signal_connect (host,
                        "notify::address",
                        G_CALLBACK (property_notified),
                        NULL);
      g_signal_connect (host,
                        "notify::port",
                        G_CALLBACK (property_notified),
                        NULL);

      g_object_set (host,
                    "address", "192.168.0.1",
                    "port", 8087,
                    NULL);

      edc_host_set_address (host, "192.168.0.22");

      g_object_unref (host);
    }

참고로 이 기능은, 디자인 패턴에서 말하는 관찰자(observer) 패턴일 수도 있고, GObject 매뉴얼에서 사용하는 것처럼 일종의 메시징 시스템 역할도 합니다. 예를 들어 모델(model)의 값이 변경되면 자동으로 뷰(view) 역할을 하는 GUI에 반영하는 코드를 작성할 경우 기존 객체 구현 코드를 수정하지 않고, 다시 말해 의존성을 추가하지 않고 기능을 구현할 수 있게 도와주어 객체간 결합도를 없애 줍니다.

자 그런데, 위 예제에서 `edc_host_set_address()` 를 사용할 때는 콜백함수가 호출이 안되는 문제점이 있습니다. 왜냐하면 이 함수는 내부 address 변수를 직접 수정하기 때문에 값이 변경되었는지 여부를 GObject 시스템이 알 방법이 없기 때문입니다. 따라서 기존 코드를 수정해야 하는데, 첫번째 방법은 접근자를 이용하더라도 내부적으로 `g_object_set()` 을 호출하도록 하는 겁니다. (여기서는 'address' 관련 API만 보여드립니다)

    void
    edc_host_set_address (EdcHost     *host,
                          const gchar *address)
    {
      g_return_if_fail (EDC_IS_HOST (host));
      g_return_if_fail (address != NULL);

      g_object_set (host,
                    "address",  address,
                    NULL);
    }

하지만 이 방법은 약간의 오버헤드가 있을 수 있습니다. 두번째 방법은, [`g_object_notify()`](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-notify) 함수를 이용해 직접 알려주는 겁니다.

    void
    edc_host_set_address (EdcHost     *host,
                          const gchar *address)
    {
      EdcHostPrivate *priv;

      g_return_if_fail (EDC_IS_HOST (host));
      g_return_if_fail (address != NULL);

      priv = EDC_HOST_GET_PRIVATE (host);

      g_free (priv->address);
      priv->address = g_strdup (address);

      g_object_notify (G_OBJECT (host), "address");
    }

`edc_host_set_property()` 함수 안에서 중복되는 코드도 정리해 봅시다.

    static void
    edc_host_set_property (GObject      *object,
                           guint         property_id,
                           const GValue *value,
                           GParamSpec   *pspec)
    {
      EdcHost *host = EDC_HOST (object);
      EdcHostPrivate *priv;

      priv = EDC_HOST_GET_PRIVATE (host);

      switch (property_id)
        {
        case EDC_HOST_PROP_NAME:
          edc_host_set_name (host, g_value_get_string (value));
          break;
        case EDC_HOST_PROP_ADDRESS:
          edc_host_set_address (host, g_value_get_string (value));
          break;
        case EDC_HOST_PROP_PORT:
          edc_host_set_port (host, g_value_get_int (value));
          break;
        case EDC_HOST_PROP_USER:
          edc_host_set_user (host, g_value_get_string (value));
          break;
        case EDC_HOST_PROP_PASSWORD:
          edc_host_set_password (host, g_value_get_string (value));
          break;
        default:
          /* We don't have any other property... */
          G_OBJECT_WARN_INVALID_PROPERTY_ID (object,
                                             property_id,
                                             pspec);
          break;
        }
    }

시그널이 중복 발생할 경우를 염려할 필요는 없습니다. 시그널은 GObject 내부적으로 알아서 잘 정리되어 한 번 변경하면 한 번만 시그널이 발생합니다.

오늘은 여기까지입니다... :)
