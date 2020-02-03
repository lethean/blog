---
date: "2006-07-03T00:00:00Z"
tags:
- Git
- Subversion
title: Git을 이용한 소스코드 관리
---

['Manage source code using Git'](http://www-128.ibm.com/developerworks/linux/library/l-git/?ca=dgr-lnxw07UsingGit)

이 글은 리누스 토발즈가 개발하고 리눅스 커널과 여러 오픈소스 프로젝트 개발에 사용하고 있는 git 소스 코드 관리 시스템에 대한 개략적인 튜토리얼이다. 자세한 기술적인 내용이라기보다 처음 접하는 이들에게 필요한 일종의 소개서 정도 되는 수준이다.

그런데 이 글을 읽으면서 과연 현재 회사에서 사용하고 있는 [서브버전(subversion)](http://subversion.tigris.org/)을 git으로 대체가 가능할까 궁금해졌다. 이미 서브버전에 있거나 git가 더 나은 점은 대략 다음과 같이 요약할 수 있다.

-   브랜치 작업이 빠르고 쉽다 (subversion도 역시)
-   오프라인 작업을 지원해서, 로컬 커밋을 나중에 한꺼번에 할 수 있다. (subversion도 브랜치를 이용하면 가능하지만, 오프라인은 안됨)
-   커밋이 프로젝트 전체에 걸쳐 원자성을 가진다 (subversion도 역시)
-   모든 작업트리는 전체 프로젝트 히스토리를 담고 있다.

하지만 subversion에 있지만 git에는 약간 부족한 기능들은 다음과 같다.

-   <span style="font-weight:bold;">윈도우즈(windows)와 같은 멀티 플랫폼 지원</span> : 커맨드라인 툴과 QGit 등을 이용하면 되겠지만, TortoiseSVN, Eclipse 등에 익숙한 사용자에겐 아직 무리
-   <span style="font-weight:bold;">바이너리 & 텍스트 파일 인식 구분 처리</span> : 라인구분자, 바이너리 diff 처리 등등등
-   <span style="font-weight:bold;">사용자 인증</span> : git는 훅을 통해 구현하는 것 같은데, 복잡해 보인다

즉, 위의 이유로 인해 아직은 도입이 망설여진다. 하지만, SVN 서버가 회사 내부 네트웍에 있어서 집이나 다른 곳에서 작업할때 커밋하기 불편하거나, 여러 브랜치를 관리하다보면 필요한 독립적인 분산 저장소 등이 필요하다고 느낄때는 아마 다시 git을 검토하고 있을 지도 모른다.
