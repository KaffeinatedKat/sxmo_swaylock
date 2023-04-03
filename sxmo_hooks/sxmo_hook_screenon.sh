#!/bin/sh
# configversion: 5407ec9ac25cbd1e9bdcbe30e7bc84dc
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# don't turn on for proximitylock events when locked
[ "$SXMO_REASON" = "proximitylock" ]  && grep -q '^lock$' "$SXMO_STATE" && exit

export SXMO_REASON=""

sxmo_log "transitioning to screen on"
printf on > "$SXMO_STATE.screen"

# This hook is called when the system wants to turn the screen on

sxmo_uniq_exec.sh sxmo_led.sh blink blue &
LEDPID=$!
sxmo_hook_statusbar.sh state_change

sxmo_wm.sh dpms off
sxmo_wm.sh inputevent touchscreen on
grep -q unlock "$SXMO_STATE" && superctl start sxmo_hook_lisgd

# avoid dangling purple blinking when usb wakeup + power button…
sxmo_daemons.sh stop periodic_blink

wait "$LEDPID"

# Go to screenoff after 8 seconds of inactivity
#if ! [ -e "$XDG_CACHE_HOME/sxmo/sxmo.noidle" ]; then
#	sxmo_daemons.sh start idle_locker sxmo_idle.sh -w \
#		timeout 8 "sh -c 'sxmo_hook_lock.sh\
#		                  sxmo_hook_screenoff.sh"
#fi

sxmo_hook_idlelocker.sh

sxmo_superd_signal.sh sxmo_desktop_widget -USR2
