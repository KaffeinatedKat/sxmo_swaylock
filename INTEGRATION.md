# Integrating swaylock into sxmo

By modifying some of the sxmo hooks (and adding a few), it is possible to replace sxmo's default "lock state" with swaylock instead

### Swaylock wrapper

The hook changes execute the wrapper script [run-screenlocker](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/scripts/run-screenlocker) instead of swaylock directly. This checks if swaylock exited with a success code or not, allowing us to restart it in the case of a crash. 

***This must be on your $PATH, or things will go horribly wrong***

### Modified hooks

- [sxmo_hook_inputhandler.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_inputhandler.sh)
Powerbutton only turns the screen on/off, calls the lock hook before turning the screen off
Corner swipe locks and turns off the screen

- [sxmo_hook_lock.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_lock.sh)
Locks the screen, but only if currently in an unlocked state to prevent double locking
Also calls the idlelock hook

- [sxmo_hook_proximitylock.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_proximitylock.sh)
Calls the screen on hook instead of the unlock hook
Disables the can_suspend mutex locking

- [sxmo_hook_screenoff.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_screenoff.sh)
Stores the lock state in $SXMO_STATE.screen

- [sxmo_hook_unlock.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_unlock.sh)
Uses the idlelock hook for setting the screenlocker 

### New hooks

- [sxmo_hook_idlelocker.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_idlelocker.sh) 
Sets the idlelocker for screen on scenarios depending on $SXMO_STATE

- [sxmo_hook_screenon.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/sxmo_hook_screenon.sh)
Handles turning on the screen, and related services  

## Installation

- Add [these files](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/sxmo_hooks/) to `~/.config/sxmo/hooks/` (or modify your existing hooks)
- Put [run-screenlocker](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/scripts/run-screenlocker) on your $PATH (e.g. `~/.local/bin/`)
- Ensure sxmo_swaylock is installed as `swaylock` on your $PATH

## Known issues

- If swaylock is not installed/does not start properly, sxmo has a stroke when trying to lock the screen
- If you get a call while the screen is off and locked, you cannot turn the screen on and have to wait for the call to expire. This might be caused by dmenu starting and stealing input handling, preventing the powerbutton from turning on the screen
- Sometimes when turning on the phone while locked, screen input is disabled. This is rare and hard to debug, but an issue nonetheless
- Disables the proximity lock suspend inhibitor, which might cause issues
- When the phone is unlocked and the proximity sensor is active and covered and you press the power button, the screen turns on for a second then locks and turns off the screen
