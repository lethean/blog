---
date: "2009-07-06T00:00:00Z"
tags:
- Coding
- DocBook
- doxy2dbook
- Doxygen
title: 'doxy2dbook: Doxygen-DocBook 변환기'
---

소스 코드 문서화에 [Doxygen](http://www.stack.nl/~dimitri/doxygen/)을 이용하고 매뉴얼이나 공식 문서 작성에는 [DocBook](http://www.docbook.org/)을 사용하신다면 혹시 둘을 합칠 수 있는 방법이 있으면 좋겠다는 생각을 해보지 않으셨나요?

긴 말 필요없이 소개하자면, doxy2dbook 프로그램이 그런 역할을 합니다. Doxygen XML 결과물을 DocBook XML로 변환해서 기존 DocBook 문서 안에 자연스럽게 포함할 수 있도록 해줍니다. 제가 GLib 라이브러리 문서 형식에 익숙해서 결과물 역시 비슷하게 출력합니다.

물론 인터넷을 찾아보면, Boost 라이브러리에서 사용하는 것도 있고, XSLT 프로세싱을 이용하는 방법도 있는데, 생각보다 제게는 커스터마이징이 쉽지 않더군요. 그래서 결국 목마른 자 우물 파는 법, 직접 만들어 보았습니다. 처음에는 펄 / 루비로도 만들어 보았으나 Doxygen XML 파싱과 객체 관리에 너무 시간이 오래 걸리는 점이 맘에 들지 않아, 결국 GLib 라이브러리 기반 C 언어로 만들게 되었습니다. 따라서 GLib 라이브러리 + GCC + Make 만 있으면 빌드할 수 있습니다. (하지만 Doxygen XML을 하나로 묶으려면 xsltproc 프로그램도 필요하게 됩니다) 지원하는 Doxygen 태그도 많지 않아서 제가 특정 매뉴얼을 작성하면서 사용하는 태그만 일단 지원합니다.

아직 홈페이지도 따로 없고, 이 블로그 자체가 별로 유명하지도 않기 때문에 얼마나 많은 피드백이나 패치가 올지 모르는데 괜히 처음부터 거창할 필요는 없을 것 같아서, 외부로 공개된 버전 관리 저장소도 없이 달랑 소스 코드 묶음만 공개합니다.

사용법은 안에 들어있는 README 파일을 참고하시기 바랍니다.

이 프로그램은 업무상 회사에서 작성한 코드이기 때문에 저작권은 당연히 회사에게 있습니다. 라이센스는 GPL입니다.