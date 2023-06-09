#ifndef _SWAYLOCK_H
#define _SWAYLOCK_H
#include <stdbool.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <poll.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <errno.h>
#include <wayland-client.h>
#include "background-image.h"
#include "cairo.h"
#include "pool-buffer.h"
#include "seat.h"
#include "effects.h"
#include "fade.h"
#include "wlr-layer-shell-unstable-v1-client-protocol.h"

enum auth_state {
	AUTH_STATE_IDLE,
	AUTH_STATE_CLEAR,
	AUTH_STATE_INPUT,
	AUTH_STATE_INPUT_NOP,
	AUTH_STATE_BACKSPACE,
	AUTH_STATE_VALIDATING,
	AUTH_STATE_INVALID,
	AUTH_STATE_GRACE,
};

enum box_type {
	TYPE_RENDER_KEY,
	TYPE_RENDER_NOTIFICATION,
};


struct swaylock_fetch {
	int out[2];
	char notification_buffer[4096];
};

struct swaylock_colorset {
	uint32_t input;
	uint32_t cleared;
	uint32_t caps_lock;
	uint32_t verifying;
	uint32_t wrong;
};

struct swaylock_colors {
	uint32_t battery;
	uint32_t battery_charging;
	uint32_t battery_critical;
	uint32_t background;
	uint32_t bs_highlight;
	uint32_t key_highlight;
	uint32_t caps_lock_bs_highlight;
	uint32_t caps_lock_key_highlight;
	uint32_t separator;
	uint32_t layout_background;
	uint32_t layout_border;
	uint32_t layout_text;
	struct swaylock_colorset inside;
	struct swaylock_colorset line;
	struct swaylock_colorset ring;
	struct swaylock_colorset text;
	struct swaylock_colorset notif_text;
	struct swaylock_colorset notif_time_text;
};

struct swaylock_args {
	struct swaylock_colors colors; enum background_mode mode;
	char *font;
	char *shell_dir;
	char *notification_dir;
	char *battery_path;
	uint32_t battery_path_len;
	uint32_t battery_critical;
	uint32_t battery_fetch;
	uint32_t shell_dir_len;
	uint32_t margin; 
	uint32_t font_size;
	uint32_t radius;
	uint32_t thickness;
	uint32_t indicator_x_position;
	uint32_t indicator_y_position;
	uint32_t indicator_length;
	uint32_t notification_count;
	bool battery_indicator;
	bool notifications;
	bool music;
	bool override_indicator_x_position;
	bool override_indicator_y_position;
	bool override_indicator_length;
	bool swipe_gestures;
	bool ignore_empty;
	bool show_indicator;
	bool show_keypad;
	bool show_music;
	bool show_quickaction;
	bool show_caps_lock_text;
	bool show_caps_lock_indicator;
	bool show_keyboard_layout;
	bool hide_keyboard_layout;
	bool show_failed_attempts;
	bool daemonize;
	bool indicator_idle_visible;

	bool screenshots;
	struct swaylock_effect *effects;
	int effects_count;
	bool time_effects;
	bool indicator;
	bool clock;
	char *timestr;
	char *datestr;
	uint32_t fade_in;
	bool allow_fade;
	bool password_submit_on_touch;
	uint32_t password_grace_period;
	bool password_grace_no_mouse;
	bool password_grace_no_touch;
};

struct swaylock_password {
	size_t len;
	char buffer[1024];
};

struct swaylock_state {
	struct loop *eventloop;
	struct loop_timer *clear_indicator_timer; // clears the indicator
	struct loop_timer *clear_password_timer;  // clears the password buffer
	struct wl_display *display;
	struct wl_compositor *compositor;
	struct wl_subcompositor *subcompositor;
	struct zwlr_layer_shell_v1 *layer_shell;
	struct zwlr_input_inhibit_manager_v1 *input_inhibit_manager;
	struct zwlr_screencopy_manager_v1 *screencopy_manager;
	struct wl_shm *shm;
	struct swaylock_fetch fetch;
	struct wl_list surfaces;
	struct wl_list images;
	struct swaylock_args args;
	struct swaylock_password password;
	struct swaylock_xkb xkb;
	enum auth_state auth_state;
	char* notifications_sh;
	char notification_msgs[5][51], notification_stamps[5][51];
	size_t notification_amt, stamp_amt;
	int swipe_x[50], swipe_y[50], swipe_count;
	bool indicator_dirty;
	char *battery_capacity_path;
	char *battery_status_path;
	char battery_capacity[3];
	char battery_status[1];
	bool battery_charging;
	int render_randnum;
	int failed_attempts;
	size_t n_screenshots_done;
	bool run_display;
	struct zxdg_output_manager_v1 *zxdg_output_manager;
	struct ext_session_lock_manager_v1 *ext_session_lock_manager_v1;
	struct ext_session_lock_v1 *ext_session_lock_v1;
};

