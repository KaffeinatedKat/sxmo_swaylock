#!/bin/sh

. sxmo_common.sh

# This hook is called everytime the idle locker is updated (the screenoff hook manages its own idle locker)

if grep -q "unlock" "$SXMO_STATE" ; then
	idle_time="${SXMO_UNLOCK_IDLE_TIME:-120}"
elif grep -q off "$SXMO_STATE.screen" ; then
	# if locked and screen is off start going to idle
	idle_time=""
else
	idle_time=8
fi

sxmo_daemons.sh stop idle_locker

if ! [ -z "$idle_time" ] ; then
	# Go to lock after 120 seconds of inactivity
	if ! [ -e "$XDG_CACHE_HOME/sxmo/sxmo.noidle" ]; then
        	case "$SXMO_WM" in
	                sway)
                	        sxmo_daemons.sh start idle_locker sxmo_idle.sh -w \
        	                        timeout "$idle_time" 'sh -c "
	                                        swaymsg mode default;
                                        	sxmo_hook_lock.sh;
                                	        exec sxmo_hook_screenoff.sh
                        	        "'
                	        ;;
        	        dwm)
	                        sxmo_daemons.sh start idle_locker sxmo_idle.sh -w \
                        	        timeout "$idle_time" "sxmo_hook_lock.sh"
                	        ;;
        	esac
	fi
else
	# Start a periodic daemon (8s) "try to go to crust" after 8 seconds
	# Start a periodic daemon (2s) blink after 5 seconds
	# Resume tasks stop daemons
	sxmo_daemons.sh start idle_locker sxmo_idle.sh -w \
        	timeout 8 'sxmo_daemons.sh start going_deeper sxmo_run_periodically.sh 5 sh -c "sxmo_hook_check_state_mutexes.sh && exec sxmo_mutex.sh can_suspend holdexec sxmo_suspend.sh"' \
	        resume 'sxmo_daemons.sh stop going_deeper' \
	        timeout 5 'sxmo_daemons.sh start periodic_blink sxmo_run_periodically.sh 2 sxmo_uniq_exec.sh sxmo_led.sh blink red blue' \
	        resume 'sxmo_daemons.sh stop periodic_blink' \
	        timeout 12 'sxmo_daemons.sh start periodic_state_mutex_check sxmo_run_periodically.sh 10 sxmo_hook_check_state_mutexes.sh' \
	        resume 'sxmo_daemons.sh stop periodic_state_mutex_check'
fi
