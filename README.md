# enforce-dpms

The `enforce-dpms` systemd service works around a long-standing bug in the `amdgpu` Linux driver that breaks DPMS monitor sleep mode:

  - https://gitlab.freedesktop.org/drm/amd/-/issues/662

It does so by monitoring when the D-Bus property for DPMS is changed from 0 ("On") to 3 ("Off") every 2 seconds. When that happens, it will start forcing DPMS "Off" mode every 0.1 seconds for 15 seconds. This effectively suppresses the consequences of the "input changed" event sent back to the computer by the monitor whenever it actually goes into sleep mode, which would otherwise trigger a DPMS state change to "On", which in turn wakes the monitor back up. This script causes the monitor to "miss" the brief DPMS "On" state, and stay asleep.

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
