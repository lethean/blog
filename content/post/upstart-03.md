---
date: "2006-12-19T00:00:00Z"
tags:
- Linux
- Ubuntu
title: Upstart 0.3
---

어느샌가 Upstart가 0.3 버전으로 올라가더니(우분투 개발버전 feisty), 공식적인 Upstart 홈페이지도 생겼다.(아래 링크 참고) 개발자가 0.3 버전에서 새로 추가된 사항을 정리해 놨으니 나도 한 번 다시 정리해 본다.

<span style="font-weight:bold;">
 작업 만들기(Writing Jobs)</span>

업스타트(Upstart)는 데몬(daemon)의 시작 / 중지 / 감시 작업을 스스로 한다. `start-stop-daemon` 등을 이용하여 개발자가 스스로 관리해야 하는 것과 다르게 프로그램 경로와 인수만 주면 된다.

    exec /usr/bin/dbus-daemon

물론 셸스크립트도 사용할 수 있다.

    script   echo /usr/share/apport/apport > /proc/sys/kernel/crashdump-helperend script

데몬이 시작(start)되기 전/후(pre/post)와 중지(stop)되기 전/후(pre/post)에 원하는 작업도 할 수 있다.

    pre-start script   mkdir -p /var/run/dbus   chown messagebus:messagebus /var/run/dbusend script

    post-start script   # wait for listen on port 80   while ! nc -q0 localhost 80 /dev/null 2>&1; do       sleep 1;   doneend script

    post-stop script   rm -f /var/run/dbus/pid

    pre-stop script   # disable the queue, wait for it to become empty   fooctl disable   while fooq >/dev/null; do        sleep 1   doneend script

여기서 `script` 대신 `exec`를 사용하면 스크립트(script) 대신 바이너리를 실행할 수도 있다.

<span style="font-weight:bold;">
 이벤트(Events)</span>

0.3 버전에서 이벤트는 더 정교해졌다고 하는데, 단순히 시스템이 보내는 이벤트 이름 뿐 아니라 인수(arguments)와 환경변수도 전달할 수 있다.

    initctl emit network-interface-up eth0 -DIFADDR=00:11:D8:98:1B:37

이 명령은 이벤트와 모든 결과를 출력하고 이벤트가 완전히 처리될때까지 끝나지 않게 한다. 이와 같이 전달된 인수는 다음처럼 스크립트에서 사용할 수 있다.

    start on network-interface-upscript   [ $1 = lo ] && exit 0   grep -q $IFADDR /etc/network/blacklist && exit 0   # etc.end script

아니면 다음과 같이 `start on` 과 `stop on` 구문에서 직접 일치하는지 검사할 수도 있다.

    start on block-device-added sda*

작업의 상태 변화로 인한 이벤트도 변경되었다. 이전에는 작업이나 이벤트 모두 같은 이름공간(namespace)를 공유했는데, 혼동을 일으킬 뿐 아니라 실제로 작업 이름을 이용하는 이벤트 이름은 문제를 일으키기도 한다.

이렇게 발생한 두개의 주요 이벤트는 간단하게 `started` 와 `stopped` 로 칭한다. 이를 통해 작업이 완전하게 로드되어 실행되고 있거나, 반대로 완전히 종료됨을 알 수 있다. 작업 이름은 이 이벤트의 인수로 받게 된다.

    start on started dbus

`started` 이벤트는 `post-start` 작업이 끝나기 전에는 발생하지 않는다. 따라서 `post-start` 작업은 데몬에 아직 연결할 수 없는 다른 작업들이 시작하는 것을 지연할 수 있다.

같은 식으로 `stopped` 이벤트는 `post-stop` 작업이 끝날때까지 발생하지 않는다.

작업이 발생시키는 다른 두개의 이벤트는 약간 특별하다. `starting`과 `stopping`이 그것인데, 이 이벤트가 처리될때까지는 작업이 시작하거나 중지하지 못하게 한다. 즉, 데이터베이스 서버가 멈추었을때 해야할 작업이 있는데, 그러나 실제로 종료되기 전에 처리해야 한다면 다음과 같이 사용할 수 있다.

    start on stopping mysqlexec /usr/bin/backup-db.py

