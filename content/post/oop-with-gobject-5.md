---
date: "2012-02-24T00:00:00Z"
tags:
- Agile
- Clutter
- Coding
- GLib
title: GObject 객체 지향 프로그래밍 (5)
---

거의 2년만에 GObject 객체 지향 프로그래밍 연재 글을 포스팅합니다. 사실 이 글의 일부는 예전에 작성해 둔 것인데, 이번 [GNOME Tech Talks](http://gnome-kr.blogspot.com/2012/02/2-gnome-tech-talks.html)에서 발표 하나를 맡게 되면서, 슬라이드 자료를 따로 만들 시간은 없고 그렇다고 오래된 자료를 재탕하는 건 실례인 것 같아 조금 보완해서 작성했습니다. 참고로, GObject 개념을 잘 모르는 분이라면 이전 연재 글을 먼저 읽어 보시면 도움이 될 수 있습니다. :)

1.  [GObject 객체 지향 프로그래밍 (1)](/2009/08/10/oop-with-gobject-1/ "GObject 객체 지향 프로그래밍 (1)")
2.  [GObject 객체 지향 프로그래밍 (2)](/2009/08/14/oop-with-gobject-2/ "GObject 객체 지향 프로그래밍 (2)")
3.  [GObject 객체 지향 프로그래밍 (3)](/2009/08/18/oop-with-gobject-3/ "GObject 객체 지향 프로그래밍 (3)")
4.  [GObject 객체 지향 프로그래밍 (4)](/2009/08/24/oop-with-gobject-4/ "GObject 객체 지향 프로그래밍 (4)")
5.  [싱글턴(Singleton) GObject 객체 만들기](/2010/02/11/how-to-make-a-gobject-singleton/ "싱글턴(Singleton) GObject 객체 만들기")
6.  [GObject 속성 직렬화(Serialization)하기](/2010/04/07/serialize-gobject-properties/ "GObject 속성 직렬화(Serialization)하기")

GObject 객체 지향 시스템을 구성하는 여러가지 개념 중 상속(inheritance), 참고 카운터(reference counting), 속성(properties) 등에 대해서는 지난 글에서 이미 소개했습니다. 아직 GObject 라이브러리에서 소개하지 않은 개념이 아직 많이 남아 있지만, 그 중에서 가장 중요한 것 중 하나는 바로 시그널(signals)이 아닐까 생각합니다. 속성이 변경되었을때 자동으로 호출되는 콜백 함수를 등록해서 사용하는 방법을 설명할 때 약간 소개했지만, 아무래도 그걸로는 부족하기 때문에 이번 글은 시그널의 개념과 사용 방법, 그리고 속성 바인딩을 정리해 보았습니다.

**간단한 클러터 기반 시계**

![](/figures/myclock-screenshot.png)

언제나 그렇듯이 재미없는 예제 소스를 먼저 보여드립니다. 이 소스를 컴파일해서 실행하면 위 그림과 같은 시계가 동작합니다.

```c
/* myclock1.c */

/*****************************************************************************/

#include <glib-object.h>

#define MY_TYPE_CLOCK (my_clock_get_type ())
#define MY_CLOCK(obj) 
  (G_TYPE_CHECK_INSTANCE_CAST ((obj), MY_TYPE_CLOCK, MyClock))
#define MY_CLOCK_CLASS(klass) 
  (G_TYPE_CHECK_CLASS_CAST ((klass), MY_TYPE_CLOCK, MyClockClass))
#define MY_IS_CLOCK(obj) 
  (G_TYPE_CHECK_INSTANCE_TYPE ((obj), MY_TYPE_CLOCK))
#define MY_IS_CLOCK_CLASS(klass) 
  (G_TYPE_CHECK_CLASS_TYPE ((klass), MY_TYPE_CLOCK))
#define MY_CLOCK_GET_CLASS(obj) 
  (G_TYPE_INSTANCE_GET_CLASS ((obj), MY_TYPE_CLOCK, MyClockClass))

typedef struct _MyClock        MyClock;
typedef struct _MyClockClass   MyClockClass;
typedef struct _MyClockPrivate MyClockPrivate;

struct _MyClock
{
  GObject         parent;
  MyClockPrivate *priv;
};

struct _MyClockClass
{
  GObjectClass parent_class;
};

enum
{
  PROP_0,
  PROP_DATE_TIME,
  PROP_LAST
};

struct _MyClockPrivate
{
  GDateTime *datetime;
  guint      timeout;
};

G_DEFINE_TYPE (MyClock, my_clock, G_TYPE_OBJECT);

static GParamSpec *props[PROP_LAST];

GDateTime *
my_clock_get_date_time (MyClock *clock_)
{
  g_return_val_if_fail (MY_IS_CLOCK (clock_), NULL);

  return g_date_time_ref (clock_->priv->datetime);
}

static void
my_clock_set_date_time (MyClock   *clock_,
                        GDateTime *datetime)
{
  g_date_time_unref (clock_->priv->datetime);
  clock_->priv->datetime = g_date_time_ref (datetime);
  g_object_notify_by_pspec (G_OBJECT (clock_), props[PROP_DATE_TIME]);
}

static gboolean
my_clock_update (gpointer data)
{
  MyClock   *clock_ = data;
  GTimeVal   now;
  GDateTime *datetime;
  guint      interval;

  g_get_current_time (&now);

  datetime = g_date_time_new_from_timeval_local (&now);
  my_clock_set_date_time (clock_, datetime);
  g_date_time_unref (datetime);

  interval = (1000000L - now.tv_usec) / 1000L;
  clock_->priv->timeout =
    g_timeout_add_full (G_PRIORITY_HIGH_IDLE,
                        interval,
                        my_clock_update,
                        g_object_ref (clock_),
                        g_object_unref);

  return FALSE;
}

static void
my_clock_set_property (GObject      *object,
                       guint         param_id,
                       const GValue *value,
                       GParamSpec   *pspec)
{
  switch (param_id)
    {
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, param_id, pspec);
      break;
    }
}

static void
my_clock_get_property (GObject   *object,
                       guint      param_id,
                       GValue     *value,
                       GParamSpec *pspec)
{
  MyClock *clock_ = MY_CLOCK (object);

  switch (param_id)
    {
    case PROP_DATE_TIME:
      g_value_set_boxed (value, clock_->priv->datetime);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, param_id, pspec);
      break;
    }
}

static void
my_clock_finalize (GObject *gobject)
{
  MyClockPrivate *priv = MY_CLOCK (gobject)->priv;

  g_date_time_unref (priv->datetime);
  g_source_remove (priv->timeout);

  G_OBJECT_CLASS (my_clock_parent_class)->finalize (gobject);
}

static void
my_clock_class_init (MyClockClass *klass)
{
  GObjectClass *obj_class = G_OBJECT_CLASS (klass);
  GParamSpec   *pspec;

  obj_class->set_property = my_clock_set_property;
  obj_class->get_property = my_clock_get_property;
  obj_class->finalize     = my_clock_finalize;

  g_type_class_add_private (klass, sizeof (MyClockPrivate));

  pspec = g_param_spec_boxed ("datetime",
                              "Date and Time",
                              "The date and time to show in the clock",
                              G_TYPE_DATE_TIME,
                              G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  props[PROP_DATE_TIME] = pspec;
  g_object_class_install_property (obj_class, PROP_DATE_TIME, pspec);
}

static void
my_clock_init (MyClock *clock_)
{
  MyClockPrivate *priv;

  priv = clock_->priv =
    G_TYPE_INSTANCE_GET_PRIVATE (clock_,
                                 MY_TYPE_CLOCK,
                                 MyClockPrivate);

  priv->datetime = g_date_time_new_now_local ();
  priv->timeout = 0;

  my_clock_update (clock_);
}

MyClock *
my_clock_new (void)
{
  return g_object_new (MY_TYPE_CLOCK, NULL);
}

/*****************************************************************************/

#include <clutter/clutter.h>

static void
clock_datetime_changed (GObject    *object,
                        GParamSpec *pspec,
                        gpointer    data)
{
  MyClock      *clock_ = MY_CLOCK (object);
  ClutterActor *text   = data;
  GDateTime    *datetime;
  gchar        *str;

  datetime = my_clock_get_date_time (clock_);
  str = g_date_time_format (datetime, "%xn%H:%M:%S");

  clutter_text_set_text (CLUTTER_TEXT (text), str);

  g_free (str);
  g_date_time_unref (datetime);
}

int
main (int    argc,
      char **argv)
{
  ClutterActor      *stage;
  ClutterActor      *text;
  ClutterConstraint *constraint;
  MyClock           *clock_;

  if (clutter_init (&argc, &argv) != CLUTTER_INIT_SUCCESS)
    return -1;

  /* stage */
  stage = clutter_stage_get_default ();
  clutter_actor_set_size (stage, 320, 240);
  clutter_stage_set_color (CLUTTER_STAGE (stage), CLUTTER_COLOR_Black);
  clutter_stage_set_user_resizable (CLUTTER_STAGE (stage), TRUE);

  /* text */
  text = clutter_text_new_full ("Sans Bold 20",
                                "NOW",
                                CLUTTER_COLOR_LightButter);
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), text);
  clutter_text_set_line_alignment (CLUTTER_TEXT (text), PANGO_ALIGN_CENTER);

  /* align text in center of stage */
  constraint =
    clutter_align_constraint_new (stage, CLUTTER_ALIGN_X_AXIS, 0.5);
  clutter_actor_add_constraint (text, constraint);

  constraint =
    clutter_align_constraint_new (stage, CLUTTER_ALIGN_Y_AXIS, 0.5);
  clutter_actor_add_constraint (text, constraint);

  /* clock */
  clock_ = my_clock_new ();
  g_signal_connect (clock_,
                    "notify::datetime",
                    G_CALLBACK (clock_datetime_changed),
                    text);

  clutter_actor_show (stage);

  clutter_main ();

  return 0;
}
```

소스 코드를 간단하게 설명하면, `MyClock` 객체가 1초 간격으로 현재 시간을 얻어와 자신의 `datetime` 속성을 갱신하면[`my_clock_update()`], 속성이 변경되었을때(`notify::datetime`) 자동으로 호출되는 콜백 함수를[`clock_datetime_changed()`] 등록해 자동으로 클러터 텍스트(`ClutterText`)를 이용해 화면에 표시합니다.

이제 이 소스 코드를 두 가지 방법으로 확장하려고 합니다. 첫번째 방법은 속성 바인딩(property binding)을 이용해 시그널을 사용하지 않는 방법이고, 두번째 방법은 시간이 변경되었을때 호출되는 진짜(!) 시그널을 추가하는 것입니다.

**속성 바인딩 (Property Binding)**

속성 바인딩(property binding)이란 두 GObject 객체간의 두 속성을 묶는 걸 말합니다. 여기서 묶는다는 의미는, 한 객체의 속성 값이 변하면 다른 객체의 속성 값도 자동으로 변한다는 의미입니다. 물론 묶으려는 두 속성은 같은 형(type)이어야 합니다. 그런데, 위 예제의 경우 `MyClock:``datetime` 속성과 [`ClutterText:``text`](http://developer.gnome.org/clutter/stable/ClutterText.html#ClutterText--text) 속성은 형(type)이 다릅니다. 그래서, 위 소스를 다음과 같이 수정합니다. (변경된 부분만 보여 드립니다)

```c
/* myclock2.c */

/* ... */

enum
{
  PROP_0,
  PROP_DATE_TIME,
  PROP_TEXT,
  PROP_LAST
};

struct _MyClockPrivate
{
  GDateTime *datetime;
  guint      timeout;
  gchar     *text;
};

/* ... */

const gchar *
my_clock_get_text (MyClock *clock_)
{
  g_return_val_if_fail (MY_IS_CLOCK (clock_), NULL);

  return clock_->priv->text;
}

static void
my_clock_set_date_time (MyClock   *clock_,
                        GDateTime *datetime)
{
  g_date_time_unref (clock_->priv->datetime);
  clock_->priv->datetime = g_date_time_ref (datetime);
  g_object_notify_by_pspec (G_OBJECT (clock_), props[PROP_DATE_TIME]);

  g_free (clock_->priv->text);
  clock_->priv->text = g_date_time_format (datetime, "%xn%H:%M:%S");
  g_object_notify_by_pspec (G_OBJECT (clock_), props[PROP_TEXT]);
}

/* ... */

static void
my_clock_finalize (GObject *gobject)
{
  /* ... */
  g_free (priv->text);
  /* ... */
}

static void
my_clock_class_init (MyClockClass *klass)
{
  /* ... */

  pspec = g_param_spec_string ("text",
                               "Text",
                               "The text of the date and time",
                               NULL,
                               G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  props[PROP_TEXT] = pspec;
  g_object_class_install_property (obj_class, PROP_TEXT, pspec);
}

static void
my_clock_init (MyClock *clock_)
{
  /* ... */
  priv->text = NULL;
  /* ... */
}

/* ... */

int
main (int    argc,
      char **argv)
{
  /* ... */

  /* clock */
  clock_ = my_clock_new ();
  g_object_bind_property (clock_, "text",
                          text,  "text",
                          G_BINDING_SYNC_CREATE);

  /* ... */
}
```

위 코드에서 변경된 내용은, `MyClock`에 문자열 형식의 `text` 속성을 추가하고[`my_clock_class_init()`], `datetime` 속성을 갱신할때 `text` 속성도 함께 갱신하도록 한 다음[`my_clock_set_date_time()`], 기존 속성 변경(`notify::datetime`)에 대한 `g_signal_connect()` 함수 호출 대신 `g_object_bind_property()` 함수를 이용해 두 객체의 속성을 묶었다는 점입니다. 여기서 핵심은 물론 `g_object_bind_property()` 함수인데, 이 함수는 [GLib 2.26 버전에 추가](/2010/10/02/glib-2-26-0-release/)되었으며 [예전에 소개한 ExoBinding](/2008/12/15/exobinding/)과 사용법이 거의 유사합니다. 물론, 옵션을 통해 바인딩하는 시점부터 값을 동기화할 지(`G_BINDING_SYNC_CREATE`), 단방향이 아닌 양방향으로 동기화할 지(`G_BINDING_BIDIRECTIONAL`) 등을 지정할 수도 있습니다. 이처럼, 위의 코드에서 볼 수 있듯이, 속성 바인딩을 이용하면 매번 콜백함수를 만들지 않고도 간단하게 코드 몇 줄로 원하는 객체 속성간의 동기화(synchronization)를 처리할 수 있습니다.

여담이지만, 처음 이 기능을 접했을때 맥, 아이폰 응용 프로그램을 개발하기 위해 XCode에서 마우스 드래그 만으로 객체 속성간 바인딩이 지원되는 것처럼, 코딩이 아닌, Glade 같은 GUI 도구에서 위젯 속성간 바인딩이 지원되면 참 편하지 않을까 하는 생각이 들었던 적도 있습니다.

**시그널 (Signals)**

[GObject 공식 매뉴얼](http://developer.gnome.org/gobject/stable/chapter-signal.html)에 의하면 시그널(signals)은 메시지 전달 시스템을 구성하는 두가지 기술 중 하나입니다. 하나는 클로저(closures)이고 다른 하나가 시그널(signals)인데, 클로저가 콜백(callback) 함수를 자료구조로 정의한 거라면, 시그널은 이 콜백함수를 등록하고 호출하는 알고리즘을 정의한 것이라고 이해해도 무방합니다.

클로저를 다시 정의하지 않고 함수 포인터를 직접 사용해도 될 것 같은데 이를 객체로 정의한 이유는 여러가지가 있지만, 무엇보다도 콜백함수에 전달되는 인자(parameters) 목록과 인자 형(type)에 대한 처리(marshalling) 때문입니다. C/C++ 언어에서 함수 호출시 스택에 쌓이는 인자를 가공하는 것 뿐 아니라, GObject가 지원하는 여러 언어에 대한 바인딩을 위해 더 일반화된 클로저(closure) 객체가 필요합니다.

아무튼, 이론적인 설명은 그만하고 다시 본론으로 돌아와서, 위 예제에서 구현한 `MyClock` 객체가 생각보다 잘 설계되고 동작하는 바람에(...) 프로그램 전체에서 이 객체를 사용하기로 결정했다고 가정해 봅시다. 수많은 모듈과 수많은 객체에서 전역 시계 객체에 속성 알림(notify) 시그널을 연결합니다. 그리고 그때마다 `my_clock_get_date_time()`을 호출해 현재 시간을 가져와서 처리합니다. 물론 이 예제에서 전달되는 `GDateTime` 구조체는 참조 카운터 방식으로 관리되기 때문에 구조체 전달시  많은 오버헤드가 없지만, 문자열을 복사하거나 많은 데이터가 전달되는 경우라면 무시할 수 없는 상황이 발생합니다. 그래서, 위 첫번째 소스를 다음과 같이 조금 수정합니다.

```c
/* myclock3.c */

/* ... */

struct _MyClockClass
{
  GObjectClass parent_class;

  /* signals */
  void (*changed) (MyClock   *clock_,
                   GDateTime *datetime);
};

enum
{
  SIGNAL_CHANGED,
  SIGNAL_LAST
};

/* ... */

static guint       signals[SIGNAL_LAST];

/* ... */

static void
my_clock_set_date_time (MyClock   *clock_,
                        GDateTime *datetime)
{
  /* ... */
}

static void
my_clock_real_changed (MyClock   *clock_,
                       GDateTime *datetime)
{
  my_clock_set_date_time (clock_, datetime);
}

static gboolean
my_clock_update (gpointer data)
{
  /* ... */

  datetime = g_date_time_new_from_timeval_local (&now);
  g_signal_emit (clock_, signals[SIGNAL_CHANGED], 0, datetime);
  g_date_time_unref (datetime);

  /* ... */
}

static void
my_clock_class_init (MyClockClass *klass)
{
  /* ... */

  klass->changed = my_clock_real_changed;

  signals[SIGNAL_CHANGED] =
    g_signal_new ("changed",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  G_STRUCT_OFFSET (MyClockClass, changed),
                  NULL,
                  NULL,
                  g_cclosure_marshal_VOID__POINTER,
                  G_TYPE_NONE,
                  1,
                  G_TYPE_POINTER);
}

/* ... */

static void
clock_changed (MyClock   *clock_,
               GDateTime *datetime,
               gpointer   user_data)
{
  ClutterActor *text = user_data;
  gchar        *str;

  str = g_date_time_format (datetime, "%xn%H:%M:%S");
  clutter_text_set_text (CLUTTER_TEXT (text), str);
  g_free (str);
}

int
main (int    argc,
      char **argv)
{
  /* ... */

  /* clock */
  clock_ = my_clock_new ();
  g_signal_connect (clock_,
                    "changed",
                    G_CALLBACK (clock_changed),
                    text);

  /* ... */
}
```

바로 위 코드에 보이는 것처럼 `g_signal_connect()` 호출시 연결하는 시그널 이름과 콜백 함수[`clock_changed()`]가 더 단순하고 효율적으로 변경된 걸 확인할 수 있습니다. 콜백 함수 호출시 전달되는 인수를 그냥 사용하면 되니까 오버헤드가 매우 많이 줄어들 수 밖에 없습니다. 하지만 시그널을 정의해서 사용하는게 단순히 성능과 효율 때문만은 아닙니다. 위 예제에서는 속성이 변경되었을 때 발생하는 시그널을 정의했지만, 일반적으로 시그널은 속성 만으로 표현할 수 없는 객체의 상태 변화를 알리기 위해서 많이 사용합니다.(예: `ClutterActor::enter-event` 시그널) 또한 속성의 변화를 통해 알 수 있더라도 더 쉽고 명확하게 이를 전파하기 위해서도 사용합니다.(예: `ClutterActor::hide` 시그널과 `ClutterActor:visible` 속성)

더 나아가, 시그널은 상태 변화 뿐 아니라 객체의 동작 방식을 외부에서 제어할 수 있도록 유연성을 제공하는데도 사용합니다. 더 자세한 이해를 위해 시그널 함수 포인터부터 설명하자면, 클래스 구조체 안에 선언된 시그널 함수 포인터[`MyClockClass::changed()`]는 일종의 가상 함수(virtual function) 역할을 하면서, 시그널이 발생하면(emit) `g_signal_connect()`를 이용해 등록된 사용자 콜백함수가 모두 실행된 뒤 맨 나중에 실행되거나 혹은 사용자 콜백 함수보다 먼저 실행됩니다. 따라서 필요 없을 경우 그냥 `NULL`로 내버려두어도 상관없지만, 위 예제에서는 클래스 생성시 `my_clock_real_changed()` 함수를 등록시켰습니다. `my_clock_real_changed()`는 다시  실제로 `datetime` 속성을 갱신하는 작업을 처리하는 `my_clock_set_date_time()`을 호출합니다. 그리고, 기존 시간 갱신 함수[`my_clock_update()`]에서는 직접 `my_clock_set_date_time()`을 호출하지 않고, 시그널을 발생시켜[`g_signal_emit()`] 작업을 처리합니다.

왜 이렇게 복잡하게 일을 나누어 처리할까요? 이렇게 구현하면 몇 가지 장점이 있기 때문입니다. 예를 들어 위 예제에서는 `datetime` 속성이 읽기 전용으로 선언되어 있기 때문에 외부에서 그 값을 변경할 수 없습니다. 하지만, 외부에서 직접 `g_signal_emit_by_name()` 등을 이용해 시그널을 발생시키면 시그널에 연결된 모든 콜백 함수 뿐 아니라 `my_clock_real_changed()` 함수까지도 간접적으로 호출되어 작업을 처리하도록 할 수 있습니다. 게다가 만일 시그널에 연결된 콜백 함수 중 하나가 어떤 이유로 `g_signal_stop_emission_by_name()` 등을 호출하면 이후 실행될 콜백 함수나 `my_clock_real_changed()` 함수가 호출되지 않게 할 수도 있고, 심지어 객체의 클래스에 등록된 함수 포인터에 직접 자신만의 콜백 함수를 등록해서 원래 작업이 아예 수행되지 않게 할 수도 있습니다.

참고로, GTK+ / Clutter 등과 같은 GObject 기반 그래픽 툴킷 시스템은 대부분 이 시그널 콜백 함수 메커니즘을 이용해 커스텀 위젯을 만들거나 기존 액터를 상속받아 사용자가 마음껏 기능을 확장할 수 있는 길을 열어 두었습니다.(예: [`clutter_actor.c:clutter_actor_real_paint()`](http://git.gnome.org/browse/clutter/tree/clutter/clutter-actor.c#n4856) 소스 참고)

시그널 객체는 `g_signal_new()` 함수를 이용해 생성한 뒤 전역 `signals[]` 배열에 ID를 저장해 둡니다. 이렇게 저장한 시그널 ID는 `g_signal_emit()` 함수 호출시 사용합니다. 물론 이렇게 ID를 따로 저장하지 않고 `g_signal_emit_by_name()`을 사용해 시그널 이름으로 직접 시그널을 발생시켜도 되지만, 어차피 내부적으로 시그널 이름을 ID로 변환하는 과정을 거치기 때문에 효율을 위해 객체 구현시 관례적으로 이런식으로 작성합니다. 물론 객체 외부에서는 시그널 ID를 모르기 때문에 어쩔 수 없이  `g_signal_emit_by_name()`을 사용해야 합니다.

[g\_signal\_new()](http://developer.gnome.org/gobject/stable/gobject-Signals.html#g-signal-new) 함수의 인자 중에서 중요한 항목만 설명하면, 첫번째 항목은 시그널 이름을 정의하고, 세번째 항목은 시그널 함수 포인터가 맨 나중에 실행될 지(`G_SIGNAL_RUN_LAST`), 또는 가장 먼저 실행될 지(`G_SIGNAL_RUN_FIRST`) 등을 지정합니다. 네번째 항목은 클래스 구조체에 정의된 시그널 함수 포인터 위치를 지정하고, 여덟번째는 시그널 콜백 함수의 리턴 형(type), 아홉번째는 콜백 함수에게 전달할 인자의 갯수, 열번째부터는 전달될 인자의 형(types)을 차례대로 정의합니다.

[g\_signal\_new()](http://developer.gnome.org/gobject/stable/gobject-Signals.html#g-signal-new) 함수의 일곱번째 인자는 함수 호출시 인자를 처리하는 마샬링(marshalling) 함수를 지정하는데, 함수의 리턴 형(type)과 인자 목록, 인자의 각 형(type)이 정확히 일치되는 함수를 지정해야 합니다. 그런데 원하는 형태의 마샬링 함수를 GLib에서 기본으로 제공하지 않을 경우 `glib-genmarshal` 프로그램을 이용해 직접 C 소스 코드를 생성해서 사용해야 했는데, GLib 2.30 버전부터는 그냥 `NULL`을 지정하면 [libffi](http://sourceware.org/libffi/) 라이브러리를 이용해 구현한 `g_cclosure_marshal_generic()` 함수가 기본으로 호출되어, 알아서 자동으로 마샬링을 처리합니다.

정리하자면, GObject 시그널은 모델-뷰(model-view) 구조나 관찰자 패턴(observer pattern)을 구현하는데 사용하기도 하지만, 더 복잡한 객체 지향 시스템을 설계할 때도 유용합니다. 하지만, 여기서는 시그널의 특징과 개념만 설명하느라 전체 기능의 반의 반도 소개되지 않은 셈입니다. 따라서 더 깊은 이해와 활용을 원하시면 반드시 참고 매뉴얼을 한 번 정독하시길 권합니다.

**그리고...**

다른 프로그래머가 왜 C++, Java, Python 처럼 좋은 언어 놔두고 C 언어 기반에서 복잡한 GObject 같은 걸 가지고 객체 지향 프로그래밍을 할려고 애쓰냐고 물어본다면,  [리눅스 커널 메일링 리스트 FAQ](http://www.tux.org/lkml/#s15-3)에 있는 유명한 다음 구절을 해석해서 미소지으며 알려주시기 바랍니다.

> What's important about object-oriented programming is the techniques, not the languages used.

뭐, 모든 도구는 필요한 곳이 반드시 있으니까 계속 존재합니다. 다만 내가 아직 그 쓰임새를 알지 못할 뿐이죠... :)
