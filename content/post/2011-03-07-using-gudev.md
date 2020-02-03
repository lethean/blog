---
date: "2011-03-07T00:00:00Z"
tags:
- GLib
- Linux
- Udev
title: GUDev 사용하기
---

이제는 리눅스 데스크탑 뿐 아니라 임베디드 시스템에서도 당연하게 사용하는 [udev](http://en.wikipedia.org/wiki/Udev) 시스템은 단순히 장치 파일을 자동으로 생성해 주는 역할 뿐 아니라 여러 핫플러그(hot-plug) 방식 장치를 감지하는데도 유용하게 사용됩니다. 비단 키보드, 마우스 같은 입력 장치 뿐 아니라 USB 플래시, SATA / IDE / SCSI 하드디스크, CD-RW 등과 같은 저장장치가 삽입되었거나 제거되었을 경우 쉽게 감지할 수 있게 도와줍니다.

이러한 udev 서브 시스템의 혜택을 개발자가 얻기 위해 많은 방법이 존재하지만, 이 글에서는 GLib 메인루프 기반으로 동작하는 [GUDev](http://www.kernel.org/pub/linux/utils/kernel/hotplug/gudev/) 라이브러리를 이용하는 법을 설명합니다. GLib 라이브러리를 사용하지 않을 경우 직접 [libudev](http://www.kernel.org/pub/linux/utils/kernel/hotplug/libudev/) 라이브러리를 사용해도 되지만, 기본 개념만 파악하면 쉽게 어떤 라이브러리를 사용해도 상관없기 때문에 인터페이스가 더 편하고 직관적인 GUDev 라이브러리를 사용합니다. 참고로, 이 글은 "[libudev and Sysfs Tutorial](http://www.signal11.us/oss/udev/)﻿" 글과 "[gudev Vala bindings](http://www.piware.de/2010/06/gudev-vala-bindings/)" 글을 참고했습니다.

먼저 라이브러리를 설치하려면 우분투에서는 `libgudev-1.0-dev` 패키지, 아치리눅스에서는 `udev` 패키지를 설치하면 됩니다. (여담이지만, 아치리눅스는 개발에 필요한 헤더파일과 라이브러리가 별도 패키지로 분리되어 있는 경우가 별로 없는 것 같습니다)

다음 소스 코드는 현재 시스템에 장착된 모든 블럭 장치(block)를 보여주고, 이후 USB 플래시가 삽입되거나 제거되었을때 이를 감지하여 표시하도록 한 소스 코드입니다.(`gudev.c`)

```c
#include <gudev/gudev.h>

static void
print_device (GUdevDevice *device)
{
  const gchar * const *symlinks;

  g_print ("  subsystem       : %sn"
           "  devtype         : %sn"
           "  name            : %sn"
           "  number          : %sn"
           "  sysfs_path      : %sn"
           "  driver          : %sn"
           "  action          : %sn"
           "  seqnum          : %lldn"
           "  device_type     : %dn"
           "  device_number   : %dn"
           "  device_file     : %sn"
           "n",
           g_udev_device_get_subsystem (device),
           g_udev_device_get_devtype (device),
           g_udev_device_get_name (device),
           g_udev_device_get_number (device),
           g_udev_device_get_sysfs_path (device),
           g_udev_device_get_driver (device),
           g_udev_device_get_action (device),
           g_udev_device_get_seqnum (device),
           g_udev_device_get_device_type (device),
           g_udev_device_get_device_number (device),
           g_udev_device_get_device_file (device));
}

static void
uevented (GUdevClient *client,
          gchar       *action,
          GUdevDevice *device,
          gpointer     user_data)
{
  g_print ("[action:%s]n", action);
  print_device (device);
}

static void
print_block_device (gpointer data,
                    gpointer user_data)
{
  GUdevDevice *device = data;

  print_device (device);
  g_object_unref (device);
}

static void
print_block_devices (GUdevClient *client)
{
  GList *devices;

  devices = g_udev_client_query_by_subsystem (client, "block");
  if (devices)
  {
    g_print ("[block devices]n");
    g_list_foreach (devices, print_block_device, NULL);
    g_list_free (devices);
  }
}

int
main (int    argc,
      char **argv)
{
  const gchar *subsystems[4] =
    { "usb/usb_interface", "scsi/scsi_device", "block", NULL };
  GUdevClient *client;
  GMainLoop   *main_loop;

  g_type_init ();
  main_loop = g_main_loop_new (NULL, FALSE);

  client = g_udev_client_new (subsystems);
  g_signal_connect (client, "uevent", G_CALLBACK (uevented), NULL);

  print_block_devices (client);

  g_main_loop_run (main_loop);
  g_object_unref (client);

  return 0;
}
```

컴파일 하려면 다음과 같이 실행하면 됩니다.

```sh
$ gcc -o gudev gudev.c `pkg-config --cflags --libs gudev-1.0`
```

소스 코드를 간단하게 설명하면, 제일 먼저 `g_udev_client_new()` 함수를 이용해 `GUdevClient` 객체를 생성합니다. 이때 넘겨주는 인수는 변화를 감지하고 싶은 서브 시스템 목록인데, 여기서는 모든 블럭 장치와 USB, SCSI 서브 시스템을 지정했습니다.(SCSI는 실제로 모든 종류의 하드디스크를 의미하기도 합니다) 만일 `NULL`을 지정하면 변화 감지 기능을 사용하지 않고 그냥 질의(query) 계열 API만 사용할 수 있으며, 비어있는 목록을 넘겨주면 시스템의 모든 서브시스템의 장치 변화를 감지해서 시그널로 알려줍니다. 참고로 매뉴얼에는 클라이언트를 생성한 쓰레드의 메인루프를 사용하여 감지 루틴이 실행된다고 하니, 만일 별도 쓰레드에서 이 감지 작업을 수행하려면 쓰레드를 먼저 만들고 그 쓰레드 안에서 생성해야 합니다. 이 예제에서는 테스트를 위해 기본 메인 루프를 사용하고 있습니다.

직접 장치 목록을 질의(query)하거나 시그널이 발생했을 경우 넘겨받는 `GUdevDevice` 객체와 `g_udev_device_get_*()` 계열 API를 이용하면 장치의 세부 정보를 얻을 수 있습니다. 위 예제에서는 udev / sysfs 관련 속성 등은 출력하지 않고 있지만, 필요하다면 더 자세한 정보를 얻을 수 있습니다.

실행하면 대략 다음과 같이 출력됩니다. (당연히 실행 환경에 따라 결과가 다릅니다)

```sh
$ ./gudev
[block devices]
  subsystem       : block
  devtype         : disk
  name            : sda
  number          : (null)
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda
  driver          : (null)
  action          : (null)
  seqnum          : 0
  device_type     : 98
  device_number   : 2048
  device_file     : /dev/sda

  subsystem       : block
  devtype         : partition
  name            : sda1
  number          : 1
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1
  driver          : (null)
  action          : (null)
  seqnum          : 0
  device_type     : 98
  device_number   : 2049
  device_file     : /dev/sda1

  subsystem       : block
  devtype         : disk
  name            : sr0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1f.2/host5/target5:0:0/5:0:0:0/block/sr0
  driver          : (null)
  action          : (null)
  seqnum          : 0
  device_type     : 98
  device_number   : 2816
  device_file     : /dev/sr0

위 출력에서는 일반 디스크 장치(`/dev/sda`)와 디스크 파티션(`/dev/sda1`), DVD-RW 장치(`/dev/sr0`)가 있음을 보여줍니다. 여기서 만일 일반 USB 플래시 메모리를 삽입하면 다음과 같은 결과가 출력됩니다.

[action:add]
  subsystem       : usb
  devtype         : usb_interface
  name            : 2-3:1.0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0
  driver          : usb-storage
  action          : add
  seqnum          : 1934
  device_type     : 0
  device_number   : 0
  device_file     : (null)

[action:add]
  subsystem       : scsi
  devtype         : scsi_device
  name            : 17:0:0:0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host17/target17:0:0/17:0:0:0
  driver          : sd
  action          : add
  seqnum          : 1938
  device_type     : 0
  device_number   : 0
  device_file     : (null)

[action:change]
  subsystem       : scsi
  devtype         : scsi_device
  name            : 17:0:0:0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host17/target17:0:0/17:0:0:0
  driver          : sd
  action          : change
  seqnum          : 1944
  device_type     : 0
  device_number   : 0
  device_file     : (null)

[action:add]
  subsystem       : block
  devtype         : disk
  name            : sdc
  number          : (null)
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host17/target17:0:0/17:0:0:0/block/sdc
  driver          : (null)
  action          : add
  seqnum          : 1945
  device_type     : 98
  device_number   : 2080
  device_file     : /dev/sdc

[action:add]
  subsystem       : block
  devtype         : partition
  name            : sdc1
  number          : 1
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host17/target17:0:0/17:0:0:0/block/sdc/sdc1
  driver          : (null)
  action          : add
  seqnum          : 1946
  device_type     : 98
  device_number   : 2081
  device_file     : /dev/sdc1
```

위 예제 소스 코드에서 감시하기 위해 지정한 서브 시스템 모두의 변화를 보여주다보니 복잡해 보이지만, 결국 USB 플래시 메모리가 USB / SCSI / BLOCK 서브시스템에 모두 정상적으로 감지되는 걸 확인할 수 있습니다. 다시 장치를 제거하면 다음과 같이 출력됩니다.

```sh
[action:remove]
  subsystem       : block
  devtype         : disk
  name            : sdc
  number          : (null)
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host16/target16:0:0/16:0:0:0/block/sdc
  driver          : (null)
  action          : remove
  seqnum          : 1926
  device_type     : 0
  device_number   : 2080
  device_file     : /dev/sdc

[action:remove]
  subsystem       : scsi
  devtype         : scsi_device
  name            : 16:0:0:0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0/host16/target16:0:0/16:0:0:0
  driver          : (null)
  action          : remove
  seqnum          : 1927
  device_type     : 0
  device_number   : 0
  device_file     : (null)

[action:remove]
  subsystem       : usb
  devtype         : usb_interface
  name            : 2-3:1.0
  number          : 0
  sysfs_path      : /sys/devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3:1.0
  driver          : (null)
  action          : remove
  seqnum          : 1931
  device_type     : 0
  device_number   : 0
  device_file     : (null)
```

이 정보를 실제로 어떻게 활용할지는 이제 어플리케이션에게 달린 몫입니다.
