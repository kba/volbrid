volbriosd
=========

CLI to control volume and brightness with notifications

## Installation

From npmjs:

```
npm install -g volbriosd
```

From source:

```
npm install -g
```

## Value Providers

### Volume

#### pulseaudio

* Requires in `$PATH`: `pacmd(1)`, `pactl(1)`
* Requires running process `pulseaudio`
* Debian/Ubuntu: `sudo apt-get install pulseaudio`
* Archlinux: `sudo pacman -S pulseaudio`

#### amixer

### Brightness

#### xbacklight

* Requires in `$PATH`: `xbacklight(1)`
* Debian/Ubuntu: `sudo apt-get install xbacklight`
* Archlinux: `sudo pacman -S xorg-xbacklight`

#### xrandr

## Notification

### volnoti_show

* Requires in `$PATH`: `xbacklight(1)`
* Requires running process `volnoti`
* Compile from source from [Github](https://github.com/kba/volnoti)

### notify_send

* Requires in `$PATH`: `notify-send(1)`
* Debian/Ubuntu: `sudo apt-get install libnotify-bin`
* Archlinux: `sudo pacman -S libnotify`

### yad

* Requires in `$PATH`: `notify-send(1)`
* Debian: `sudo apt-get install yad -t unstable`
* Ubuntu `sudo apt-get install yad`
* Archlinux (AUR): `yad`
* Compile from source from [Github](https://github.com/kba/yad-dialog)

