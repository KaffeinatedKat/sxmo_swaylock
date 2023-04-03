#!/bin/sh
# configversion: bd662f3a7848555a73dcd32a3fd7a421
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# This hook enables the proximity lock.

finish() {
	kill "$EVENTMONITORPID"
	kill "$AWKPID"
	rm "$tmp"

	if ! grep -q "$INITIALSTATE" "$SXMO_STATE"; then
		sxmo_hook_screen"$INITIALSTATE".sh
	fi

	# De-activate thresholds
	printf 0 > "$prox_path/events/in_proximity_thresh_falling_value"
	# The in_proximity_scale affects the maximum threshold value
	# (see static const int stk3310_ps_max[4])
	printf 6553 > "$prox_path/events/in_proximity_thresh_rising_value"

	#sxmo_mutex.sh can_suspend free "Proximity lock is running"
	exit 0
}

INITIALSTATE="$(cat "$SXMO_STATE.screen")"
trap 'finish' TERM INT

#sxmo_mutex.sh can_suspend lock "Proximity lock is running"

# Permissions for these set by udev rules.
prox_raw_bus="$(find /sys/devices/platform/soc -name 'in_proximity_raw' | head -n1)"
prox_path="$(dirname "$prox_raw_bus")"
prox_name="$(cat "$prox_path/name")" # e.g. stk3310

printf "%d" "${SXMO_PROX_FALLING:-50}" > "$prox_path/events/in_proximity_thresh_falling_value"
printf "%d" "${SXMO_PROX_RISING:-100}" > "$prox_path/events/in_proximity_thresh_rising_value"

tmp="$(mktemp -u)"
mkfifo "$tmp"

# TODO: stdbuf not needed with linux-tools-iio >=5.17
stdbuf -o L iio_event_monitor "$prox_name" >> "$tmp" &
EVENTMONITORPID=$!

export SXMO_REASON=proximitylock

awk '
	/rising/{system("sxmo_hook_screenoff.sh")}
	/falling/{system("sxmo_hook_screenon.sh")}
' "$tmp" &
AWKPID=$!

initial_distance="$(cat "$prox_raw_bus")"
if [ "$initial_distance" -gt 50 ] && [ "$INITIALSTATE" != "off" ]; then
	sxmo_hook_screenoff.sh
elif [ "$initial_distance" -lt 100 ] && [ "$INITIALSTATE" != "on" ]; then
	sxmo_hook_screenon.sh
fi

wait "$EVENTMONITORPID"
wait "$AWKPID"
