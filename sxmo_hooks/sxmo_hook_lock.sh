#!/bin/sh
# configversion: 5407ec9ac25cbd1e9bdcbe30e7bc84dc
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

grep -q unlock "$SXMO_STATE" || exit

sxmo_log "transitioning to stage lock"
printf lock > "$SXMO_STATE"

# This hook is called when the system reaches a locked state

sxmo_hook_statusbar.sh state_change

superctl stop sxmo_hook_lisgd

SXMO_REASON=screenlocker run-screenlocker&

sxmo_hook_idlelocker.sh

sxmo_superd_signal.sh sxmo_desktop_widget -USR2
