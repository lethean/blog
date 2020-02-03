---
date: "2009-07-13T00:00:00Z"
tags:
- Clutter
- Kernel
- Linux
- Xorg
title: X 윈도우 비디오 가속(VA) API
---

기존 X 윈도우 프로그래밍에서 하드웨어 가속 기능을 이용하여  YUV 형식의 비디오를 재생하거나 MPEG2 코덱을 디코딩하려면  [Xv (X Video)](http://en.wikipedia.org/wiki/X_video_extension)와 [XvMC (X Video Motion Compensation)](http://en.wikipedia.org/wiki/X-Video_Motion_Compensation) 확장(extension) API를 사용해야 합니다. 하지만 몇년 전부터 이러한 X 윈도우 확장 API의 한계를 벗어나기 위해 업체별로 각각 별도의 API 라이브러리를 제공하고 있는데, 인텔의 [VA (Video Acceleration) API](http://en.wikipedia.org/wiki/Video_Acceleration_API), NVIDIA의  [VDPAU (Video Decode and Presentation API for Unix)](http://en.wikipedia.org/wiki/VDPAU), ATI의 [XvBA (X-Video Bitstream Acceleration)](http://en.wikipedia.org/wiki/X-Video_Bitstream_Acceleration) API 등이 그 예입니다. (물론 이를 지원하는 최신 그래픽카드 칩셋이 장착되어 있어야 하는데, 인텔의 경우 G45 칩셋부터 가능하다고 합니다) 참고로 CPU 점유율 66.3 ~ 98.4% 정도를 사용하는 고해상도 H.264 / VC1 비디오 재생이 하드웨어 가속 기능을 이용하면 0.6% 이하로 낮아진다는 [벤치마킹 결과](http://gwenole.beauchesne.info/en/blog/2009/06/22/video_decode_acceleration_benchmarks)도 있습니다.

이러한 여러 업체의 독자적인 API가, [LWN 기사](http://lwn.net/Articles/339349/)에서 정리한 것처럼, 이제는 인텔 API로 통합되어 가고 있습니다.  VDPAU / XvBA 기능이 VA API의 백엔드(backend)로 구현하는 작업이 진행되고 있어 VA API만 지원해도 응용 프로그램은 쉽게 다른 업체의 하드웨어 가속 기능을 사용할 수 있게 되는 것입니다. 물론 MPlayer, FFmpeg, VLC 같은 대표적인 비디오 관련 응용 프로그램은 VA API를 이미 지원하거나 지원하기 위해 준비하고 있습니다.

VA API는 비디오 디코딩 뿐 아니라 기존 Xv 확장 API에서 처리하던 색상 공간 변환 (color space conversion), 감마 교정 (gamma correction), 확대 (scaling) 외에 기타 비디오 작업을 처리합니다. 게다가 앞으로는 인텔에서 제공하는 하드웨어 가속 인코딩 기능까지 지원할 예정인 것 같습니다. (2009년 하반기에 발표할 예정인 인텔 Moorestown 모바일 플랫폼에서 지원하는 것 같습니다) 더 나아가 클러터(Clutter) 같은 툴킷 라이브러리에서 직접 사용할 수 있도록 OpenGL 텍스쳐(texture)에 직접 렌더링하는 기능도 지원할 예정이라는군요.

그래픽 하드웨어 칩셋의 인코더 / 디코더 기능을 이용하는 기능은 얼핏 리눅스 커널 V4L2 기반의 하드웨어 인코더 / 디코더 API와 중복된다는 느낌도 있지만, VA API는 디코딩한 데이터가 바로 그래픽 카드 프레임 버퍼에 저장되어 표시되기 때문에 별도의 디스플레이 과정이 불필요하다는 점이 다릅니다. 또한 인코더 / 디코더 보드는 대부분 다채널 동시 인코딩 / 디코딩을 지원하지만, VA API는 한 번에 하나의 비디오만 처리할 수 있다는 점도 다릅니다.

아직은 모두 오픈소스가 아닌 업체가 제공하는 바이너리 X 윈도우 드라이버에서만 동작하는 것 같지만, 나중에 분명 필요하게 될 때가 있을 것 같으니, VA API 사용법도 한 번 둘러봐야 할 것 같습니다.
