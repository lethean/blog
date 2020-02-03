---
date: "2010-08-09T00:00:00Z"
tags:
- Sound
- Ubuntu
title: LG XNOTE C1 노트북 우분투 사용시 사운드 재생 문제
---

오랫동안 묵혀두었던 LG XNOTE C1 노트북에 우분투를 설치했는데, 사운드 카드를 통해 오디오가 재생되지 않았습니다. 한동안 오디오를 재생할 일이 없어서 그냥 사용하다가, 오늘 갑자기 필요해져서 급하게 문제를 해결했는데, 그 과정을 기록해 둡니다.

일단 확인 결과 사운드 카드 관련 드라이버는 모두 정상적으로 동작합니다. 하지만, 역시나 가장 문제 많은 `snd-hda-intel` 드라이버를 사용하고 있었습니다. 그래서 더 정확히 사용하는 모델을 확인하기 위해 `/proc/asound/pcm` 파일을 열어보니 다음과 같이 **ALC883** 모델을 사용하고 있습니다.

    00-00: ALC883 Analog : ALC883 Analog : playback 1 : capture 1
    00-01: ALC883 Digital : ALC883 Digital : playback 1 : capture 1
    00-02: ALC883 Analog : ALC883 Analog : capture 1

이제 이 칩셋을 사용하는 모델 목록을 얻기 위해 리눅스 커널 소스 문서 디렉토리에서 해당 파일을 검색합니다.(`Documentation/sound/alsa/HD-Audio-Models.txt`) 그러면 ALC883 칩은 다음과 같은 목록이 있습니다.

    ALC882/883/885/888/889
    ======================
      3stack-dig    3-jack with SPDIF I/O
      6stack-dig    6-jack digital with SPDIF I/O
      arima         Arima W820Di1
      targa         Targa T8, MSI-1049 T8
      asus-a7j      ASUS A7J
      asus-a7m      ASUS A7M
      macpro        MacPro support
      mb5           Macbook 5,1
      macmini3      Macmini 3,1
      mba21         Macbook Air 2,1
      mbp3          Macbook Pro rev3
      imac24        iMac 24'' with jack detection
      imac91        iMac 9,1
      w2jc          ASUS W2JC
      3stack-2ch-dig        3-jack with SPDIF I/O (ALC883)
      alc883-6stack-dig     6-jack digital with SPDIF I/O (ALC883)
      3stack-6ch    3-jack 6-channel
      3stack-6ch-dig 3-jack 6-channel with SPDIF I/O
      ...
      auto          auto-config reading BIOS (default)

이제 남은 일은 `/etc/modprobe.d/alsa-base.conf` 파일 마지막 부분에 다음과 같은 내용을 추가하고, 위 문서에 있는 각 모델 이름을 지정하고 재부팅한 뒤 사운드 재생 테스트 과정을 모든 모델에 대해 반복합니다.

    options snd-hda-intel model=3stack-dig

다행히 제 경우 첫번째 모델이었습니다. 빙고!

**[추가 - 2010.08.19]** 우분투 10.10 알파 버전에서는 터치패드 버튼도 이상 동작합니다. 여러 사이트를 참고 했지만, 일단 다음 내용을 위와 동일한 방법으로 추가해서 일반 마우스처럼 사용하고 있습니다.

    options psmouse proto=imps
