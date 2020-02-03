---
date: "2009-04-29T00:00:00Z"
tags:
- Coding
- GCC
- glibc
title: TCMalloc, 구글 성능 도구
---

장기간 실행되면서 빈번하게 메모리를 할당 / 해제하는 것은 물론 수십 개의 쓰레드가 동작하는 프로그램에서는 어쩔 수 없이 메모리 단편화(Memory Fragmentation)가 발생합니다. 메모리 단편화가 많을 경우 어플리케이션 로직에 메모리 누수(memork leak)가 없어도 C 라이브러리 메모리 관리자가 메모리를 커널에 반환하지 않기 때문에 프로세스의 메모리 사용량은 계속 늘어납니다.(참고로 이러한 경우인지 여부는 주기적으로 `mallinfo()` 정보를 확인하면 됩니다) 물론 이를 회피하기 위한 기법이나 아키텍쳐는 많이 있지만, 그리 쉽게 원하는 성능과 효율을 얻기는 힘들더군요.

그런데, 며칠 동안 이와 비슷한 문제를 디버깅하다가 예전에 무심코 지나쳤던 [Google Performance Tools](http://code.google.com/p/google-perftools/) 라이브러리를 다시 발견하고, 그 안에 들어 있는 [TCMalloc(Thread-Caching Malloc)](http://google-perftools.googlecode.com/svn/trunk/doc/tcmalloc.html) 모듈을 사용해 보았는데 사용하지 않을 때와 비교해 놀랄만큼 많은 차이를 보이는군요. 문서에 보면 성능과 효율을 동시에 향상시킨다고 하는데 성능은 사실 잘 모르겠지만,  장기간 실행시 메모리 사용량 변동률은 너무나 맘에 듭니다.

간단하게 TCMalloc의 동작 방식을 설명하면, 일단 중앙 메모리 관리자와 쓰레드별 메모리 관리자를 구분합니다. 작은 크기(32K 이하)의 메모리 할당 / 해제 요청은  쓰레드별 메모리 관리자가 처리하고, 부족할 경우 중앙 메모리 관리자에서 얻어오는 방식입니다. 따라서 메모리 할당시 불필요한 동기화 과정이 이론상 거의 없어 성능 향상을 얻을 수 있습니다.  메모리 크기를 60개의 클래스로 나누어 관리하게 때문에 단편화도 줄어듧니다. 큰 메모리(32K 이상)는 전역 관리자에서 페이지 크기(4K) 단위로 클래스를 나누어 mmap()을 이용하여 할당하는 것을 제외하고 전체적으로 비슷하게 처리합니다.

소스를 빌드하고 프로젝트에 라이브러리를 링크하는 방법은 [위키페이지](http://code.google.com/p/google-perftools/wiki/GooglePerformanceTools)에 설명되어 있으며, 문제가 발생하거나 더 복잡한 튜닝을 원한다면 소스 묶음 안에 있는 [README](http://google-perftools.googlecode.com/svn/trunk/README), [INSTALL](http://google-perftools.googlecode.com/svn/trunk/INSTALL) 파일 등을 참고하면 됩니다. (특히 리눅스 x86\_64 환경에서는 `configure` 실행시 '`--enable-frame-pointers`' 옵션을 추가하는 것이 좋습니다)
