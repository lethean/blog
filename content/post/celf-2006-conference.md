---
date: "2006-05-09T00:00:00Z"
tags:
- Embedded
- Linux
title: CELF 2006 컨퍼런스
---

[CELF 2006](http://linuxdevices.com/articles/AT8247255296.html) 컨퍼런스에서 공개된 여러 [슬라이드 자료](http://free-electrons.com/community/videos/conferences/)에서 관심있는 몇 가지를 요약해 본다.

<span style="font-weight:bold;">Visualizing Resource Usage During Initialization of Embedded Systems</span>

Bootchart를 임베디드 시스템에 적용하여 임베디드 리눅스 부팅 속도 측정 및 지연 부분을 찾아내는 과정을 보여준다. 더불어 기존 Bootchart의 처리 방식이 저성능 CPU에서는 비효율적이라서 리소스를 적게 차지하도록 새로 개선하는 방법도 소개한다.

<span style="font-weight:bold;">Graphics Subsystem in an Embedded World - Integrating DirectFB into a UHAPI platform</span>

스트리밍 장비 표준 미들웨어 API인 [UHAPI](http://www.uhapi.org/)를 [DirectFB](http://directfb.org/)에서 지원하기 위한 기본 지식과 그 과정을 보여준다.

<span style="font-weight:bold;">Low Disturbance Embedded System Tracing with Linux Trace Toolkit Next Generation</span>

[LTTng](http://www.opersys.com/LTT/)를 이용하여 인터럽트 응답시간을 저해하는 요소를 찾아내는 과정을 설명한다

<span style="font-weight:bold;">Analysis of User Level Device Driver usability in embedded application</span>

임베디드 시스템은 일반적인 서버나 PC와 달리 항상 새로운 디바이스를 사용하는 경우가 대부분이고 일반적인 용도라기보다 하나의 전용 어플리케이션에 맞추어 동작하는 경우가 대부분이다. 이 글에서는 사용자 레벨 디바이스 드라이버, 즉 일반 어플리케이션 방식으로 드라이버를 제작하는 방식을 제시하고 있다. 새로운 개념이라기보다는 이미 존재하는 mmap(), fasync() 등을 이용하여 DMA, IO 영역, 인터럽트 처리 방법을 보여주고 여러가지 커널 설정에서 성능을 비교해주고 있다.

<span style="font-weight:bold;">Embedded Linux Optimizations - Size, RAM, speed, power, cost</span>

[Free Electrons](http://free-electrons.com/)의 강의 시리즈 중에 하나로 보이는 이 자료는, 임베디드 리눅스의 부팅 속도, 메모리 사용크기, 속도, 전원 절약 등 실제 업무에 활용가능한 여러가지 기법을 잘 정리하고 있다. 최신 기술은 물론 고전적인 방식까지 일목요연하게 잘 정리된 것 같다.
