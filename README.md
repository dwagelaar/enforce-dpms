# enforce-dpms

The `enforce-dpms` systemd service works around a long-standing bug in the `amdgpu` Linux driver that breaks DPMS monitor sleep mode:

  - https://gitlab.freedesktop.org/drm/amd/-/issues/662
  - https://gitlab.gnome.org/GNOME/mutter/-/issues/976 (related)
  - https://gitlab.freedesktop.org/drm/amd/-/issues/1840
  - https://bugzilla.kernel.org/show_bug.cgi?id=215203

It does so by monitoring when the D-Bus property for DPMS is changed from 0 ("On") to 3 ("Off") every 2 seconds. When that happens, it will start forcing DPMS "Off" mode every 0.1 seconds for 15 seconds. This effectively suppresses the consequences of the "input changed" event sent back to the computer by the monitor whenever it actually goes into sleep mode, which would otherwise trigger a DPMS state change to "On", which in turn wakes the monitor back up. This script causes the monitor to "miss" the brief DPMS "On" state, and stay asleep.

**NOTE: There is currently a [better work-around available](https://gitlab.freedesktop.org/drm/amd/-/issues/1840), which consists of adding `amdgpu.runpm=0` to your kernel parameters. This does not cause any lag when trying to reactivate the display the way that `enforce-dpms` does. An actual [fix to the kernel is also in the works](https://bugzilla.kernel.org/show_bug.cgi?id=215203), which should remove the need for any work-around in the near future.**

## Installation

```
sudo sh install.sh
systemctl --user daemon-reload
```

## Enable service

```
systemctl --user enable enforce-dpms
systemctl --user start enforce-dpms
```

## Disable service

```
systemctl --user stop enforce-dpms
systemctl --user disable enforce-dpms
```
