---
date: "2009-09-17T00:00:00Z"
tags:
- GLib
- GTK+
- MacOSX
title: GLib 메인루프와 애플 GCD의 libdispatch
---

GTK 메일링 리스트에 [흥미있는 포스트](http://mail.gnome.org/archives/gtk-devel-list/2009-September/msg00036.html)가 있어서 정리해 봅니다.

스노우 레오파드 출시와 더불어 오픈 소스로 공개되면서 요즘 한창 이슈가 되고 있는 애플의 [GCD(Grand Central Dispatch)](http://arstechnica.com/open-source/news/2009/09/apple-opens-gcd-challenges-impede-adoption-on-linux.ars)의 일부인 [libdispatch](http://libdispatch.macosforge.org/) 라이브러리와 GLib 메인루프를 비교한 내용인데, 정리해 보면 다음과 같습니다.

libdispatch는 세 종류의 실행 큐를 제공하는데 다음과 같습니다.

1.  <span style="background-color:#ffffff;">메인 큐(main queue) : GLib의 메인 이벤트 루프와 동일</span>
2.  <span style="background-color:#ffffff;">전역 큐(global queue) : 쓰레드풀(thread pool) 방식으로 동작하며 모든 작업(job)은 이 큐로 보내진 다음 임의의 쓰레드에서 비동기(asynchronously) 실행됩니다</span>
3.  <span style="background-color:#ffffff;">개인 큐(private queue) : 이 큐의 작업은 순서대로 실행됩니다.</span>

개인 큐와 메인 큐는 전역 큐의 쓰레드로 동작하는데, 이 방식은 GLib에서 GSource(g\_idle / g\_timeout / etc) 콜백함수를  다른 쓰레드에서 처리하게 위해 GMainLoop + GThreadPool 조합을 사용하는 것보다 사용자에게 더 편한 것 같습니다. 물론 libdispatch는 GCC를 확장한 블럭(blocks)이라는 문법을 이용하므로 사용하려면 GCC 패치가 필요합니다. 참고로, 블럭(blocks)은 함수형 언어나 스크립트 언어에서 지원되는 일종의 익명(anonymous) 함수인데, GLib의 GClosure와 비슷한 역할을 합니다. 예를 들어 C 언어에서는 특정 이벤트나 시그널이 발생할때 처리를 하려면 함수를 정의하고 이 함수를 콜백함수로 등록해야 하는데, 블럭(blocks)을 사용하면 함수를 따로 정의하지 않고 코드 블럭을 직접 시그널에 연결할 수 있는 셈입니다.

그런데 이 포스트에 달린 댓글을 보면 GLib을 이용해 GCD와 비슷한 역할을 하는 라이브러리인 [iris](http://git.dronelabs.com/iris)와 [catalina](http://git.dronelabs.com/catalina) 라이브러리도 소개하고 있군요. 어쩌면  얼마 안있어 GCD를 참고한 라이브러리나 혹은 새로운 GLib API가 추가될 지도 모른다고 예측해 봅니다. 워낙 오픈소스 쪽은 부지런한 사람이 많아서 말이죠... :)

얼마전에는, 작은 웹서버를 띄우고 웹페이지에서 실행중인 GTK 어플리케이션의 모든 GObject 객체를 보여주는 것은 물론 바로 객체 속성도 수정할 수 있는 [gtkwebd 유틸리티가 소개](http://mail.gnome.org/archives/gtk-list/2009-September/msg00044.html)되었고, 구글 어스나 나사의 월드윈드처럼 3차원으로 지구 지도를 보여주도록 도와주는 [AWether 라이브러리도 공개](http://mail.gnome.org/archives/gtk-list/2009-September/msg00050.html)되었습니다. 물론 [이전 포스트](/2009/02/03/location-aware-softwares-in-linux/)에서 다룬 [libchamplain](http://projects.gnome.org/libchamplain/) 라이브러리에 더 관심이 많아 그다지 흥미롭지는 않았는데, 모르고 있던 [Blue Marble NG](http://earthobservatory.nasa.gov/Features/BlueMarble/), [SRTM 30 Plus](http://topex.ucsd.edu/WWW_html/srtm30_plus.html) 등과 같은 무료 지도 데이터 정보를 알 수 있게 되어 고마울 따름입니다.

아무튼 이쪽 세상은 끊임없이 상용 코드를 벤치마킹하고 모방하면서 조금씩 계속 진화하고 있습니다.
