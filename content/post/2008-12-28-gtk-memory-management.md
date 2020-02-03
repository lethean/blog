---
date: "2008-12-28T00:00:00Z"
tags:
- GLib
- GTK+
title: GTK+ 메모리 관리
---

GTK+ 포럼에 [GTK+ 메모리 관리하기](http://www.gtkforums.com/viewtopic.php?t=2412)라는 글이 올라왔는데 내용이 간결해서 이를 참고로 다시 정리해 보았습니다.

**참조 카운터 (Reference Counting)**

모든 GTK 객체는 GObject를 상속하고 있는데, GObject는 메모리 관리를 위해 참조 카운터 기능을 기본적으로 지원합니다. GObject가 새로 생성되면 참조 카운터는 1입니다. 이 참조 카운터는 [g\_object\_ref()](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-ref) / [g\_object\_unref()](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-unref) 함수를 이용해 증가시키거나 감소시킬 수 있습니다. 말 그대로 객체를 사용중이라면(참조하고 있다면) 참조 카운터를 증가시키면 되고, 더 이상 사용하지 않는다면(참조를 안한다면) 참조 카운터를 감소시키면 됩니다. 참조 카운터가 0이 되면 당연히 객체의 모든 리소스는 자동으로 해제됩니다. 하지만 언제나 그렇듯이 예외가 존재하는데 이런 경우 조심하지 않으면 그대로 메모리 누수가 발생하기 쉽상입니다.

첫번째 경우는 객체간에 결합할 때입니다. 가장 흔한 경우가 GtkTreeModel 인터페이스를 구현한 GtkTreeStore / GtkListStore 객체와 GtkTreeView / GtkComboBox 객체를 연결할 때입니다. 예를 들어 gtk\_list\_store\_new() 함수로 만들어진 GtkListStore 객체의 참조 카운터는 1입니다. [gtk\_tree\_view\_set\_model()](http://library.gnome.org/devel/gtk/stable/GtkTreeView.html#gtk-tree-view-set-model) 함수로 트리뷰 객체에 리스트 스토어 객체를 연결하면 참조 카운터는 2가 됩니다. 왜냐하면 트리뷰 객체가 리스트 스토어 객체를 참조하기 때문입니다. 많은 예제 프로그램에서 이 함수를 호출한 뒤 g\_object\_unref() 함수를 이용해 리스트 스토어 객체의 참조 카운터를 감소하는 이유는, 이후 리스트 스토어 객체에 대한 메모리 관리를 더 이상 프로그래머가 할 필요 없이, 트리뷰 객체가 없어질때 리스트 스트어 객체의 참조 카운터를 감소하면서 자동으로 리소스가 정리되도록 하기 위해서입니다.

**객체 복사 (Object Copying)**

두번째 경우는 객체 데이터를 저장하거나 가져올 때입니다. GtkTreeStore / GtkListStore 객체에서 [gtk\_tree\_model\_get()](http://library.gnome.org/devel/gtk/stable/GtkTreeModel.html#gtk-tree-model-get) 함수로 데이터를 가져오거나 gtk\_list\_store\_set() / gtk\_tree\_store\_set() 등으로 저장할때, 즉 데이터가 복사될때는 데이터 타입이 GObject 기반이라면 참조 카운터가 증가됩니다. 이미지 데이터를 관리하는데 많이 사용하는 GdkPixbuf 객체도 그 중 하나입니다. 따라서 이러한 객체를 가져온 뒤 사용이 다 끝났다면 g\_object\_unref() 함수를 이용해 반드시 참조 카운터를 해제해야 합니다.  객체 속성(property)를 설정하거나 가져올때도 마찬가지로 객체 복사 규칙이 적용됩니다. 따라서 g\_object\_set() / g\_object\_get() 함수를 사용했을 때도 사용이 끝난 객체에 대한 참조 카운터를 감소해 주어야 합니다. 마찬가지로, GtkCellRenderer 객체의 속성도 동일한 규칙이 적용되므로 유의해야 합니다.

참고로, 객체 복사시 정수 / 실수 타입 등은 무관하지만 문자열은 항상 새로 할당된 메모리에 복사된 문자열이 전달되기 때문에 사용이 끝나면 g\_free() 함수로 해제해야 합니다. [GBoxed](http://library.gnome.org/devel/gobject/stable/gobject-Boxed-Types.html#g-boxed-copy) 타입은 참조 카운터가 없기 때문에 항상 새로 할당된 메모리에 복사된 자료 구조가 전달되므로 마지막에 해당 객체의 해제 함수로 리소스를 정리해야 합니다. ([G\_TYPE\_DATE](http://library.gnome.org/devel/gobject/stable/gobject-Boxed-Types.html#G-TYPE-DATE--CAPS), [G\_TYPE\_STRV](http://library.gnome.org/devel/gobject/stable/gobject-Boxed-Types.html#G-TYPE-STRV--CAPS), [G\_TYPE\_GSTRING](http://library.gnome.org/devel/gobject/stable/gobject-Boxed-Types.html#G-TYPE-GSTRING--CAPS), ...)

**GInitiallyUnowned 상속 객체 (Descendants of GInitiallyUnowned)**

GTK 객체 중에서 GObject를 직접 상속하지 않고, GtkObject 객체를 상속받는 객체들이 있습니다. GtkWidget / GtkAdjustment / GtkCellRenderer 등이 대표적이므로, GtkWidget을 상속하는 대부분의 위젯이 이러한 객체입니다. [GtkObject 상속도](http://library.gnome.org/devel/gtk/stable/GtkObject.html#GtkObject.object-hierarchy)를 보면 특이하게 GInitiallyUnowned 객체를 상속받는데 이 객체의 참조 카운터 동작 방식은 위에서 설명한 것과 조금 다르기 때문에 더 깊은 이해가 필요합니다.

GInitiallyUnowned 객체는 생성되면 초기에 참조 카운터가 0입니다. 대신 부동 참조(floating reference) 상태에 있게 됩니다. 누군가가 [g\_object\_ref\_sink()](http://library.gnome.org/devel/gobject/stable/gobject-The-Base-Object-Type.html#g-object-ref-sink) 함수를 호출하면 떠있는(floating) 참조가 참조 카운터로 변환되며 닻을 내리게(sink) 됩니다. 이후에는 일반적인 GObject 참조 카운터와 동일하게 동작합니다. 여기서 누군가는 대부분 객체를 자식(child)으로 갖는 부모(parent) 객체입니다. 즉, gtk\_container\_add() / gtk\_box\_pack\_start() 등과 같은 함수를 이용하여 위젯을 결합하면 상위 위젯이 g\_object\_ref\_sink() 함수를 호출합니다.

GTK+ 프로그래밍시 위젯을 만들고 상위 위젯에 넣는 작업은 매우 빈번한데 만일 이 과정에 생성하는 모든 위젯 객체 리소스를 프로그래머가 관리해야 한다면 끔찍해질 겁니다. 부동 참조(floating reference) 개념은 이러한 수고를 덜어주는데 유용합니다. 모든 위젯은 생성 후 상위 위젯에 추가되어도 참조 카운터는 1밖에 안되고, gtk\_widget\_destroy() 등을 이용하여 최상위 위젯을 없애면 모든 하위 위젯 객체는 자동으로 참조 카운터가 0이 되어 메모리가 해제됩니다.

참고로, 어떤  위젯을 부모 위젯에서 떼어낸 뒤 다른 부모 위젯에 넣기 위해서는 제일 먼저 해당 위젯의 참조 카운터를 증가시켜야 합니다. 왜냐하면 부모 위젯에서 떼어낼 때도 참조 카운터가 자동으로 감소하기 때문에, 떼어내는 순간 객체가 사라지기 때문입니다. 부모 위젯이 더 이상 자식 위젯을 참조 하지 않기 때문에 떼어내는 순간 자식 위젯의 참조 카운터가 감소됩니다.

**문자열 / 문자열 배열 / 리스트 (Strings, String Arrays and Lists)**

GLib 라이브러리는 매우 많은 문자열 관련 API를 제공합니다. 또한 특정 객체에서 어떤 결과나 내부 자료를 얻어올때는 문자열 배열이나 리스트(GList) 등도 많이 사용합니다. 이 경우 프로그래머는 반드시 자신이 사용하는 API 문서를 꼼꼼하게 잘 읽어야 합니다. 대부분의 API 문서는 결과로 넘겨지는 데이터 사용이 끝난 뒤 어떻게 해야 하는지를 분명히 명시하고 있기 때문에 이에 따라 리소스를 처리 해야합니다.

따라서 예전부터 GLib / GTK+ 프로그래밍시에는 편집기의 자동 완성 (auto-complete) 기능을 잊어버리고, 번거롭더라도 DevHelp프로그램이나 웹브라우저를 이용해 API 리퍼런스를 분명히 열람한 뒤 정확하게 API를 사용할 것을 권장하고 있습니다.

만일, API 문서에 명확하게 메모리 관리 / 객체 참조 카운터 방식이 명시되지 않았거나 무언가 개운치 않다면, 해당 API 소스 코드를 참고하는 것이 가장 확실한 방법입니다.
