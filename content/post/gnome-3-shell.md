---
date: "2009-06-02T00:00:00Z"
tags:
- Clutter
- GLib
- GNOME
title: GNOME 3.0 셸(GNOME Shell) 소개
---

GNOME 3.0의 기본 프로그램 역할을 하게 될 [그놈 셸(GNOME Shell)](http://live.gnome.org/GnomeShell)에 대한 소식이 요즘 많이 보이는군요. 하지만 역시 엔지니어라서 그런지, 사용자 관점의 변화보다 기술적인 면에 더 관심이 갈 수 밖에 없는터라 그 부분을 조금 정리해 보았습니다.

새로운 셸은 기존에 컴피즈(Compiz)가 했던 3D 컴포지트 기능을 내장하면서 메타시티(Metacity)가 담당했던 윈도우 관리자 역할과 그놈 패널(GNOME Panel) 역할을 동시에 담당합니다. 그런데, 지금보다 더 직관적이고 화려한(?) 인터페이스를 구현하는 것은 물론 많은 개발자가 쉽게 패널 애플릿을 작성할 수 있도록 과감하게도 [클러터(Clutter)](http://www.clutter-project.org/) 라이브러리와 자바스크립트(JavaScript) 언어를 이용해 구현하고 있습니다.

물론 그렇다고 모든 그놈 플랫폼에서 GTK+ 라이브러리를 클러터 라이브러리로 대체하는 것은 아니고 그놈 셸을 작성하는데만 사용하는 것으로 일단 제한하고 있습니다. 클러터보다는 아무래도 GTK+ 자체가 더 복잡한 인터페이스를 요구하는 많은 어플리케이션에 적합하기 때문입니다. 그러나 그놈 셸처럼 화려하고 직관적인 인터페이스를 구현하기 위해서는 클러터 라이브러리가 더 적합하다는 판단인 것 같습니다.

하지만 자바스크립트 언어의 도입은 약간 충격적입니다. 그동안 파이썬, 루비, 펄, 심지어 Vala  등과 같은 언어까지 새로 만들어가면서도 무언지 모를 아쉬움에 선택을 못하더니, (그래도 결국 C++은 사용하지 않고 :-) C 언어를 대체할 언어를 찾아가던 그놈 개발자들이 결국 전 세계에서 가장 많은 (웹 프로그래머) 사용자를 가진 언어를 선택하게 된 셈입니다. 물론 여기에는 점점 성능이 좋아지는 자바스크립트 인터프리터 엔진의 역할도 큰 것 같습니다.

자바스크립트 인터프리터 엔진은 현재 모질라 트레이스몽키(TraceMonkey) 기반의 [Gjs](http://live.gnome.org/Gjs)와 웹킷(WebKit) 자바스크립트 엔진 기반의 [Seed](http://live.gnome.org/Seed)를 동시에 고려하고 있는듯 합니다. 둘 모두 활발하게 개발되고 있고 각각의 장단점이 있기 때문에 지금 현 시점에서 굳이 하나를 선택하지는 않는 것 같습니다.([LWN 기사](http://lwn.net/Articles/333930/) 참조)

또한 쉽게 자바스크립트 언어를 선택하게 된 배경에는 최근에 멋지게 데뷔한 [GObject Introspection](http://live.gnome.org/GObjectIntrospection) 라이브러리의 역할도 큰 것 같습니다. 참고로 이 라이브러리는 GObject 기반 라이브러리를 어떤 언어에도 쉽게 바인딩할 수 있도록 도와줍니다.

언제나 그렇듯이, 직접적인 그놈 개발자는 아니지만, KDE처럼 성급하게 새로운 기술을 실험하지 않고 점진적으로 이미 잘 개발된 라이브러리를 바탕으로 조금씩 혁신을 이루어가는 그놈 쪽 개발 과정을 보고 있노라면 흐뭇하기만 합니다. 특히나 저처럼 이쪽으로 먹고 사는 사람들한테는 더욱... :)