---
date: "2009-01-05T00:00:00Z"
tags:
- Shell
title: 파일 목록에서 최근 버전 얻기
---

이름이 '메이저버전-마이너버전-릴리스날짜' 식으로 구성된 파일 목록이, 예를 들어, 다음과 같이 주어졌을때(list.txt),

    2.0-10-20100101
    2.0-2-20080101
    2.0-9-20090101

셸(shell)에서 가장 최신 마이너 버전을 얻는 방법은 다음과 같습니다.

    $ sort -t- -k2,3 -n list.txt | tail -1

sort 명령 옵션을 설명하면, '-t'는 필드 구분자, '-k'는 정렬 기준으로 사용할 필드 시작,끝 번호, '-n' 옵션은 필드를 문자가 아닌 숫자로 여겨서 판단하도록 하는 것입니다. 차이점이 궁금하신 분은 아래 두 명령의 결과를 비교해 보시길.

    $ sort -t- -k2,3 -n list.txt
    $ sort -t- -k2,3 list.txt
