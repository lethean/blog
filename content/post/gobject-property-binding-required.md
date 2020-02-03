---
date: "2009-04-20T00:00:00Z"
tags:
- GLib
- GTK+
title: GObject Property Binding 기능이 필요함
---

맥 코코아 프레임웍을 공부하면서 GTK+ / GObject 라이브러리에도 있으면 참 좋겠다고 생각한 것 중 하나가 특정 속성(property)을 다른 객체의 속성과 결합하는(binding) 개념입니다. 이를 이용해 자동으로 모델과 뷰를 클릭 몇 번으로 연결하고, 더 나아가 객체 배열은 물론 선택한 항목까지 자동으로 동기화되는 걸 보면서 정말 잘 만들어진 프레임웍이라는 걸 새삼 느낍니다. 또한 사용자가 직접 설계한 클래스를 인터페이스 빌더의 객체로 등록해서 마우스 클릭만으로 자연스럽게 연결이 되는 걸 보면 정말 부럽습니다.

물론 GObject  객체의 속성 묶기(property binding)를 지원하기 위해 [ExoBinding](/2008/12/15/exobinding/)과 같은 라이브러리도 존재하지만, 이 역시 개발자가 직접 코드를 추가해주어야 하는 방식일 뿐 Glade와 같은 인터페이스 빌더에서 직접 사용할 수는 없습니다. 아쉽게도 [GTK+ 3.0 로드맵](http://mail.gnome.org/archives/gtk-devel-list/2009-April/msg00048.html) / [GLib 2.22 예정](http://mail.gnome.org/archives/gtk-devel-list/2009-February/msg00039.html)에도 없는 걸 보면 GTK+ 개발자들은 아무래도 직접 코딩하는 걸 더 선호하거나 혹은 필요성을 못 느끼거나, 또는 아직 괜찮다고 생각하는 구현이 없는 거라고 생각하고 싶을 뿐입니다.
