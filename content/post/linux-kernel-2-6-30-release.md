---
date: "2009-06-12T00:00:00Z"
tags:
- Kernel
- Linux
title: 리눅스 커널 2.6.30 릴리스
---

어김없이 [리눅스 커널 2.6.30 버전](http://lwn.net/Articles/336506/)이 나왔습니다. 에휴...

20대에는 릴리스마다 변경된 커널 코드를 읽어 보기도 했는데, 30대 초반 들어서는 기술 분석 문서를 읽는 것도 벅차더니, 30대 중반을 달리고 있는 요즘은 어디 잘 요약해 놓은데 없나 찾아 다니기만 하는 것 같습니다. 물론 갈수록 게을러지는 게 가장 큰 원인이겠지만, 매 릴리스마다 변경되는 기술의 폭이 커지는 것도 하나의 변명이 될 수 있지 않을까 생각합니다. 게다가 요즘은 초창기와 다르게 릴리스 전에 많은 전문가들이 먼저 시험해 보고 잘 정리해 놓으니까, 직접 API를 사용해 보거나 코드를 확인하는 건 정말 업무에 사용하게될 때 뿐인 것 같습니다. 어찌되었든, 중요한 변경 사항은 놓치지 않고 확인해놔야 먹고 사는데 지장이 없을 것 같아 제가 관심 있는 부분만 정리해 봅니다. 물론 더 자세한 내용은 [커널 뉴비 사이트](http://kernelnewbies.org/Linux_2_6_30)를 보시면 지나치게 잘 정리되어 있으니 놓치지 마시길!

**파일시스템 잔치 : NILFS2, POHMELFS, DST, EXOFS, EXT4, EXT3, ...**

일본 NTT Lab에서 개발한 NILFS2 파일시스템이 정식으로 커널에 포함되었습니다. 아직 개선이 조금 더 필요하지만 SSD 저장장치에서 엄청난 성능을 뿜어낸다고 하는군요. 아주 오래전부터 공식 커널 밖에서 개발되던 로그-구조(Log-structured) 방식 파일시스템이 드디어 실생활에 사용될 수 있을지 조금 기대가 됩니다. 참고로 로그-구조란, 로그 파일에 로그 메시지가 계속 추가되듯이, 기존 내용을 덮어쓰지 않고 추가 / 수정된 부분만 계속 새로운 공간에 배치하기 때문에 공간이 허락하는 한 무한대 롤백 / 스냅샷이 가능합니다. 그리고 이러한 특성 때문에 쓰기 제한이 있는 SSD 매체에 적합한 파일시스템이라는 얘기도 가능합니다.

오랫동안 [커널 플래닛](http://planet.kernel.org/)에서 개발 과정을 지켜봤던 POHMELFS 파일시스템도 포함되었습니다. 지금까지 존재하는 어떤 네트웍 파일시스템보다 성능이 더 좋다고 하는데, 써 볼 기회가 없는게 아쉽네요. 또한 NFS / AFS 등의 성능 개선을 이끌어낸 FS-Cache 캐싱 파일시스템도 추가되었다고 합니다. DST, EXOS 파일시스템은 잘 모르는 거라서...

EXT3 / EXT4 파일시스템에서 fsync() 호출에 대한 반응속도(latency)도 많은 논의 끝에(?) 개선되었고, EXT3 파일시스템에서 relatime 옵션이 기본으로 켜지게 되었습니다. 더불어 EXT4 파일시스템도 많이 안정화된 것처럼 보입니다.

아무튼, 요즘 리눅스 커널은 BTRFS, EXT4, UnionFS 등을 포함한 차세대 파일시스템들이 EXT3 다음 자리를 놓고 치열하게 경쟁하는 덕분에, 개발자들 공부 많이 하게 해 주는군요...

**쓰레드 방식 인터럽트 핸들러 지원**

솔라리스나 실시간 커널에서는 이미 몇십년 전부터 사용하고 있는 방식이지만, 여러 정치적인 이유로 실시간 커널 브랜치에만 있던 [쓰레드 방식 인터럽트 핸들러 기능](http://lwn.net/Articles/302043/)이 이제서야 메인 커널에 추가되었습니다. 물론 인터럽트 핸들러가 실행이 길어질수록 시스템의 다른 부분이 아무 일도 할 수 없기 때문에 리눅스 커널은 아주 오래전부터 상단/하단 부분(top/bottom half)이나 태스크릿(tasklet)을 비롯해 많은 메카니즘을 제공함으로써 커널 레이턴시(latency)를 훌륭하게 보장하고 있지만, 아무래도 실시간 시스템 하는 사람들에겐 부족했던 모양입니다.

기존 방식으로 동작하려면 지금과 동일하게 request\_irq() 함수를 사용하면 되고, 각각의 핸들러가 별도 커널 쓰레드로 동작하게 하려면 request\_threaded\_irq() 함수를 이용해 등록하면 됩니다. 두번째 방식은 핸들러 함수(quick\_check\_handler)가 하나 더 있는데, 인터럽트가 발생하면 이 핸들러가 먼저 실행된 후 인터럽트가 자신의 것이 맞는지 여부와, 그렇다면 그에 따라 인터럽트 핸들러 쓰레드를 깨울지, 직접 인터럽트 문맥에서 실행할 지 등을 결정하는 리턴값을 돌려주면 그에 따라 인터럽트 핸들러 쓰레드가 동작하는 방식입니다. 따라서 이로 인해 기존 태스크릿(tasklet)은 사라질 수도 있다고 합니다.

**기타**

커널 부팅 속도를 빠르게 하기 위해 한번에 하나씩 장치를 스캔하지 않고, 한꺼번에 장치 스캔 요청을 보낸 뒤 나중에 [비동기(async)로 응답을 받아 처리할 수 있는 API](http://lwn.net/Articles/314808/)도 추가되었습니다.

메모리 관리자는 또 개선되어, 커널 메모리 추적자(kmemtrace)라는 녀석도 추가되어 kmalloc(), kfree(), kmem\_cache\_alloc() 등과 같은 메모리 관련 API 추적 정보를 사용자 영역 프로세스에게 전달해 분석에 사용할 수 있게 되었습니다. 더불어 [DMA API 디버깅을 위한 기능](http://lwn.net/Articles/308237/)도 추가되었습니다.

X86\_32 아키텍쳐에서 커널 스택 보호 기능도 추가되고, 이제 더 이상 zImage 형식은 지원하지 않게 되었고, /sys 밑에 새로운 항목들이 추가되고, 수많은 디바이스 드라이버가 업데이트되고 추가되었고...

아무튼, 오늘은 여기까지!