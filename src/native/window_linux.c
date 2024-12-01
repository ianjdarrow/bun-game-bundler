#include <stdio.h>
#include "window_platform.h"

void launch_fullscreen_window(const char *title) {
    printf("Launching fullscreen window on Linux: %s\n", title);
    // TODO: Implement X11 or Wayland support
}

void destroy_window() {
    printf("Destroying fullscreen window on Linux\n");
    // TODO: Implement X11 or Wayland cleanup
}
