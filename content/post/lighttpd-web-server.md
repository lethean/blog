---
date: "2007-04-08T00:00:00Z"
tags:
- Web
title: lighttpd 웹 서버
---

'[The lighttpd Web Server'](http://www.onlamp.com/pub/a/onlamp/2007/04/05/the-lighttpd-web-server.html "The lighttpd Web Server")라는 글을 읽다 보니 [lighttpd](http://www.lighttpd.net/ "lighttpd") 웹서버가 물건 취급을 받을만 하다는 생각이 든다. 전세계 웹서버 통계에서 Apache, IIS, Unknown(?), iPlanet 다음으로 5번째 점유율을 차지하고, YouTube, Wikipedia 등과 같은 굵직한 사이트에서 메인 서버로 사용할 만큼 검증받은 웹서버라는 점만으로도 일단 흥미를 가질만 하다.

최신 리눅스 커널에서 지원하는 epoll, sendfile, aio 등과 같은 API를 충분히 활용하여 멀티 쓰레드 방식보다 더 좋은 성능을 낼 수 있도록 구현한 점도 매력적이지만, Apache가 지원하는 대부분의 기능을 그대로 지원한다는 점도 눈여겨볼 만 하다. 다중 사용자 인증 / 접근 권한, 대역폭 제한, 연결 제한, 프록시, 가상 호스팅 등은 물론 FastCGI 방식의 PHP까지도 거뜬히 소화한다.

하지만 무엇보다도 마음에 드는 건 다양한 플랫폼 지원과, 작은 실행 크기(바이너리 이미지 + 메모리)이다. 현재 개발중인 제품 중에서 웹서버를 탑재한 것 모두를 lighttpd 서버로 교체하고 싶은 생각이 들 정도다. 단순하다는 이유만으로 성능도 안좋고, 기능도 미약한 boa, busybox의 httpd 데몬이여 이제 안녕~

물론 여러가지 사용되는 라이브러리가 임베디드 환경에 맞추려면 조금 어려울 수도 있지만, 프로젝트의 로드맵이 지향하는 바도 그렇고 앞으로가 더욱 더 기대되는 프로젝트이다.