MySQL이 백업이 끝나기 전까지 종료되지 않을 것이다.

이 런 경우는 특히 다른 데몬에 의존하는 데몬일 경우 유용하다. 예를 들어 HAL은 DBUS를 필요로 하는데, DBUS가 실행되기 전에는 시작하면 안되고 DBUS는 HAL이 끝나기 전에 멈추면 안된다. 따라서 HAL 작업은 다음과 같다.

    start on started dbusstop on stopping dbus

같은 식으로 Tomcat이 설치되어 있다면 Apache는 Tomcat이 실행되기 전에는 시작하면 안되고, Tomcat는 Apache가 종료될때까지 멈추면 안된다. 따라서 Tomcat 작업은 다음과 같다.

    start on starting apachestop on stopped apache

<span style="font-weight:bold;">실패(Failure)</span>

항 상 모든게 부드럽게 흘러가는 게 아니므로 가끔 작업이 수행이 태스크가 실패할 수도 있고 데몬이 죽을 수도 있다. upstart는 죽은(crashed) 데몬을 자동으로 재시작하게 할 수도 있고, 다른 작업에게 이를 알려줄 수도 있다. stopping 과 stopped 이벤트에 추가되는 failed 인수가 그것이다.

    start on stopped typo failedscript  echo "typo failed again :-(" | mail -s "type failed" rootend script

이벤트 실패로 인해 어떤 작업이 시작되거나 멈추었다면, 이벤트 자체가 실패했다는 것을 발견할 수도 있다.

    start on network-interface-up/failed

<span style="font-weight:bold;">
 상태(States)</span>

네트웍 인터페이스를 구성하거나 블럭 장치를 검사하고 마운트하는 작업은 대개 이벤트의 결과로서 동작하는 반면, 서비스는 조금 더 복잡하다.

서비스는 특정 이벤트가 발생했을때가 아니라 대개 시스템이 어떤 상태에 있을 경우 동작해야 한다. 따라서 upstart는 변화를 정의하는 이벤트를 참조하여 복잡한 시스템 상태를 설명할 수 있도록 한다.

예를 들어 많은 서비스가 파일시스템이 마운트되어 있을 경우에만 동작해야 하고, 최소 하나의 네트웍 디바이스가 올라와 있어야 한다. 이러한 시기가 시작되고 끝나는 것을 가리키는 이벤트를 이용해 조합하면 다음과 같이 사용할 수 있다.

    from fhs-filesystem-mounted until fhs-filesystem-unmountedand from network-up until network-down

`until` 연산자는 두 이벤트 사이트의 기간을 정의하고, `and` 연산자는 두 기간을 동시에 적용하도록 한다.

디스플레이 매니저가 실행되고 있는 경우에만 동작하려면 다음과 같이 기술할 수 있다.

    from started gdm until stopping gdmor from started kdm until stopping kdm

네트웍 인터페이스가 올라온뒤 bind9이 시작하기 전에 실행하고 싶다면 다음과 같이 기술하면 된다.

    on network-interface-up and from startup until started bind9

이처럼 "복합 이벤트 구성"은 어느 작업 파일에나 올 수 있다. 그리고 어느 작업 파일이나 다른 작업에 대한 리퍼런스로 동작할 수 있다. 다른 작업과 동시에 시작하고 멈출 수도 있다.

    with apache

`exec`나 `script` 절을 생략하면, 다른 작업이 리퍼런스로 사용할 수 있도록 상태만 정의한다. 그런 식으로 `multiuser` 상태 역시 단순히 상태를 정의하는 작업 파일이다.

보너스로 덧붙이자면, 이러한 상태들도 `pre-start`, `post-stop` 등을 응용할 수 있다.

참고:

1.  [Upstart 공식 홈페이지](http://upstart.ubuntu.com/) - 언제 생겼지?
2.  [Upstart 0.3](http://www.netsplit.com/blog/articles/2006/12/14/upstart-0-3) - 개발자 블로그

