

# sxmo_swaylock notifications

sxmo_swaylock has support to display notifications, which are fetched via the shell script [notifications.sh](https://github.com/KaffeinatedKat/sxmo_swaylock/blob/master/scripts/notifications.sh)

# Using notifications

```
--notifications
    Display notifications *--shell-directory must be set*
    
--notification-count
    Number of notifications to display before displaying "+x more"

--shell-directory
    The directory to look for 'notifications.sh' in
```

# Notification fetching

By default `notifications.sh` pulls in sxmo_common.sh and reads from the files in `$SXMO_NOTIFDIR`. It uses a shell script to support the easy creation of different notification fetch methods other than sxmo.

## Shell script requirements 

If you wish to modify `notifications.sh`, it has to output notifications in a very specific way. The format is as follows

```
[length of output (not including this number)]
[notification 1]
[notification time string]
. . .
```

Be sure to include a '\n' after each notification/timestamp 



