#include <unistd.h>
#include <stdio.h>

//#include "swaylock.h"

void fetch_notifications(/*struct swaylock_state *state*/) {
	int out[2];
	char buff[2048];

	if (pipe(out) == -1) { 
		printf("pipe failed"); 
		return;
	}

	int pid = fork();

	if (pid == 0) {
		dup2(out[1], 1);

		char *args[] = { "/home/coffee/swaylock-effects/scripts/notifications.sh", "/home/coffee/swaylock-effects/notifs/", NULL };
		execvp("/home/coffee/swaylock-effects/scripts/notifications.sh", args);
	}

	read(out[0], buff, 2048);
	printf("notifications: %s\n", buff);
}


int main(void) {
	fetch_notifications();
}
