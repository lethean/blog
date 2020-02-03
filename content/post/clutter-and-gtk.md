---
date: "2009-09-08T00:00:00Z"
tags:
- Clutter
- GUI
- Linux
title: 클러터와 GTK
---

\`[Design experience and demos in GTK and Clutter](http://blog.didrocks.fr/index.php/post/Design-experience-and-demos-in-GTK-Clutter)' 라는 포스트가 얼마 전에 올라왔는데 이제야 리뷰를 해봅니다. 이 포스트를 클릭해서 들어가 보시면 데모 동영상이 여러개 있는데, 클러터 안에 GTK 노트북 위젯을 넣어 여러가지 효과를 보여주고 있습니다. 이 포스트는 <span style="background-color:#ffffff;">\`[animating GTK+, Clutter-Gtk, client-side-windows and demos](http://dannipenguin.livejournal.com/280866.html)' 포스트에서 설명한 방식을 더 확장하고 실용적인 예제를 보여주고 있는 셈인데, GTK Client Side Window + ClutterGtk를 이용하고 있습니다.</span>

<span style="background-color:#ffffff;">클러터를 이용해 사용자 인터페이스를 만들때 불편한 점 중 하나는 버튼, 입력상자, 라디오 버튼 등과 같은 위젯 툴킷이 없기 때문에 모두 직접 만들어야 한다는 점입니다. 물론 모블린 프로젝트에서 사용하고 있는 클러터 기반 툴킷 라이브러리도 있고 클러터 예제 디렉토리에 여러가지 참고할 만한 샘플이 있긴 하지만, QT나 GTK 같은 라이브러리처럼 풍부한 기능은 제공하지 않습니다. 이 데모가 유용한 이유는, GTK 위젯을 그대로 클러터 안에 포함할 수 있는 것은 물론, 기존 GTK 위젯의 동작을 확장하여 자연스러운 애니메이션 효과를 마음대로 추가할 수 있다는 점을 보여주고 있기 때문입니다.</span>

<span style="background-color:#ffffff;">물론, 단순히 예쁘고 화려한 인터페이스 효과를 추가하는게 목적이 아니라, 이를 통해 사용자가 더 쉽게 이해하고 사용하기 편한 인터페이스를 제공할 수 있다는 점이 더 중요한 것 같습니다.</span>
