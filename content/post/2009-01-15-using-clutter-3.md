---
date: "2009-01-15T00:00:00Z"
tags:
- Clutter
title: 클러터(Clutter) 사용하기 (3)
---

[클러터 튜토리얼](http://www.openismus.com/documents/clutter_tutorial/0.8/docs/tutorial/html/index.html) 내용 계속됩니다.

**컨테이너 (Containers) - 그릇**

어떤 클러터 액터는 [ClutterContainer](http://clutter-project.org/docs/clutter/stable/ClutterContainer.html) 인터페이스를 구현합니다. 이 액터는 자식 액터를 담을 수 있고, 목록이나 표 형태처럼 각각에 상대적인 위치를 지정할 수도 있습니다. 더 나아가 변환(transformation)이나 속성(properties) 변경을 한꺼번에 모든 자식에게 적용할 수 있습니다. [`clutter_container_add()`](http://clutter-project.org/docs/clutter/stable/ClutterContainer.html#clutter-container-add) 함수를 이용하면 자식 액터를 컨테이너에 추가할 수 있습니다.

[ClutterStage](http://clutter-project.org/docs/clutter/stable/ClutterStage.html) 자신도 하나의 컨테이너입니다. 따라서 모든 종류의 자식 액터를 담을 수 있습니다. [ClutterGroup](http://clutter-project.org/docs/clutter/stable/ClutterGroup.html)도 또다른 컨테이너입니다. 스테이지와 달리 그룹은 복수 객체가 가능하고, ClutterGroup이 다시 다른 ClutterGroup을 포함할 수도 있습니다. 그리고, 이 역시 하나의 액터이기 때문에 [`clutter_actor_*()`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html) API를 모두 사용할 수 있습니다.

GTK+ 프로그래밍 경험이 있는 분이라면 이쯤에서, [ClutterActor](http://clutter-project.org/docs/clutter/stable/ClutterActor.html) 객체가 GTK+에서 GtkWidget 객체와 동일한 개념이라는 걸 알 수 있을 겁니다. 그래서 모든 클러터 액터 / 그룹 / 스테이지를 새로 만들면 반환되는 객체 형식은 항상 ClutterActor입니다.

다음 예제는 하나의 그룹에 두 액터를 넣은 다음, 그룹을 변경하면 자동으로 자식 액터에게 적용되는 모습을 보여주고 있습니다.

    #include <clutter/clutter.h>
    #include <stdlib.h>

    int main(int argc, char *argv[])
    {
      ClutterColor stage_color = { 0x00, 0x00, 0x00, 0xff };
      ClutterColor actor_color = { 0xff, 0xff, 0xff, 0x99 };

      clutter_init (&argc, &argv);

      /* 스테이지를 얻어 크기와 색상을 정합니다. */
      ClutterActor *stage = clutter_stage_get_default ();
      clutter_actor_set_size (stage, 200, 200);
      clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);

      /* 스테이지에 그룹을 추가합니다. */
      ClutterActor *group = clutter_group_new ();
      clutter_actor_set_position (group, 40, 40);
      clutter_container_add_actor (CLUTTER_CONTAINER (stage), group);
      clutter_actor_show (group);

      /* 사각형을 그룹에 추가합니다. */
      ClutterActor *rect = clutter_rectangle_new_with_color (&actor_color);
      clutter_actor_set_size (rect, 50, 50);
      clutter_actor_set_position (rect, 0, 0);
      clutter_container_add_actor (CLUTTER_CONTAINER (group), rect);
      clutter_actor_show (rect);

      /* 레이블을 그룹에 추가합니다. */
      ClutterActor *label = clutter_label_new_full ("Sans 9", "Some Text", &actor_color);
      clutter_actor_set_position (label, 0, 60);
      clutter_container_add_actor (CLUTTER_CONTAINER (group), label);
      clutter_actor_show (label);

      /* 그룹을 X축 방향으로 120% 확대합니다. */
      clutter_actor_set_scale (group, 3.00, 1.0);

      /* 그룹을 Z축 기준으로 회전합니다. */
      clutter_actor_set_rotation (group, CLUTTER_Z_AXIS, 10, 0, 0, 0);

      /* 스테이지를 보이게 합니다. */
      clutter_actor_show (stage);

      /* 메인 이벤트 루프를 시작합니다. */
      clutter_main ();

      return EXIT_SUCCESS;
    }

더 자세한 컨테이너 기능은 [clutter\_container\_\*()](http://clutter-project.org/docs/clutter/stable/ClutterContainer.html) API를 참고하시기 바랍니다.

**이벤트 (Events) - 사용자 입력 처리**

ClutterActor 객체는 사용자와 액터가 상호작용할때 발생하는 시그널(signals)을 가지고 있습니다.

-   [`button-press-event`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#ClutterActor-button-press-event): 액터 위에서 마우스 버튼을 누르면 발생
-   [`button-release-event`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#ClutterActor-button-release-event): 액터 위에서 마우스 버튼을 떼면 발생
-   [`motion-event`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#ClutterActor-motion-event): 액터 위에서 마우스 포인터가 움직이면 발생
-   [`enter-event`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#ClutterActor-enter-event): 마우스 포인터가 액터 영역 안으로 들어왔을때 발생
-   [`leave-event`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#ClutterActor-leave-event): 마우스 포인터가 액터 영역 밖으로 나갔을때 발생

예를 들어, 액터를 사용자가 눌렀는지 감지하려면 다음과 같이 시그널 핸들러 콜백을 연결하면 됩니다.

    g_signal_connect (actor, "button-press-event",
                      G_CALLBACK (actor_button_pressed), NULL);

다른 방법으로, 액터의 부모가 되는 ClutterStage에 시그널 핸들러 콜백을 연결한 뒤, [`clutter_stage_get_actor_at_pos()`](http://clutter-project.org/docs/clutter/stable/ClutterStage.html#clutter-stage-get-actor-at-pos)를 이용하여 어떤 액터와 관련이 있는 이벤트인지 확인할 수 있습니다.

성능 최적화를 위해 클러터는 모든 이벤트 시그널을 기본적으로 발생하지 않습니다. 그래서, 스테이지가 아닌 액터로부터 이벤트 시그널을 받으려면 [`clutter_actor_set_reactive()`](http://clutter-project.org/docs/clutter/stable/ClutterActor.html#clutter-actor-set-reactive)를 호출해서 액터가 이벤트를 수신할지 여부를 설정해야 합니다. 움직임 관련 이벤트(motion-event, enter-event, leave-event)를 한꺼번에 모든 액터가 수신할지 여부는 [`clutter_set_motion_events_enabled()`](http://clutter-project.org/docs/clutter/stable/clutter-General.html#clutter-set-motion-events-enabled)를 이용해 설정할 수 있습니다. 이는 마치 GTK+에서 gtk\_widget\_set\_events()를 이용하여 위젯별로 처리할 이벤트를 설정하는 것과 비슷합니다.

이벤트 시그널 핸들러가 발생한 이벤트에 대한 모든 처리를 다 수행한다면 TRUE 값을 반환해서 연결된 다른 핸들러나 다른 액터에게 더 이상 전달되지 않도록 해야 합니다. 반대의 경우 FALSE를 반환해서 다른 핸들러나 다른 액터에게 전달되도록 할 수 있습니다. 클러터는 스테이지가 가장 먼저 이벤트를 수신하도록 하고, 이때 `capture-event` 시그널을 발생합니다. 스테이지가 이벤트를 처리하지 않으면, 계층적으로 자식 액터에게 전달되면서 `capture-event` 시그널을 발생합니다. 만일 어떤 액터도 이 이벤트를 처리하지 않았다면 다시 각각 세부적인 이벤트(가령 `button-press-event`, `key-press-event`)가 자식 액터부터 발생해서 반대로 상위 방향으로 올라가면서 처리될때까지 시그널을 발생합니다. 따라서 처리가 완료되었다면 반드시 TRUE를 반환해야 클러터 어플리케이션 전체가 효율적으로 동작하게 됩니다.

일반적으로 액터는 키 초점(key focus)을 가지고 있을때만 키보드 이벤트를 받지만, [`clutter_grab_pointer()`](http://clutter-project.org/docs/clutter/stable/clutter-General.html#clutter-grab-pointer)와 [`clutter_grab_keyboard()`](http://clutter-project.org/docs/clutter/stable/clutter-General.html#clutter-grab-keyboard)를 이용하여 포인터나 키보드를 강제로 잡게 함으로써(grabbing) 모든 이벤트를 받게 할 수도 있습니다. 예를 들어, 드래그 앤 드롭 기능을 구현할때 마우스 버튼을 누른 다음 포인터가 스테이지 윈도우 바깥으로 나가더라도 마우스 버튼 떼기 이벤트를 받게 할 수 있습니다.

다음 예제는 지금까지 설명한 내용을 보여주기 위해 이벤트 발생시 관련 메시지를 콘솔에 출력합니다.

    #include <clutter/clutter.h>
    #include <stdlib.h>

    static gboolean
    on_stage_button_press (ClutterStage *stage, ClutterEvent *event, gpointer data)
    {
      gint x = 0;
      gint y = 0;
      clutter_event_get_coords (event, &x, &y);

      g_print ("Clicked stage at (%d, %d)n", x, y);

      /* 마우스 버튼 누른 위치에 액터가 있는지 검사합니다.
       * 물론 액터의 시그널에 직접 연결할 수도 있습니다.
       */
      ClutterActor *rect = clutter_stage_get_actor_at_pos (stage, x, y);
      if (!rect)
        return FALSE;

      if (CLUTTER_IS_RECTANGLE (rect))
        g_print ("  A rectangle is at that position.n");

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    static gboolean
    on_rect_button_press (ClutterRectangle *rect, ClutterEvent *event, gpointer data)
    {
      gint x = 0;
      gint y = 0;
      clutter_event_get_coords (event, &x, &y);

      g_print ("Clicked rectangle at (%d, %d)n", x, y);

      /* clutter_main_quit(); */

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    static gboolean
    on_rect_button_release (ClutterRectangle *rect, ClutterEvent *event, gpointer data)
    {
      gint x = 0;
      gint y = 0;
      clutter_event_get_coords (event, &x, &y);

      g_print ("Click-release on rectangle at (%d, %d)n", x, y);

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    static gboolean
    on_rect_motion (ClutterRectangle *rect, ClutterEvent *event, gpointer data)
    {
      g_print ("Motion in the rectangle.n");

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    static gboolean
    on_rect_enter (ClutterRectangle *rect, ClutterEvent *event, gpointer data)
    {
      g_print ("Entered rectangle.n");

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    static gboolean
    on_rect_leave (ClutterRectangle *rect, ClutterEvent *event, gpointer data)
    {
      g_print ("Left rectangle.n");

      return TRUE; /* 다른 핸들러가 이벤트를 더이상 처리못하게 합니다. */
    }

    int main(int argc, char *argv[])
    {
      ClutterColor stage_color = { 0x00, 0x00, 0x00, 0xff };
      ClutterColor label_color = { 0xff, 0xff, 0xff, 0x99 };

      clutter_init (&argc, &argv);

      /* 스테이지를 얻어 크기와 색상을 정합니다. */
      ClutterActor *stage = clutter_stage_get_default ();
      clutter_actor_set_size (stage, 200, 200);
      clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);

      /* 스테이지의 마우스 클릭 시그널에 핸들러를 연결합니다. */
      g_signal_connect (stage, "button-press-event",
                        G_CALLBACK (on_stage_button_press), NULL);

      /* 사각형을 스테이지에 추가합니다. */
      ClutterActor *rect = clutter_rectangle_new_with_color (&label_color);
      clutter_actor_set_size (rect, 100, 100);
      clutter_actor_set_position (rect, 50, 50);
      clutter_actor_show (rect);
      clutter_container_add_actor (CLUTTER_CONTAINER (stage), rect);

      /* 사각형 액터가 이벤트를 받을 수 있게 합니다.
       * 기본적으로 스테이지만 이벤트를 받을 수 있습니다.
       */
      clutter_actor_set_reactive (rect, TRUE);

      /* 사각형 액터의 이벤트 시그널에 핸들러를 연결합니다. */
      g_signal_connect (rect, "button-press-event",
                        G_CALLBACK (on_rect_button_press), NULL);
      g_signal_connect (rect, "button-release-event",
                        G_CALLBACK (on_rect_button_release), NULL);
      g_signal_connect (rect, "motion-event",
                        G_CALLBACK (on_rect_motion), NULL);
      g_signal_connect (rect, "enter-event",
                        G_CALLBACK (on_rect_enter), NULL);
      g_signal_connect (rect, "leave-event",
                        G_CALLBACK (on_rect_leave), NULL);

      /* 스테이지를 보이게 합니다. */
      clutter_actor_show (stage);

      /* 메인 이벤트 루프를 시작합니다. */
      clutter_main ();

      return EXIT_SUCCESS;
    }

다음은 클러터에서 애니메이션 효과를 구현하는데 사용하는 타임라인(Timelines)에 대해 설명할 예정입니다. 대략 12개 장으로 구성된 튜터리얼을 지금까지 5개 장까지 했으니 대략 7개 정도가 더 남았네요. 근데 이제부터는 점점 내용도 많아지고 분량도 많아져서 슬슬 피곤함이...
