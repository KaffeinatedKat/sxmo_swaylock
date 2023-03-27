#!/bin/bash

# Include common sxmo definitions
#. sxmo_common.sh

DATE="$(date +%s)"

get_sxmo_notifs() {
    for NOTIFFILE in $(ls -tr "$SXMO_NOTFIDIR"); do
        # The message of the notification
        MSG="$(tail -n+3 "$SXMO_NOTIFDIR/$NOTIFFILE" | tr "\n^" " ")"


    done
}

get_notifs() {
    NOTIFS=""
    for NOTIFFILE in $(ls -tr "$1"); do
        MSG="$(tail -n+3 "$1/$NOTIFFILE" | tr "\n^" " ")"
NOTIFS="$MSG
$(time_string "$1/$NOTIFFILE")
$NOTIFS"

    done

    printf "%d\n%s" "$(echo $NOTIFS | wc -c)" "$NOTIFS"
}

time_string() {
    FILEDATE="$(stat --printf %X $1 | cut -d'.' -f1)"
    SECONDS=$(($DATE - $FILEDATE))

    if [ ${SECONDS} -lt 60 ]; then
        echo "Now"
    elif [ $(($SECONDS / 60)) -lt 60 ]; then
        echo "$(($SECONDS / 60))m ago"
    elif [ $(($SECONDS / 60 / 60)) -lt 24 ]; then
        echo "$(($SECONDS / 60 / 60))h ago"
    elif [ $(($SECONDS / 60 / 60)) -lt 48 ]; then
        echo "Yesterday at $(date -d @$FILEDATE +%R)"
    else
        echo "$(date -d @$FILEDATE +"%Y-%m-%d")"
    fi
}

get_notifs "/home/coffee/swaylock-effects/notifs/"
