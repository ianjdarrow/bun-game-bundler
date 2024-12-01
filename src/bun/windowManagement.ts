import { dlopen, FFIType, suffix } from "bun:ffi";
import { join } from "path";

// Define the interface for our native functions
const nativeApi = {
  create_fullscreen_window: {
    args: [FFIType.cstring],
    returns: FFIType.bool,
  },
  window_should_close: {
    args: [],
    returns: FFIType.bool,
  },
  destroy_window: {
    args: [],
    returns: FFIType.void,
  },
} as const;

// Load the native library
const libPath = join(import.meta.dir, `../../build/libwindow.${suffix}`);
const { symbols } = dlopen(libPath, nativeApi);

export class GameWindow {
  private isOpen: boolean = false;
  private pollInterval: Timer | null = null;

  constructor() {
    // Ensure cleanup on process exit
    process.on("exit", () => this.close());
  }

  /**
   * Opens a fullscreen window with the specified title
   * Returns a promise that resolves when the window is ready
   */
  async open(title: string = "Game Window"): Promise<void> {
    if (this.isOpen) {
      throw new Error("Window is already open");
    }

    const success = symbols.create_fullscreen_window(
      Buffer.from(title + "\0", "utf-8")
    );
    if (!success) {
      throw new Error("Failed to create window");
    }

    this.isOpen = true;

    // Start polling for window close events
    this.pollInterval = setInterval(() => {
      if (symbols.window_should_close()) {
        this.close();
      }
    }, 16); // Poll at roughly 60fps
  }

  /**
   * Closes the window and cleans up resources
   */
  close(): void {
    if (!this.isOpen) return;

    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }

    symbols.destroy_window();
    this.isOpen = false;
  }

  /**
   * Checks if the window is currently open
   */
  isWindowOpen(): boolean {
    return this.isOpen;
  }
}

// Export a singleton instance
export const gameWindow = new GameWindow();
