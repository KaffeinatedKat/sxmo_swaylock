#!/bin/sh
# configversion: 061f1ec838ab73997514c2281424b1e6
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# This script handles input actions, it is called by lisgd for gestures
# and by dwm for button presses

ACTION="$1"

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# this action will move the lock state $1 levels higher
lock_screen_action() {
	state="$(cat "$SXMO_STATE.screen")"
	if [ "$state" = "on" ] ; then
		sxmo_hook_lock.sh
		sxmo_hook_screenoff.sh
	else
		sxmo_hook_screenon.sh
	fi
}

XPROPOUT="$(sxmo_wm.sh focusedwindow)"
WMCLASS="$(printf %s "$XPROPOUT" | grep app: | cut -d" " -f2- | tr '[:upper:]' '[:lower:]')"
WMNAME="$(printf %s "$XPROPOUT" | grep title: | cut -d" " -f2- | tr '[:upper:]' '[:lower:]')"

sxmo_debug "ACTION: $ACTION WMCLASS: $WMCLASS WMNAME: $WMNAME XPROPOUT: $XPROPOUT"

if ! grep -q unlock "$SXMO_STATE"; then
	case "$ACTION" in
		"powerbutton_one")
			lock_screen_action
			;;
		"powerbutton_two"|"powerbutton_three")
			lock_screen_action 2
			;;
		"voldown_one")
			sxmo_audio.sh vol down 5
			exit
			;;
		"voldown_two")
			sxmo_audio.sh vol down 10
			exit
			;;
		"voldown_three")
			sxmo_audio.sh vol down 15
			exit
			;;
		"volup_one")
			sxmo_audio.sh vol up 5
			exit
			;;
		"volup_two")
			sxmo_audio.sh vol up 10
			exit
			;;
		"volup_three")
			sxmo_audio.sh vol up 15
			exit
			;;
	esac
	#we're locked, don't process the rest of the script
	exit 0
fi

#special context-sensitive handling
case "$WMCLASS" in
	*"mpv"*)
		case "$ACTION" in
			"oneright")
				sxmo_type.sh -k Left
				exit 0
				;;
			"oneleft")
				sxmo_type.sh -k Right
				exit 0
				;;
			"oneup")
				sxmo_type.sh m
				exit 0
				;;
			"onedown")
				sxmo_type.sh p
				exit 0
				;;
		esac
		;;
	*"foot"*|*"st"*|*"vte"*)
		# First we try to handle the app running inside st:
		case "$WMNAME" in
			*"weechat"*)
				case "$ACTION" in
					*"oneleft")
						sxmo_type.sh -M Alt -k a
						exit 0
						;;
					*"oneright")
						sxmo_type.sh -M Alt -k less
						exit 0
						;;
					*"oneup")
						sxmo_type.sh -k Page_Down
						exit 0
						;;
					*"onedown")
						sxmo_type.sh -k Page_Up
						exit 0
						;;
				esac
				;;
			*" sms")
				case "$ACTION" in
					*"upbottomedge")
						number="$(printf %s "$WMNAME" | sed -e 's|^\"||' -e 's|\"$||' | cut -f1 -d' ')"
						sxmo_terminal.sh sxmo_modemtext.sh conversationloop "$number" &
						exit 0
						;;
				esac
				;;
			*"tuir"*)
				if [ "$ACTION" = "rightbottomedge" ]; then
					sxmo_type.sh o
					exit 0
				elif [ "$ACTION" = "leftbottomedge" ]; then
					sxmo_type.sh s
					exit 0
				fi
				;;
			*"less"*)
				case "$ACTION" in
					"leftbottomedge")
						sxmo_type.sh q
						exit 0
						;;
					"leftrightedge_short")
						sxmo_type.sh q
						exit 0
						;;
					*"onedown")
						sxmo_type.sh u
						exit 0
						;;
					*"oneup")
						sxmo_type.sh d
						exit 0
						;;
					*"oneleft")
						sxmo_type.sh ":n" -k Return
						exit 0
						;;
					*"oneright")
						sxmo_type.sh ":p" -k Return
						exit 0
						;;
				esac
				;;
			*"amfora"*)
				case "$ACTION" in
					"downright")
						sxmo_type.sh -k Tab
						exit 0
						;;
					"upleft")
						sxmo_type.sh -M Shift -k Tab
						exit 0
						;;
					*"onedown")
						sxmo_type.sh u
						exit 0
						;;
					*"oneup")
						sxmo_type.sh d
						exit 0
						;;
					*"oneright")
						sxmo_type.sh -k Return
						exit 0
						;;
					"upright")
						sxmo_type.sh -M Ctrl t
						exit 0
						;;
					*"oneleft")
						sxmo_type.sh b
						exit 0
						;;
					"downleft")
						sxmo_type.sh -M Ctrl w
						exit 0
						;;
				esac
				;;
		esac
		# Now we try generic actions for terminal
		case "$ACTION" in
			*"onedown")
				case "$WMCLASS" in
					*"foot"*)
						sxmo_type.sh -M Shift -k Page_Up
						exit 0
						;;
					*"st"*)
						sxmo_type.sh -M Ctrl -M Shift -k b
						exit 0
						;;
				esac
				;;
			*"oneup")
				case "$WMCLASS" in
					*"foot"*)
						sxmo_type.sh -M Shift -k Page_Down
						exit 0
						;;
					*"st"*)
						sxmo_type.sh -M Ctrl -M Shift -k f
						exit 0
						;;
				esac
				;;
		esac
