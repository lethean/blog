---
date: "2008-07-16T00:00:00Z"
tags:
- Kernel
- Linux
title: 리눅스 커널 메모리 검사 기능
---

리눅스 커널 2.6.26 릴리스에는 메모리 검사 기능이 추가되었습니다. 기존에 많이 사용하는, 우분투 리눅스의 경우 grub 부트 메뉴에서 선택해서 실행할 수 있는 [Memtest86+](http://www.memtest.org/) 프로그램처럼 많은 기능이 있는 건 아니지만, 가끔 간단한 메모리 검사가 필요한 경우 요긴하게 사용할 수 있을 것 같습니다.

아직 X86 플랫폼만 지원하며, 사용하려면 커널 컴파일시 CONFIG\_MEMTEST\_BOOTPARAM 설정을 선택해야 하고, 부팅시 'memtest' 인수를 넘겨주면 동작합니다.
