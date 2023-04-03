# sxmo_swaylock

sxmo_swaylock is a fork of [swaylock-effects](https://github.com/jirutka/swaylock-effects)
with the touchscreen keypad from [swaylock-mobile](https://codeberg.org/slatian/swaylock-mobile).
This is intended to be used with [sxmo](https://sxmo.org/) on mobile devices, as sxmo currently
does not have a proper password protected lockscreen 

## Features

- Everything from [swaylock-effects](https://github.com/jirutka/swaylock-effects) (I have not tested that everything works)
- Support for displaying [notifications](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/Notifications.md)
- On screen 10 digit keypad for touchscreens 
- Flat style indicator from swaylock-mobile
- Basic swipe gestures to toggle the keypad (via --swipe-gestures)

Current implementation is not polished, but in it's current form suffices as a lockscreen and is 
better than what sxmo has by default.

[How to intergrate swaylock into sxmo](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/INTEGRATION.md)

## Planned Features

- More presise swipe gesture detection + more swipe gestures
- Indicator modules (battery, weather, etc)
- Maybe a full keyboard instead of just the numbered keypad
- More customization in regards to the keypad

## Installation

### Compiling from Source

Install dependencies:

* meson \*
* wayland
* wayland-protocols \*
* libxkbcommon
* cairo
* gdk-pixbuf2 \*\*
* pam (optional)
* [scdoc](https://git.sr.ht/~sircmpwn/scdoc) (optional: man pages) \*
* git \*
* openmp (if using a compiler other than GCC)

_\*Compile-time dep_

_\*\*Optional: required for background images other than PNG_

Run these commands:

	meson build
	ninja -C build
	sudo ninja -C build install

On systems without PAM, you need to suid the swaylock binary:

	sudo chmod a+s /usr/local/bin/swaylock

Swaylock will drop root permissions shortly after startup.

