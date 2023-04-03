#!/bin/sh
# configversion: a861024910eceb507671197080281140
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# This hook is called when the system reaches a off state (screen off)

sxmo_log "transitioning to screen off"
printf off > "$SXMO_STATE.screen"

export SXMO_REASON=""

sxmo_uniq_exec.sh sxmo_led.sh blink blue red &
LEDPID=$!
sxmo_hook_statusbar.sh state_change

sxmo_wm.sh dpms on
sxmo_wm.sh inputevent touchscreen off
superctl stop sxmo_hook_lisgd

wait "$LEDPID"

case "$SXMO_WM" in
	dwm)
		# dmenu will grab input focus (i.e. power button) so kill it before going to
		# screenoff unless proximity lock is running (i.e. there's a phone call).
		if ! (sxmo_daemons.sh running proximity_lock -q || \
			sxmo_daemons.sh running calling_proximity_lock -q); then
			sxmo_dmenu.sh close
		fi
		;;
esac

sxmo_hook_idlelocker.sh
