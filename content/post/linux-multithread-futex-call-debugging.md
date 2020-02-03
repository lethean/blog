---
date: "2006-12-21T00:00:00Z"
tags:
- glibc
- Kernel
- Linux
title: 리눅스 멀티쓰레드(futex) 호출 디버깅
---

리눅스 커널 2.6 이후, 즉 최신 리눅스 환경에서 어플리케이션을 개발할때 멀티쓰레드인 경우 데드락이나 블럭킹 현상을 디버깅하려면 매우 골치가 아프다. strace나 gdb 백트레이스를 추적하다보면 결국 `futex()` 시스템콜을 호출하고, 여기서 멈춰있는 경우가 대부분이다. 이 경우 대부분 이 시스템콜은 pthread 라이브러리가 호출하는 것이다. 이 경우 정확히 어떤 공유 라이브러리와 연관이 있는지 확인하기 힘든데 [여기](http://galathilion.livejournal.com/91051.html) 블로그에 달린 댓글을 보면 다음 2가지 방법을 권하고 있다.

1.  `export LD_ASSUME_KERNEL=2.4.1`식으로 커널 버전을 명시하여 glibc가 NPTL 대신 futex() 를 사용하지 않는 이전 LinuxThread 방식을 사용하도록 하여 디버깅하기
2.  ltrace 프로그램을 이용하여 라이브러리 호출 감시하기

하지만, 뭐 그런다고 쉽게 풀리지는 않는게 멀티쓰레드 프로그래밍인지라...

참고:

1.  [Jeremy Kolb: futex headaches](http://galathilion.livejournal.com/91051.html)

