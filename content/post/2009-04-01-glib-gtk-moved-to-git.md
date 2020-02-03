---
date: "2009-04-01T00:00:00Z"
tags:
- Git
- GNOME
- GTK+
- Subversion
title: GLib과 GTK+도 Subversion에서 Git으로 이동
---

2009년 4월 1일을 기준으로 GNOME 프로젝트의 핵심이 되는 glib, gtk, pango, atk 프로젝트가 기존 서브버전에서 [git으로 소스 버전 관리 시스템을 변경](http://mail.gnome.org/archives/gtk-devel-list/2009-March/msg00206.html)했습니다. 한동안 어떤 버전 관리 시스템을 사용할지 논의가 많았는데, 결국 대세를 거를 수는 없었던 모양입니다. 달라진 사용법은 [Git이전하기](http://live.gnome.org/GitMigration) 위키 페이지에 계속 정리되고 있으니 참고하시기 바랍니다.

참고로, 초기 버전과 달리 최신 버전의 git은 이진(binary) 파일 처리 / 외부(external) 프로젝트 연결 등을 지원합니다. 또한 기존 서브버전 저장소와 동시에 유지할 수 있는 방법(git-svn)도 존재합니다. 하지만 아직 아쉬운 점은 멀티플랫폼 지원, 물론 커맨드 라인 방식으로는 지금도 가능하지만, 하지만 윈도우 탐색기 인터페이스에서 벗어나기 싫어하는 게으른 개발자들에게 커맨드 라인 방식을 강요할 근거가 아직은 부족한 것 같습니다. 윈도우 플랫폼에서 TortoiseSVN처럼 탐색기와 통합된 git 클라이언트만 있다면 지금 당장이라도 회사 개발 프로젝트에 도입할 수 있을 것 같은데... :)