esac

#standard handling
case "$ACTION" in
	"powerbutton_one")
		if echo "$WMCLASS" | grep -i "megapixels"; then
			sxmo_type.sh -k space
		else
			lock_screen_action
		fi
		exit 0
		;;
	"powerbutton_two")
		lock_screen_action 2
		exit 0
		;;
	"powerbutton_three")
		sxmo_terminal.sh
		exit 0
		;;
	"voldown_one")
		sxmo_keyboard.sh toggle
		exit
		;;
	"voldown_two")
		sxmo_wm.sh togglelayout
		exit
		;;
	"voldown_three")
		sxmo_killwindow.sh
		exit
		;;
	"volup_one")
		sxmo_appmenu.sh
		exit
		;;
	"volup_two")
		sxmo_appmenu.sh sys
		exit
		;;
	"volup_three")
		sxmo_wmmenu.sh
		exit
		;;
	"rightleftedge")
		sxmo_wm.sh previousworkspace
		exit 0
		;;
	"leftrightedge")
		sxmo_wm.sh nextworkspace
		exit 0
		;;
	"twoleft")
		sxmo_wm.sh movepreviousworkspace
		exit 0
		;;
	"tworight")
		sxmo_wm.sh movenextworkspace
		exit 0
		;;
	"righttopedge")
		sxmo_brightness.sh up &
		exit 0
		;;
	"lefttopedge")
		sxmo_brightness.sh down &
		exit 0
		;;
	"upleftedge")
		sxmo_audio.sh vol up &
		exit 0
		;;
	"downleftedge")
		sxmo_audio.sh vol down &
		exit 0
		;;
	"upbottomedge")
		sxmo_keyboard.sh open
		exit 0
		;;
	"downbottomedge")
		sxmo_keyboard.sh close
		exit 0
		;;
	"downtopedge")
		sxmo_dmenu.sh isopen || sxmo_appmenu.sh &
		exit 0
		;;
	"twodowntopedge")
		sxmo_dmenu.sh isopen || sxmo_appmenu.sh sys &
		exit 0
		;;
	"uptopedge")
		sxmo_dmenu.sh close
		if pgrep mako >/dev/null; then
			makoctl dismiss --all
		elif pgrep dunst >/dev/null; then
			dunstctl close-all
		fi
		exit 0
		;;
	"twodownbottomedge")
		sxmo_killwindow.sh
		exit 0
		;;
	"uprightedge")
		sxmo_type.sh -k Up
		exit 0
		;;
	"downrightedge")
		sxmo_type.sh -k Down
		exit 0
		;;
	"leftrightedge_short")
		sxmo_type.sh -k Left
		exit 0
		;;
	"rightrightedge_short")
		sxmo_type.sh -k Right
		exit 0
		;;
	"rightbottomedge")
		sxmo_type.sh -k Return
		exit 0
		;;
	"leftbottomedge")
		sxmo_type.sh -k BackSpace
		exit 0
		;;
	"topleftcorner")
		sxmo_appmenu.sh sys &
		exit 0
		;;
	"toprightcorner")
		sxmo_appmenu.sh scripts &
		exit 0
		;;
	"bottomleftcorner")
		sxmo_dmenu.sh close
		sxmo_hook_lock.sh
		sxmo_hook_screenoff.sh
		exit 0
		;;
	"bottomrightcorner")
		sxmo_rotate.sh &
		exit 0
		;;
esac
