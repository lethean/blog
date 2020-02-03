---
date: "2007-07-25T00:00:00Z"
tags:
- Linux
- Ubuntu
title: DBus or Upstart
---

Dbus를 이용해 이제는 시스템 데몬과 같은 프로그램까지 실행할 수 있게 될 것 같다.([Dbus System Activation is upstream](http://hughsient.livejournal.com/31169.html) 참고) 디자인 문서를 보니, 다음과 같이 서비스 파일을 정의하면 해당 메시지가 발생했을때 해당 서버가 동작하는 방식이다.

    [D-BUS Service]
    Name=org.me.test
    Exec=/usr/sbin/dbus-test-server.py
    User=ftp

다음과 같이 직접 실행할 수도 있다.

    dbus-send --system --print-reply 
     --dest=org.freedesktop.DBus 
     /org/freedesktop/DBus 
     org.freedesktop.DBus.StartServiceByName 
     string:org.freedesktop.Hal uint32:0

이렇게 되면 현재 Ubuntu 시스템의 기반이 되는 upstart나 기존의 sysvinit 등과 같은 시스템 초기화 시스템도 불필요해질 수있다고 하는데, 단순히 메시지 기반 병렬 실행 기능만으로는 서비스간 의존성이나 초기화 과정의 많은 예외처리까지는 어렵지 않을까 싶다.
