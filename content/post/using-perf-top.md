---
date: "2011-01-16T00:00:00Z"
tags:
- Kernel
- Linux
- Perf
title: perf top 사용하기
---

리눅스에서 병목 현상 디버깅이나 현재 실행중인 프로세스 중에서 가장 CPU 리소스를 많이 소모하는 녀석을 찾아야 할 경우가 있습니다. 이런 경우 가장 전통적이고 간단한 방법은 `top` 명령어를 실행해서 키보드 단축키 '1' / 'H'를 눌러 CPU / 쓰레드별 사용량을 확인하는 것입니다. 또한 이와 관련된 전통적인 유닉스 명령어도 많지만, 리눅스에서 실행 루틴 수준에서 더 정밀하게 분석하고 싶다면 [OProfile](http://www.google.co.kr/search?q=OProfile), [Valgrind](http://www.google.co.kr/search?q=Valgrind), [Google Performance Tools](/2009/06/18/debugging-memory-leaks-with-tcmalloc-google-perftools/) 등과 같은 도구를 사용해도 됩니다.

그런데, 최근 리눅스 커널과 배포판에는 [perf](https://perf.wiki.kernel.org/) 추적(trace) 도구가 포함되어 있습니다. 그리고 이를 기반으로 한 여러 명령어 중에서, 이 글에서 소개하는 `perf top` 명령어를 사용하면 쉽게 현재 실행중인 커널 / 사용자 프로세스의 CPU 사용 내역을 확인할 수 있습니다. 이 명령어는 기본적으로 `top` 명령어와 비슷하게 동작하지만, OProfile 같은 도구처럼 별도의 복잡한 설정 과정이 필요없다는 장점이 있습니다. 게다가 그 원리를 조금만 이해하면 다양한 응용이 가능하고, 최근 리눅스 커널에 추가된 많은 추적 도구 중에서 가장 활발하게 개발되고 있는 프레임워크이기 때문에 익숙해지는 것도 나쁘지 않을 것 같습니다.

우분투 리눅스에서 perf 도구를 사용하려면 제일 먼저 다음과 같이 해당 패키지를 설치해야 합니다.

```sh
$ sudo apt-get install linux-tools
```

실행하기 위해서 반드시 perf 이벤트 접근 권한이 있어야 하므로 루트 계정 또는 `sudo` 명령을 이용해 다음과 같이 무작정 실행하면 됩니다.

```sh
$ sudo perf top
```

![](/figures/perf-top-screenshot.png)

위 출력 화면을 간단하게 설명하면, 마지막 갱신 주기 동안 `AES_encrypt` 함수가 가장 많이 실행되었습니다. 목록은 위에서 아래로 더 많이 실행된 순서로 정렬되어 있는데, 각 열(column)을 설명하면, 맨 앞의 샘플(samples)과 퍼센트(pcnt)는 총 성능 카운터 샘플링 중에서 차지한 회수와 비율을 나타내고 함수(function)과 동적 공유 객체(DSO)는 샘플링된 위치를 보여줍니다. 따라서 가장 많이 샘플링된 함수가 갱신 주기 동안 가장 많이 실행된 부분이라고 해석하면 됩니다.

예를 들어 위 실행 결과는, `git pull` 명령으로 ssh 방식 네트웍 서버로부터 데이터를 받아오는 작업을 처리하는 과정을 분석한 것입니다. ssh 연결이므로 암호화 관련 라이브러리 호출이 가장 많이 보이고, 커널에서 사용자 공간으로 복사하는 함수, e1000 이더넷 드라이버 인터럽트 핸들러 등이 눈에 띕니다.

`man perf top` 또는 `perf top help` 명령으로 더 자세한 사용법을 얻을 수 있습니다. 많은 옵션이 있지만 그 중에서 자주 사용하는 옵션 몇 가지만 설명하면, `-v` 옵션은 함수 내에서 더 장확한 샘플링 위치를 보여주면서 상세한 메시지를 출력합니다. 그리고, `-s` 옵션은 지정한 함수만 어셈블리 단계에서 샘플링한 결과를 자세히 보여줍니다.

참고로, 데비안 / 우부툰에서 개발하는 분이라면 패키지로 설치한 라이브러리의 디버깅 심볼 포함 패키지를 함께 설치해 두면, 예를 들어 libc6 라이브러리는 libc6-dbg 패키지(끝에 '-dbg'가 더 붙음), 많은 개발 / 분석 도구에서 더 자세한 정보를 얻을 수 있습니다.