#!/bin/sh
# configversion: 040920a594309449edef1213b05965fd
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# This hook is called when the system becomes unlocked again

sxmo_log "transitioning to stage unlock"
printf unlock > "$SXMO_STATE"

sxmo_uniq_exec.sh sxmo_led.sh blink red green &
LEDPID=$!
sxmo_hook_statusbar.sh state_change

sxmo_wm.sh dpms off
sxmo_wm.sh inputevent touchscreen on
superctl start sxmo_hook_lisgd

wait "$LEDPID"

NETWORKRTCSCAN="/sys/module/$SXMO_WIFI_MODULE/parameters/rtw_scan_interval_thr"
if [ -w "$NETWORKRTCSCAN" ]; then
	echo 16000 > "$NETWORKRTCSCAN"
fi

sxmo_hook_idlelocker.sh

sxmo_superd_signal.sh sxmo_desktop_widget -USR2
