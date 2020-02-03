---
date: "2012-07-02T00:00:00Z"
tags:
- GTK+
- Xorg
title: X 윈도우 마우스 포인터 장벽(barrier)
---

그놈3 데스크탑 환경을 사용할때 불편했던 점 중 하나는,  프로그램을 실행하는 등의 창 작업을 위해 화면 상단 왼쪽 구석으로 마우스를 이동했을때 듀얼 모니터에서 마우스가 미끌어져 버리는 현상이었습니다. 그런데, 어느 날부터인가 이 현상, 즉 마우스를 화면 구석으로 이동해도 마우스가 다음 모니터로 미끌어져 넘어가는 현상이 발생하지 않았습니다. 제가 '어느 날'이라는 표현을 사용한 이유는, [아치 리눅스로 이전](/2011/02/21/migrated-to-arch-linux/)한 이후로 아직까지 한 번도 시스템을 재설치하지 않고, 생각날 때마다 최소 2~3일에 한 번씩 패키지를 업그레이드하는 습관 때문입니다.

그러다가 최근 [LWN.net의 X11R7.7 릴리스 기사](http://lwn.net/Articles/500747/)에서 이런 내용을 읽게 되었습니다.

> **Pointer barriers** were added by X Fixes extension Version 5.0. Compositing managers and desktop environments may have UI elements in particular screen locations such that for a single-headed display they correspond to easy targets, for example, the top left corner. For a multi-headed environment these corners should still be semi-impermeable. Pointer barriers allow the application to define additional constraint on cursor motion so that these areas behave as expected even in the face of multiple displays.

즉, X Fixes 확장 기능 5.0 버전에 포인터 장벽(?)이라는게 추가되었는데, 어플리케이션이 커서 움직임에 제한을 더할 수 있도록 했다는 겁니다. 그리고 이를 이용하면 바로 정확하게 제가 경험한 것과 같은 멀티 모니터에서의 구석 마우스 미끄러짐 현상을 없앨 수 있다는 점도 부연하고 있습니다.

사실 비슷한 문제가 제가 회사에서 개발 중인 프로그램에서도 발생하고 있었기 때문에 이 기능에 관심이 안 갈 수가 없었습니다. 그래서 조금 더 정확하게 확인하기 위해 그놈 셸 소스 코드를 조사했더니 아니나 다를까, 패널 박스 크기가 변경될때마다("allocation-changed") 호출되는 [`_updatePanelBarriers()`](http://git.gnome.org/browse/gnome-shell/tree/js/ui/layout.js#n171) 함수가 그 역할을 하고 있습니다. ([2011년 7월 25일에 작성된 코드](http://git.gnome.org/browse/gnome-shell/commit/js/ui/layout.js?id=021d3dadbb63676c1ac9496ecbb0b80ce2eb6dfe)군요...)

```javascript
_updatePanelBarriers: function() {
    if (this._leftPanelBarrier)
        global.destroy_pointer_barrier(this._leftPanelBarrier);
    if (this._rightPanelBarrier)
        global.destroy_pointer_barrier(this._rightPanelBarrier);

    if (this.panelBox.height) {
        let primary = this.primaryMonitor;
        this._leftPanelBarrier =
            global.create_pointer_barrier(primary.x, primary.y,
                                          primary.x, primary.y + this.panelBox.height,
                                          1 /* BarrierPositiveX */);
        this._rightPanelBarrier =
            global.create_pointer_barrier(primary.x + primary.width, primary.y,
                                          primary.x + primary.width, primary.y + this.panelBox.height,
                                          4 /* BarrierNegativeX */);
    } else {
        this._leftPanelBarrier = 0;
        this._rightPanelBarrier = 0;
    }
}
```

위 자바스크립트 코드가 호출하는 [실제 C 함수 코드](http://git.gnome.org/browse/gnome-shell/tree/src/shell-global.c#n1010)는 다음과 같습니다.

```c
/**
 * shell_global_create_pointer_barrier:
 * @global: a #ShellGlobal
 * @x1: left X coordinate
 * @y1: top Y coordinate
 * @x2: right X coordinate
 * @y2: bottom Y coordinate
 * @directions: The directions we're allowed to pass through
 *
 * If supported by X creates a pointer barrier.
 *
 * Return value: value you can pass to shell_global_destroy_pointer_barrier()
 */
guint32
shell_global_create_pointer_barrier (ShellGlobal *global,
                                     int x1, int y1, int x2, int y2,
                                     int directions)
{
#if HAVE_XFIXESCREATEPOINTERBARRIER
  return (guint32)
    XFixesCreatePointerBarrier (global->xdisplay,
                                DefaultRootWindow (global->xdisplay),
                                x1, y1,
                                x2, y2,
                                directions,
                                0, NULL);
#else
  return 0;
#endif
}

/**
 * shell_global_destroy_pointer_barrier:
 * @global: a #ShellGlobal
 * @barrier: a pointer barrier
 *
 * Destroys the @barrier created by shell_global_create_pointer_barrier().
 */
void
shell_global_destroy_pointer_barrier (ShellGlobal *global, guint32 barrier)
{
#if HAVE_XFIXESCREATEPOINTERBARRIER
  g_return_if_fail (barrier > 0);

  XFixesDestroyPointerBarrier (global->xdisplay, (PointerBarrier)barrier);
#endif
}
```

`XFixesCreatePointerBarrier()` / `XFixesDestroyPointerBarrier()` 함수에 대한 더 자세한 사용법을 확인하기 위해 [XFIXES 공식 프로토콜 문서](http://www.x.org/releases/X11R7.7/doc/fixesproto/fixesproto.txt)를 확인해 보니 마지막에 다음과 같은 API 설명이 있습니다.

```
12. Pointer Barriers

...

12.1 Types

    BARRIER:    XID

    BarrierDirections

        BarrierPositiveX:       1 << 0
        BarrierPositiveY:       1 << 1
        BarrierNegativeX:       1 << 2
        BarrierNegativeY:       1 << 3

12.3 Requests

CreatePointerBarrier

        barrier:            BARRIER
        drawable:           DRAWABLE
        x1, y2, x2, y2:         INT16
        directions:         CARD32
        devices:            LISTofDEVICEID

    Creates a pointer barrier along the line specified by the given
    coordinates on the screen associated with the given drawable.  The
    barrier has no spatial extent; it is simply a line along the left
    or top edge of the specified pixels.  Barrier coordinates are in
    screen space.

    The coordinates must be axis aligned, either x1 == x2, or
    y1 == y2, but not both.  The varying coordinates may be specified
    in any order.  For x1 == x2, either y1 > y2 or y1 < y2 is valid.
    If the coordinates are not valid BadValue is generated.

    Motion is allowed through the barrier in the directions specified:
    setting the BarrierPositiveX bit allows travel through the barrier
    in the positive X direction, etc.  Nonsensical values (forbidding Y
    axis travel through a vertical barrier, for example) and excess set
    bits are ignored.

    If the server supports the X Input Extension version 2 or higher,
    the devices element names a set of master device to apply the
    barrier to.  If XIAllDevices or XIAllMasterDevices are given, the
    barrier applies to all master devices.  If a slave device is named,
    BadDevice is generated; this does not apply to slave devices named
    implicitly by XIAllDevices.  Naming a device multiple times is
    legal, and is treated as though it were named only once.  If a
    device is removed, the barrier continues to apply to the remaining
    devices, but will not apply to any future device with the same ID
    as the removed device.  Nothing special happens when all matching
    devices are removed; barriers must be explicitly destroyed.

    Errors: IDChoice, Window, Value, Device

DestroyPointerBarrier

        barrier:            BARRIER

    Destroys the named barrier.
```

포인터 장벽은 반드시 화면 구석에서만 사용할 수 있는 게 아니라 화면 어느 곳에나 생성할 수 있으며, 장벽 생성시 지정한 방향(direction)으로만 마우스 커서가 이동할 수 있도록 허용합니다. 다시 말해 마우스 커서가 반대 방향으로는 장벽을 넘어갈 수 없게 합니다.방향과 함께 장벽의 영역 좌표를 지정해야 하는데, 예를 들어 왼쪽에서 오른쪽이라면 Y 좌표값만 다르고 X 좌표값을 동일하게 지정해야 합니다. 즉, 세로로 장벽 선을 그리면 됩니다. 그런데, 사실 화면 구석에서는 원하는 대로 동작하는데, 화면 임의의 위치에 포인터 장벽을 생성해 보면 마우스 커서의 대각선 움직임 등은 허용하기 때문에 아주 정확하게 원하는 대로 동작하지 않을 수도 있습니다.

참고로 상위 툴킷에서 X 윈도우 API 호출에 사용하는 Display, Window 핸들을 얻으려면, Clutter의 경우 [`clutter_x11_get_default_display()`](http://developer.gnome.org/clutter/stable/clutter-X11-Specific-Support.html#clutter-x11-get-default-display) / [`clutter_x11_get_stage_window()`](http://developer.gnome.org/clutter/stable/clutter-X11-Specific-Support.html#clutter-x11-get-stage-window) 또는 [`clutter_x11_get_root_window()`](http://developer.gnome.org/clutter/stable/clutter-X11-Specific-Support.html#clutter-x11-get-root-window) 함수를 이용하면 됩니다. GTK+ 역시 GDK 관련 API를 뒤져 보시면 됩니다. ;)
