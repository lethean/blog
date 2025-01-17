---
date: "2009-10-01T00:00:00Z"
tags:
- Git
title: Subversion 프로젝트 Git 기반으로 이전
---

회사에서 개발하는 모든 프로젝트 소스는 (이제는 당연하겠지만) 버전 관리 시스템을 이용해 관리합니다. 2001년부터 CVS를 사용하다가 2004년에 Subversion으로 이전하여 지금까지 사용했습니다. 그리고 이번달에 사전 조사와 학습, 개발자 세미나 등을 거쳐 Git으로 이전하게 되었는데, 그 과정에서 몇 가지 기록해 둘 만한 내용을 정리했습니다.

Git 자체를 학습하고 이해하는데는 [Pro Git](http://progit.org/book/) 책이 가장 유용했습니다. 서버 구축과 계정 관리 뿐 아니라 수많은 Git 관련 온라인 문서를 보면서 애매하고 답답했던 내용을 가장 쉽게 설명한 책인 것 같습니다. 국내에는 아직 수입이 안된 것 같지만, 온라인으로 공개되어 있어 읽는데 문제는 없습니다.

기존  Subversion 저장소를 Git으로 변환하기 위해 [svn2git](http://github.com/schwern/svn2git) 프로그램을 조금 수정해서 사용했습니다. svn2git 프로그램은 여러 스크립트 버전이 있는데 링크한 펄 버전이 가장 튼튼했습니다. 수정한 부분은 변환 작업 마지막의 trunk 브랜치를 master 로 자동으로 변경해 주는 부분인데, 몇몇 저장소에서 오동작을 일으켜 실행하지 않도록 주석 처리한 것 뿐입니다. 한가지 유의할 점은, 서브버전에서 마지막 커밋이 이루어진 브랜치가 Git에서 master 브랜치가 되므로,  trunk에서 마지막 커밋임을 확인해야 합니다. 변환 작업은 저장소가 운영되고 있는 서버에서 직접 'file:///' URL 접근을 이용해 처리했는데, 왜냐하면 가끔 네트웍 오류나 웹서버 오류가 발생할 경우 처음부터 다시 실행해야 하는 문제가 있기 때문입니다.

윈도우(Windows)에서는  [msysgit](http://code.google.com/p/msysgit/) + [TortoiseGit](http://code.google.com/p/tortoisegit/) 프로그램을 사용하고, 맥(Mac)은 기본으로 제공하는 설치 프로그램을 이용했습니다. [Git Extensions](http://code.google.com/p/gitextensions/)은 비주얼 스튜디오 확장 기능도 있지만, 안정성이나 유용성이 조금 부족하다는 느낌을 받았습니다.

'git push'시에 자동으로 메일링 리스트나 특정 메일 주소로 메일을 전송하는 기능은 Git 소스에 들어있는 기본 훅(hook) 스크립트 대신 [GNOME Git 관리 스크립트](http://git.gnome.org/cgit/gitadmin-bin/)에 들어있는 gnome-post-receive-mail 스크립트를 조금 수정해서 사용했습니다. 커밋 로그 메시지에 'Bug \#1111' 같은 문자열이 있으면 자동으로 버그질라 데이터베이스에 추가하는 기능은 아직 이전하지 못했습니다. 구글링을 해보면 몇몇 비슷한 스크립트를 찾을 수 있으나 맘에 드는 게 없다는 점도 이유 중 하나이지만, GNOME 프로젝트처럼 'git bz' 같은 명령을 이용해 직접 버그질라에 버그를 등록하거나(file), 첨부파일로 커밋 로그 추가, 상태 변화 등을 할 수 있는 방식으로 변화를 꾀하는 것도 좋을 것 같아 고민 중에 있습니다.

기본 Subversion 저장소를 Git으로 이전할때 가장 고민이 되었던 부분은 Subversion의 svn:externals 속성을 이용해 복잡하게 연결되어 있는 수많은 프로젝트를 어떻게 관리할 것인가였습니다. 처음에는 Git이 제공하는 Submodules 기능을 이용하려 했으나 생각보다 복잡한 것 같아서 일단 팀원들이 모두 Git에 어느 정도 익숙해진 다음에 적용하기로 하고, 대신 자동으로 하위 모듈까지 내려 받는 스크립트(예:git-pull-all.sh)를 최상위 디렉토리에 두고 사용하기로 했습니다. 대신 여러 프로젝트에서 공유하는 여러 프로젝트를 하나의 프로젝트로 소스를 합친 뒤 모든 프로젝트에서는 단 하나의 공유 프로젝트만 연결하도록 저장소 구조를 대폭 단순화했습니다.

아무튼 이전 작업은 마무리했지만, 한동안은 Subversion에서 벗어나 Git에 익숙해지기까지 시행착오를 많이 겪을 것 같고, 작업 방식이나 브랜치 / 안정버전 관리 방식 등도 Git에 더 친숙한 방식으로 변경해가야 할 것 같은 생각이 듭니다.
