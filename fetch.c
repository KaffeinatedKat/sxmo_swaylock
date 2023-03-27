#include "log.h"
#include "swaylock.h"
#include <errno.h>
#include <stdio.h>


int fetch_notifications(struct swaylock_state *state) {
	//memset(state->fetch.notification_buffer, 0, 4096);
	int buff_size = 0;
	int err = errno;
	

	if (pipe(state->fetch.out) == -1) {
		swaylock_log(LOG_ERROR, "Fetch notification: pipe failed: %s", strerror(err));
		return 1;
	}

	int pid = fork();

	if (pid == 0) {
		dup2(state->fetch.out[1], 1);

		char *args[] = { state->notifications_sh, NULL };
		execvp(state->notifications_sh, args);
		_exit(0);
	}


	int x = 0;
	while (1) {
		read(state->fetch.out[0], &state->fetch.notification_buffer, 1);

		if (*state->fetch.notification_buffer == '\n') {
			buff_size /= 10;
			break;
		}
		buff_size += (*state->fetch.notification_buffer - '0');
		buff_size *= 10;
		x++;
		if (x > 100) {
			swaylock_log(LOG_ERROR, "Notification script printed 100 values before the first newline, I doubt your notification list is a googol bytes long");
			return 1;
		}
	}

	//  Script returns size of 1 if there are no notifications
	if (buff_size <= 1) {
		return 0;
	}

	read(state->fetch.out[0], &state->fetch.notification_buffer, buff_size);
	swaylock_log(LOG_DEBUG, "Notification script length: %d", buff_size);

	return parse_notifications(state, state->fetch.notification_buffer, buff_size);
}

int parse_notifications(struct swaylock_state *state, char *notifs, int size) {
	size_t notif_size = 0;
	bool stamp = false;
	state->notification_amt = 0;
	state->stamp_amt = 0;
	state->notification_amt = 0;

	for (int i = 0; i < size; i++) {
		//  Store the current iteration position
		notif_size = i;
		//  Add to size till a newline is found
		while (notifs[notif_size] != '\n') { notif_size++; }
		//  Subtract i to get the size of the messages
		notif_size -= i;
		if (notif_size > 50) { notif_size = 50; }
		else if (notif_size <= 0) {
			return 0; //  End of output
		}

		//  Append to timestamp list
		if (stamp) {
			memcpy(state->notification_stamps[state->stamp_amt], notifs+i, notif_size);
			state->notification_stamps[state->stamp_amt++][notif_size] = '\0';
			stamp = false;
		//  Append the notification msg list
		} else {
			memcpy(state->notification_msgs[state->notification_amt], notifs+i, notif_size);
			state->notification_msgs[state->notification_amt++][notif_size] = '\0';
			stamp = true;
		}

		notif_size = 0;
		while (notifs[i] != '\n') { i++; }
	}

	return 0;
}