struct swaylock_surface {
	cairo_surface_t *image;
	struct {
		uint32_t format, width, height, stride;
		enum wl_output_transform transform;
		void *data;
		cairo_surface_t *original_image;
		struct swaylock_image *image;
	} screencopy;
	struct swaylock_state *state;
	struct wl_output *output;
	uint32_t output_global_name;
	struct zxdg_output_v1 *xdg_output;
	struct wl_surface *indicator_child; // surface made into subsurface
	struct wl_subsurface *indicator_subsurface;
	struct wl_surface *surface;
	struct wl_surface *child; // surface made into subsurface
	struct wl_subsurface *subsurface;
	struct wl_surface *keypad_child;
	struct wl_subsurface *keypad_subsurface;
	struct wl_surface *notification_child;
	struct wl_subsurface *notification_subsurface;
	struct zwlr_layer_surface_v1 *layer_surface;
	struct zwlr_screencopy_frame_v1 *screencopy_frame;
	struct ext_session_lock_surface_v1 *ext_session_lock_surface_v1;
	struct pool_buffer buffers[2];
	struct pool_buffer indicator_buffers[2];
	struct pool_buffer keypad_buffers[2];
    struct pool_buffer notification_buffers[2];
	struct pool_buffer *current_buffer;
	struct swaylock_fade fade;
	int events_pending;
	bool configured;
	bool frame_pending, dirty;
	uint32_t width, height;
	uint32_t indicator_width, indicator_height;
	uint32_t keypad_width, keypad_height;
	uint32_t notification_witdh, notification_height;
	int32_t scale;
	enum wl_output_subpixel subpixel;
	enum wl_output_transform transform;
	char *output_name;
	struct wl_list link;
};

// There is exactly one swaylock_image for each -i argument
struct swaylock_image {
	char *path;
	char *output_name;
	cairo_surface_t *cairo_surface;
	struct wl_list link;
};

cairo_t *cairo_init(struct swaylock_surface *surface);
void swaylock_handle_key(struct swaylock_state *state,
		xkb_keysym_t keysym, uint32_t codepoint);
void swaylock_handle_mouse(struct swaylock_state *state);
void swaylock_handle_touch(struct swaylock_state *state);
void render_frame_background(struct swaylock_surface *surface, bool commit);
void render_background_fade(struct swaylock_surface *surface, uint32_t time);
void render_indicator_frame(struct swaylock_surface *surface);
void render_keypad_frame(struct swaylock_surface *surface);
void render_notification_frame(struct swaylock_surface *surface);
void render_frames(struct swaylock_state *state);
void render_notifications(cairo_t *cario, struct swaylock_state *state, int spacing,
		int key_height, int key_width, int pos_x, int pos_y);
void draw_button(cairo_t *cairo, struct swaylock_surface *surface, char *text, int buffer_width, int buffer_height, 
		int x_divisions, int y_divisions, int x_pos, int y_pos);
void damage_surface(struct swaylock_surface *surface);
void damage_state(struct swaylock_state *state);
void clear_password_buffer(struct swaylock_password *pw);
void schedule_indicator_clear(struct swaylock_state *state);

void initialize_pw_backend(int argc, char **argv);
void run_pw_backend_child(void);
void clear_buffer(char *buf, size_t size);

int fetch_notifications(struct swaylock_state *state);
int parse_notifications(struct swaylock_state *state, char *notifs, int size);
int fetch_battery();

#endif
