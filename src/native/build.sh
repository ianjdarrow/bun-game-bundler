#!/bin/bash

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM_SRC="src/native/window_mac.m"
    FRAMEWORKS="-framework Cocoa"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM_SRC="src/native/window_linux.c"
    FRAMEWORKS=""
else
    echo "Unsupported platform: $OSTYPE"
    exit 1
fi

# Set variables
OUTPUT="build/libwindow.dylib"

# Compile the shared library
clang -o $OUTPUT $PLATFORM_SRC -shared -fobjc-arc $FRAMEWORKS

# Display result
if [ $? -eq 0 ]; then
    echo "Build successful! Output: $OUTPUT"
else
    echo "Build failed."
fi
