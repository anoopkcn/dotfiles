# system/

Root-owned config, mirroring the `/etc` layout. Installed by `sudo
./setup-system.sh` (symlinks, so repo edits are live).

This exists because the lid/sleep/wakeup behaviour that
`wayland/hypr/conf/monitors.lua` and `wayland/hypr/hypridle.conf` are built on
used to live entirely in unstated systemd defaults. Two of them are load-bearing
and were only true by accident.

## etc/systemd/logind.conf.d/10-lid.conf

Pins `HandleLidSwitchDocked=ignore`. Already the systemd default, so it changes
nothing today — it just stops a future default flip from silently breaking
monitors.lua.

logind treats *any connected external display* as "docked" (`logind.conf(5)`),
so the desk monitor alone is enough to route every lid-close through
`HandleLidSwitchDocked`. That is why closing the lid at the desk never suspended
on its own. Suspending is split between hypridle and monitors.lua instead:

| Situation | Who suspends | Trigger | Skipped if audio playing |
|---|---|---|---|
| Lid close, undocked | logind (`HandleLidSwitch=suspend`) | immediate | no — logind can't check |
| Lid shut, docked | 1200s listener in hypridle.conf | 20 min **idle** | **yes** |
| Undock with lid already shut | `monitor.removed` handler in monitors.lua | 8s | no — you physically left |
| Idle on battery, lid either way | 1800s listener in hypridle.conf | 30 min idle | **yes** |
| Idle on AC, lid open | nobody, deliberately | — | — |

### Why the docked lid-close suspend is idle-gated, not a lid timer

Because "lid shut" does not mean "gone" on this machine — working on the
external with the laptop closed is the *normal* mode, and the entire point of
monitors.lua. A first attempt armed a 90-second timer from the lid-close event
in monitors.lua and it suspended a live desk session twice: a timer started by
the lid event has no idea whether anyone is still typing. Only an idle timer can
separate "shut the lid and left" from "shut the lid and kept working", so the
rule lives in hypridle, where input resets the clock. Do not move it back.

The audio guards are all `pactl list sinks | grep -q RUNNING`, which matters
because it sees Bluetooth sinks — lid shut at the desk with headphones on is
another normal mode, and an earlier cut slept straight through a WH-1000XM5
playing. They are one-shot: audio at the deadline means no suspend until the
next activity→idle cycle.

Do **not** set `HandleLidSwitchDocked=suspend` to "simplify" this. It fires on
the lid event with no idea whether you are still working — the exact failure
above, but harder to fix because it is below the compositor.

## etc/udev/rules.d/90-dock-wakeup.rules

Lets the USB-C dock wake the laptop from suspend.

The desk monitor comes in on `DP-2` over USB-C, not the physical HDMI port
(`HDMI-A-1` sits disconnected). DisplayPort hotplug is not a wakeup source, but
the dock brings a full USB tree up on the same plug event, and USB is. Both PCI
xHCI controllers were already armed; the four **root hubs** were not, which
broke the chain in the middle — so nothing on USB could wake the machine,
including the dock's own keyboard.

Topology, for when this needs re-deriving:

```
USB 3.x   2-2  VL813 hub + RTL8153 LAN + SD reader  ->  usb2  ->  0000:00:0d.0  (TXHC)
USB 2.0   3-8  VL813 hub + keyboard                 ->  usb3  ->  0000:00:14.0  (XHCI)
```

Verify with `cat /sys/bus/usb/devices/usb*/power/wakeup` — expect `enabled` four
times.

### If you get spurious wakeups

Root-hub wakeup is disabled by default precisely because it can wake a laptop
inside a bag. Check for resumes you didn't trigger:

```sh
journalctl --since -7d | grep 'PM: suspend exit'
```

Narrow in this order, re-testing each time:

1. **One controller only.** Add `KERNELS=="0000:00:0d.0"` to the root-hub rule
   to keep wake-on-dock-connect but drop the PCH side, or `KERNELS=="0000:00:14.0"`
   to keep wake-on-keyboard and drop the dock-connect wake.
2. **Keyboard only.** Delete the root-hub line entirely and keep the two
   `2109:*` hub lines. Loses wake-on-connect; you press a key instead.
3. **Back it out.** `sudo rm /etc/udev/rules.d/90-dock-wakeup.rules && sudo udevadm control --reload`.

Note `mem_sleep` must stay `s2idle` for any of this to work. `deep` (S3) is
available on this machine and looks tempting for battery, but it generally
breaks USB-C DP re-enumeration and would cost the wake path entirely.
