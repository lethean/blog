---
date: "2009-02-03T00:00:00Z"
tags:
- Clutter
- GTK+
- Linux
title: 리눅스에서 위치 인식 소프트웨어
---

'[Location-aware software comes to the Linux platform](http://arstechnica.com/open-source/news/2009/01/location-awareness-comes-to-the-linux-platform.ars)' 글에서 모바일 위치 정보와 지도 렌더링을 오픈소스 리눅스 플랫폼에서 처리하는 방법을 정리해 놓았는데, 나중을 위해 간략하게 정리해 보았습니다.

가장 먼저 소개하는 프레임웍은 [GeoClue](http://www.freedesktop.org/wiki/Software/GeoClue)입니다. GeoClue는 로컬에 장착된 GPS 장치 뿐 아니라 GSMLoc 등과 같은 여러가지 위치 정보를 일종의 표준화된 형식으로 D-Bus를 통해 알려줍니다. (GSMLoc은 이 글을 통해 처음 알게된 건데 GSM 방식 휴대폰의 무선기지국 위치를 측정해 현재 휴대폰의 위치를 판단하는 기법이라고 합니다) GeoClue는 이미 Glib 기반 C API도 제공하고 있기 때문에 이를 이용한 위치 정보 어플리케이션을 개발하면 여러가지 GPS 장치 뿐 아니라 GeoClue 방식을 따르는 다양한 위치 정보를 이용할 수 있다는 장점이 있습니다.

이렇게 얻어진 위치 정보를 표시하기 위해 가장 관심받고 있는 라이브러리는 [libchamplain](http://blog.pierlux.com/projects/libchamplain/en/)입니다. OpenStreetMap이나 OpenAerialMap 같은 인터넷 지도 서버를 이용하면서, 렌더링에는 [Clutter](http://www.clutter-project.org/)라이브러리를 사용하지만 GTK+ 위젯 기반이기 때문에 쉽게 그놈 / GTK+ 어플리케이션에도 사용이 가능합니다. 이미 그놈 프로젝트의 기본 이미지 보기 프로그램인 EOG에도 플러그인이 추가되었고, 인스턴트 메신저에도 적용되고 있습니다. (예를 들어 iPhone이나 최신 디지털 카메라는 촬영시 GPS 정보를 이미지에 저장하는데, 이를 읽어들여 이미지를 볼때 이미지를 촬영한 장소의 지도 이미지를 함께 보여줍니다. 또한 메신저 친구 목록에서 친구를 클릭하면 현재 친구가 위치한 장소가 어디인지 알려주고 지도에 표시해 주기도 하는 거죠. 허락없이 무단링크한 다음 스크린샷을 확인해 보시길...)

![](/figures/eog-champlain.png "EOG에서 champlain 플러그인 사용 화면")

참고로, 이 소프트웨어들은 일반 데스크탑이나 서버 뿐 아니라 휴대폰, PDA 등과 같은 모바일 장치에서도 사용할 수 있습니다. 따라서 앞으로는 웹서비스 뿐 아니라 일반 어플리케이션도 위치 정보와 지도 서비스를 활용해 계속 진화하지 않을까 예측해 봅니다.
