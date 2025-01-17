---
date: "2011-02-22T00:00:00Z"
tags:
- ArchLinux
- Linux
- Ubuntu
title: 사진 파일 이름 변경하기
---

요즘 디지털 카메라나 휴대폰으로 촬영한 JPEG 파일에는 [EXIF](http://en.wikipedia.org/wiki/EXIF) 정보가 삽입되어 있어서 나름 유용할 때가 많습니다. 카메라에 대한 자세한 사양(?) 정보에는 관심이 없지만, 촬영한 시각이라든지 카메라를 세워서 촬영했는지 여부는 물론, 카메라 GPS 옵션을 켜면 기록되는 촬영 장소의 정확한 좌표는 가끔 두려울 때도 있습니다.

아무튼 요즘은 윈도우나 맥 부럽지 않은 리눅스 사진 관리 프로그램들이 많이 있어서 편하긴 한데, 이런 프로그램들이 존재하기 전부터, EXIF 정보가 포함되지도 않았던 시절부터 디렉토리별로 관리해오던 습관을 버리지 못하는 게 문제입니다. 예를 들어 폴더는 알아보기 쉽게 `YYYYMMDD-장소또는이벤트이름` 식으로 이름짓고, 안에 들어있는 JPEG 파일은 `YYYYMMDD-hhmmss-photo.jpg`, 동영상 파일은 `YYYYMMDD-hhmmss-movie.mp4` 식으로 이름을 지어 줍니다.

물론, 이런 작업을 모두 수작업으로 하지는 않습니다. EXIF 정보에 문외한이던 시절에는 [gthumb](http://live.gnome.org/gthumb) 같은 프로그램의 이름일괄변경(`Rename...`) 기능을 이용해 자동으로 날짜 뒤에 일련번호를 붙이기도 했습니다.

하지만 요즘은 그것도 귀찮아서 `exiv2` / `rename` 명령어를 이용해 한꺼번에 변경해 버립니다. [`exiv2`](http://www.exiv2.org/) 프로그램을 이용해 EXIF 정보에 들어있는 촬영 시각을 기준으로 사진 파일 이름을 변경하고,  `rename` 명령어를 이용해 대문자로 된 `.JPG` 확장자를 소문자 `.jpg` 확장자로 한번에 변경합니다. 예를 들어 위에서 설명한 예처럼 파일 이름을 변경하려면 사진 파일이 들어 있는 디렉토리에서 다음과 같이 실행하면 됩니다.

```sh
$ rename .JPG .jpg *.JPG
$ exiv2 -r '%Y%m%d-%H%M%S-photo' -k rename *.jpg
```

`rename` 명령어는 대부분 배포판에 기본으로 설치되어 있으나 `exiv2` 프로그램은 수동으로 패키지를 설치해야 할 수도 있습니다. 게다가, 우분투의 `rename` 명령어는 perl 패키지에 포함되어 있는 버전인데 아치 리눅스는 util-linux 패키지에 포함되어 있는 거라 사용법이 조금 다릅니다. 참고로 위 예제는 아치 리눅스 버전입니다. 하지만 `exiv2`, `rename` 명령어 모두 매뉴얼 페이지를 보면 자세한 사용 예제가 있으므로 쉽게 사용할 수 있습니다.

그리고 이 글은 사실, 나이가 들수록 자꾸만 옵션을 잊어버려 다시 찾기 귀찮아서 기록하고 있습니다... :)
