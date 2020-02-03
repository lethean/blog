---
date: "2006-01-11T00:00:00Z"
tags:
- Coding
title: Duff's Device
---

[Duff's Device](http://en.wikipedia.org/wiki/Duff%27s_device)는 연속적인 복사 작업을 수행하는 알고리즘에 있어 C 언어로 구현된 가장 최적화된 기법이다. 일반적으로 어셈블리에서 사용되는 기술을 `switch` 문과 루프 풀기(Loop Unrolling) 기법을 이용하여 구현하는데, 이 기법이 발표된 1983년 이후 아직까지 이보다 더 최적화된 구현은 없다고 한다. 코드를 보면 다음과 같다.

    int n = (count + 7) / 8;      /* count > 0 assumed */
    switch (count % 8) {
    case 0: do { *to = *from++;
    case 7:      *to = *from++;
    case 6:      *to = *from++;
    case 5:      *to = *from++;
    case 4:      *to = *from++;
    case 3:      *to = *from++;
    case 2:      *to = *from++;
    case 1:      *to = *from++;
            } while (--n > 0);
    }

얼핏보면 컴파일도 안될 것 같지만 깔끔하게 컴파일되고 제대로 동작하는 ANSI C 코드이다. 이 코드는 `switch` 문의 `case` 문이 `goto` 문에서도 사용하는 레이블(label)로 처리된다는 점을 이용한다. 8의 배수 크기만큼은 `do { } while ()` 문의 최적화된 루프 풀기(loop unroll) 코드로 동작하고, 8로 나누어지지 않는 나머지 부분은 `switch()` 문에 의해 직접 해당 위치로 점프하여 그만큼을 미리 수행하는 방식이다. '[Loop Unrolling with Duff's Device](http://www.codemaestro.com/reviews/review00000102.html)' 리뷰 문서는 이 알고리즘을 더 자세히 설명하고 있다.

['Coroutines in C'](http://www.chiark.greenend.org.uk/%7Esgtatham/coroutines.html)는 Duff's Device에서 사용한 `switch` 기법을 이용하여 상태가 유지되는 함수를 만들 수 있는 방법을 알려주고 있다. 또한 스테이트 머신(state machine)과 같이 상태에 따라 다른 동작을 해야하는 루틴을 만들 경우 상태 변수에 따라 일일히 분기하는 알고리즘이 아니라, 하나의 작업 흐름대로 코드를 만들고, 다음에 루틴에 진입할 경우 바로 마지막 작업 시점에서 계속 수행되도록 할 수 있다. Duff's Device 기법을 고안한 사람도 처음에는 인터럽트 핸들러를 작성할때 이 방법을 이용하여 만들었다고 한다.

[Protothreads](http://www.sics.se/%7Eadam/pt/) 라이브러리는 Duff's Device 기법을 이용하여 ANSI C 에서 멀티쓰레드를 프로그래밍을 할 수 있도록 도와준다. 쓰레드별 스택(stack)을 지원하지 않고 이벤트 기반으로 동작할 경우에만 유용하다. 하지만, 메모리가 적은 임베디드 시스템이나 마이크로 컨트롤러 시스템에서 멀티쓰레드를 지원하는 운영체제를 이용하기 힘든 경우가 많은데, 이런 경우에 적합하다고 하며, 실제로 이 라이브러리를 이용해 구현한 초경량 커널에 대한 정보도 얻을 수 있다.
