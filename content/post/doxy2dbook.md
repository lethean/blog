---
date: "2009-07-20T00:00:00Z"
tags:
- DocBook
- doxy2dbook
- Doxygen
title: doxy2dbook 업그레이드
---

지난 번에 공개한 [Doxygen -\> DocBook 변환기](/2009/07/06/doxy2dbook-doxygen-to-docbook-converter/) doxy2dbook 프로그램의 업그레이드 버전입니다. 20090706 버전 이후 변경 사항은 다음과 같습니다.

-   함수 인수(parameters) 이름 줄맞춤 (indent)
-   struct / enum 에 속성(attributes) 이름 줄맞춤 (indent)
-   'inline' 함수 + 'union' 형 문서화 지원
-   링크에 사용하는 ID를 doxygen ID가 아닌 읽기 쉬운 API 이름을 그대로 사용
-   \<indexterm\> 태그 추가 (DocBook 문서에 '\<index/\>' 태그를 넣으면 C/C++ API 색인이 자동으로 생성됨)

사용법은 안에 들어있는 README 파일을 참고하시기 바랍니다.

이 프로그램은 업무상 회사에서 작성한 코드이기 때문에 저작권은 당연히 회사에게 있습니다. 라이센스는 GPL입니다.
