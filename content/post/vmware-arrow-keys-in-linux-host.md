---
date: "2009-01-21T00:00:00Z"
tags:
- Linux
- VMware
title: 리눅스에서 VMware 방향키 문제 해결하기
---

리눅스에서 VMware 사용시 방향키를 제대로 인식하지 못하고 오동작한다면 다음과 같이 처리하면 됩니다.

`~/.vmware/config` 파일이나 `/etc/vmware/config` 파일에 다음 내용을 추가합니다. (파일이 없다면 새 파일을 만듭니다)

    xkeymap.noKeycodeMap = "TRUE"
    xkeymap.keycode.93 = 0x076
    xkeymap.keycode.97 = 0x073
    xkeymap.keycode.98 = 0x078
    xkeymap.keycode.99 = 0x077
    xkeymap.keycode.100 = 0x079
    xkeymap.keycode.101 = 0x070
    xkeymap.keycode.102 = 0x07b
    xkeymap.keycode.103 = 0x05c
    xkeymap.keycode.104 = 0x11c
    xkeymap.keycode.105 = 0x11d
    xkeymap.keycode.106 = 0x135
    xkeymap.keycode.107 = 0x137
    xkeymap.keycode.108 = 0x138
    xkeymap.keycode.109 = 0x000
    xkeymap.keycode.110 = 0x147
    xkeymap.keycode.111 = 0x148
    xkeymap.keycode.112 = 0x149
    xkeymap.keycode.113 = 0x14b
    xkeymap.keycode.114 = 0x14d
    xkeymap.keycode.115 = 0x14f
    xkeymap.keycode.116 = 0x150
    xkeymap.keycode.117 = 0x151
    xkeymap.keycode.118 = 0x152
    xkeymap.keycode.119 = 0x153
    xkeymap.keycode.120 = 0x16f
    xkeymap.keycode.121 = 0x120
    xkeymap.keycode.122 = 0x12e
    xkeymap.keycode.123 = 0x130
    xkeymap.keycode.124 = 0x15e
    xkeymap.keycode.125 = 0x059
    xkeymap.keycode.126 = 0x14e
    xkeymap.keycode.127 = 0x100
    xkeymap.keycode.128 = 0x000
    xkeymap.keycode.129 = 0x07e
    xkeymap.keycode.130 = 0x000
    xkeymap.keycode.131 = 0x000
    xkeymap.keycode.132 = 0x07d
    xkeymap.keycode.133 = 0x15b
    xkeymap.keycode.134 = 0x15c
    xkeymap.keycode.135 = 0x15d
    xkeymap.keycode.136 = 0x168
    xkeymap.keycode.146 = 0x131
    xkeymap.keycode.148 = 0x121
    xkeymap.keycode.150 = 0x15f
    xkeymap.keycode.151 = 0x163
    xkeymap.keycode.160 = 0x10a
    xkeymap.keycode.163 = 0x16c
    xkeymap.keycode.164 = 0x166
    xkeymap.keycode.165 = 0x16b
    xkeymap.keycode.166 = 0x16a
    xkeymap.keycode.167 = 0x169
    xkeymap.keycode.171 = 0x119
    xkeymap.keycode.172 = 0x122
    xkeymap.keycode.173 = 0x110
    xkeymap.keycode.174 = 0x124
    xkeymap.keycode.180 = 0x132
    xkeymap.keycode.181 = 0x167
    xkeymap.keycode.191 = 0x05d
    xkeymap.keycode.192 = 0x05e
    xkeymap.keycode.193 = 0x05f
    xkeymap.keycode.199 = 0x133
    xkeymap.keycode.220 = 0x10b
    xkeymap.keycode.225 = 0x165
    xkeymap.keycode.234 = 0x16d
    xkeymap.keycode.244 = 0x109
    xkeymap.keycode.246 = 0x157

참고한 문서는 다음과 같습니다.

-   [Linux Hosts That Use the evdev Driver for Keyboards Do Not Map Keys Correctly in Any Guest](http://kb.vmware.com/selfservice/microsites/search.do?cmd=displayKC&docType=kc&externalId=1007439)
-   [Keyboard Mapping on a Linux Host](http://www.vmware.com/support/ws55/doc/ws_devices_keymap_linux.html)

