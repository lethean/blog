---
date: "2011-02-21T00:00:00Z"
tags:
- ArchLinux
- Linux
title: 아치 리눅스(Arch Linux)로 갈아타다
---

1996년부터 리눅스를 사용하면서 [슬랙웨어](http://slackware.com/), [레드햇](http://www.redhat.com/), [데비안](http://www.debian.org/)을 거쳐 [우분투](http://www.ubuntu.com/) 배포판을 사용해 오다가 최근 [아치 리눅스](http://www.archlinux.org/)로 갈아 탔습니다. 우분투가 여러 이유로 편하긴 하지만, 어느 순간부터 점점 무거워지다가(mono, python 기반 기본 프로그램 때문?), 별로 사용하지 않고 원하지도 않는 기능들이 추가되는가 싶더니만(Ubuntu One 등) 급기야 2011.4 버전부터 그놈 3(GNOME 3) 프로젝트의 공식 셸(GNOME Shell) 대신 자체 유나이티(Unity) 셸을 채택한다고 하는 순간, 아 이제 우분투와 이별의 순간이 다가왔구나 깨달았습니다. 그놈 셸이 유나이티보다 UX 측면에서 완성도가 더 높다고 생각하고 있었고, 개인적으로 더 선호하는 스타일이었기 때문이기도 하지만, 역시 상업 회사가 이끄는 배포판은 장점도 많지만 이런 단점도 있을 수 있다는 걸 다시 한 번 깨달았기 때문이기도 합니다. 물론 지금까지 우분투에 불만이 없었던 건 아니지만, 대부분 다른 장점에 의해 묻혀버렸는데, 이번 일을 계기로 쌓였던 불만이 한꺼번에 노출된 것 같기도 합니다.

그렇다고 데비안이나 페도라, 젠투 배포판으로 가기에는 별로 재미가 없을 것 같아서 여기 저기 확인해보다가 아치 리눅스를 선택하게 되었습니다. 여러가지 이유가 있지만, 32비트 버전의 경우 패키지 바이너리가 i686에 최적화되어 있고, 패키지 시스템이 의외로 빠르고 단순명료하게 동작하면서, 6개월마다 시스템을 갈아 엎을 일 없이 계속 조금씩 업그레이드 되어(rolling release) 최신 소프트웨어를 항상 바로 사용할 수 있다는 점이 맘에 들었습니다. 더 이상 우분투 개발 버전을 사용하면서 X가 실행되지 않는다든지, 부팅이 안된다든지, 잘 돌던 소프트웨어가 동작하지 않는다든지 걱정할 필요가 없어진 셈입니다. 게다가 아치 사용자 저장소(Arch User Repository; AUR)와 yaourt 프로그램을 사용하니 기존에 별도로 설치했던 dropbox, android-sdk, eclipse, openproj 등도 쉽게 패키지로 설치할 수 있어 더 편했습니다. 물론 GUI 방식 패키지 관리자가 없고 패키지 설치만으로 모든 설정이 자동으로 되는게 아니라 어느 정도 리눅스 경험자가 아니면 불편한 점도 많지만, 오히려 중급 사용자 이상일 경우 원리를 하나씩 알아가면서 설치하는 재미도 쏠쏠합니다. 게다가 별도 문서가 불필요할 정도로 아치리눅스 위키 페이지 정리가 잘 되어 있어 굳이 다른 구글링도 필요없는 것 같습니다. 물론, 한글 글꼴 패키지의 부족이나 부족한 그놈 테마 패키지 등 못마땅한 점이 없는 건 아니지만, 어차피 단점 없는 배포판은 없는 법, 나름 오랜만에 커스터마이징에 즐거운 시간을 보낸 것 같습니다.

인증 스크린샷이라도 하나 올리려다가, 별로 다른게 없어서 그만 두었습니다. 사용하는 배포판이 무엇이든, 어차피 설치 이후에는 결국 동일한 리눅스일 뿐이기 때문입니다. 여담이지만, 오래된 저사양 노트북에서도 동일한 그놈 환경인데 우분투보다 더 빨리 실행되는 듯한 느낌을 받고 있습니다. 물론 정신적인 영향이 더 큰 것 같기도 하지만... :)
