#ifndef WINDOW_PLATFORM_H
#define WINDOW_PLATFORM_H

#ifdef __cplusplus
extern "C" {
#endif

// Launch a fullscreen window with the specified title
void launch_fullscreen_window(const char *title);

// Destroy the fullscreen window
void destroy_window();

#ifdef __cplusplus
}
#endif

#endif // WINDOW_PLATFORM_H
