#include "window_platform.h"

// Include platform-specific implementation
#if defined(__APPLE__)
#include "window_mac.m"
#elif defined(__linux__)
#include "window_linux.c"
#else
#error "Platform not supported"
#endif
