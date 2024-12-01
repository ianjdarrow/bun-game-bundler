# **bun-game-bundler**

an ultralight framework for cross-platform JS fullscreen games

#### bun-game-bundler is in the very earliest stages of development and is not suitable for anything yet. PRs welcome!

---

## **1. Motivation**

I wanted a way to build cross-platform games using Three.js. Cross-platform support for pointer locking is bad, so I built a minimal game framework similar to Tauri but smaller in scope.

It helps you do four useful things:

- Render a cross-platform fullscreen webview (where you can load three.js code, html, whatever you want)
- Lock the cursor, and access mouse position and cumulative deltas on any platform for a controlled cursor (for things like FPS infinite pan or controlling native window interactions)
- Write game UI elements in React or your preferred framework and interact with them with controlled cursors.
- Serve game assets locally (with very basic optimizations)

### Usage examples

[to be added once implemented]

---

## **2. Design Principles**

This framework was built with a few guiding principles to keep it focused, performant, and approachable:

- Minimalism: It does only what’s necessary and nothing more. If it can be handled effectively in JavaScript, it’s left out.
- Platform Independence: Everything relies on public APIs to ensure it works seamlessly across platforms.
- Developer-Friendly Defaults: Clear, simple defaults with the flexibility to configure as needed.
- Responsiveness: Latency is kept to a bare minimum to ensure smooth interactions.
- Indie Focus: Tailored for solo developers or small teams, prioritizing ease of use and quick iteration over extensive setup.

---

## **3. Architecture**

The framework is divided into three layers:

### **3.1 Game Layer**

The game layer includes APIs, utilities, and tools directly used by developers to implement game logic and rendering. It is framework-agnostic but supports integration with tools like React.

**Responsibilities:**

- Provide hooks and utilities for managing pointer lock, mouse input, and DOM interactions.
- Simplify UI integration through event simulation.
- Provide APIs for loading assets into Three.js.

---

### **3.2 Bun Layer**

The Bun layer serves as the intermediary between the Game Layer and the Native Layer. It handles communication with native modules, manages asset pipelines, and exposes necessary APIs to the Game Layer.

**Responsibilities:**

- Use `bun:ffi` to interact with native libraries.
- Serve assets efficiently using Bun’s built-in tools.
- Handle pointer lock requests and raw mouse input forwarding.
- Handle hot module reloading in development

---

### **3.3 Native Layer**

The native layer is implemented in platform-specific languages (C, Objective-C, etc.) and provides low-level capabilities that cannot be addressed in higher layers. We implement and build for each OS separately.

**Responsibilities:**

- Create and manage fullscreen windows.
- Capture raw mouse input and manage pointer lock.
- Expose a minimal set of public functions for Bun to call.

---

### **Diagram**

```
+--------------------------+        +--------------------------+
|       Game Layer         |        |       Native Layer       |
| - Pointer lock hooks     |        | - Fullscreen management  |
| - Mouse input utilities  | <----> | - Raw input handling     |
| - Asset loading          |        | - Shared memory setup    |
+--------------------------+        +--------------------------+
                |                            |
                |          Bun Layer         |
                | - `bun:ffi` bindings       |
                | - Asset pipeline           |
                +----------------------------+
```

---

## **4. Project Structure**

```
/project-root
│
├── /src
│   ├── /game
│   │   ├── controlledPointer.ts   // Pointer lock hook
│   │   ├── uiIntegration.ts       // DOM simulation tools
│   │   ├── assetLoader.ts         // Asset loading API
│   │   └── index.ts               // Exports for the game layer
│   │
│   ├── /bun
│   │   ├── mouseInput.ts          // Bun FFI mouse input bridge
│   │   ├── windowManagement.ts    // Fullscreen management
│   │   ├── sharedMemory.ts        // SharedArrayBuffer setup
│   │   └── index.ts               // Exports for the Bun layer
│   │
│   ├── /native
│   │   ├── window.h               // Cross-platform interface
│   │   ├── window_mac.m           // MacOS window handling
│   │   ├── mouse_mac.m            // MacOS mouse handling
│   │   ├── window_x86.c           // Windows window handling
│   │   ├── mouse_x86.c            // Windows mouse handling
│   │   ├── window_linux.c         // Linux window handling
│   │   ├── mouse_linux.c          // Linux mouse handling
│   │   ├── mouse.c                // Raw mouse input handler
│   │   ├── window.c               // Fullscreen window manager
│   │   └── sharedMemory.c         // Shared memory allocation
│   │
│   └── /types
│       └── index.d.ts             // TypeScript definitions
│
├── bunfig.toml                    // Bun configuration
├── package.json                   // NPM package metadata
└── README.md                      // Project documentation
```

---

## **5. Interfaces**

### **5.1 Game Layer**

#### **Pointer Lock Hook**

```typescript
/**
 * Provides pointer lock state and mouse input data.
 *
 * Exposed to developers for game logic integration.
 *
 * To discuss: correct interface w/ raw mouse input <> DOM requirements?
 */
export function useControlledPointer(): {
  isLocked: boolean;
  lock: () => Promise<void>;
  unlock: () => void;
  pos: () => {
    x: number;
    y: number;
    deltaX: number;
    deltaY: number;
  };
};
```

#### **UI Integration**

```typescript
/**
 * Registers a UI container for handling synthetic DOM events.
 *
 * Transforms raw mouse input into DOM-compatible events.
 */
export function registerUIContainer(container: HTMLElement): void;
```

#### **Asset Loader**

```typescript
/**
 * Provides URLs for assets served by Bun.
 *
 * Simplifies integration with Three.js loaders.
 */
export function getAssetURL(path: string): string;
```

---

### **5.2 Bun Layer**

#### **Mouse Input**

```typescript
/**
 * Initializes mouse input tracking and writes data to a shared buffer.
 */
export function initializeMouseInput(buffer: SharedArrayBuffer): void;
export function lockPointer(): void;
export function unlockPointer(): void;
```

#### **Window Management**

```typescript
/**
 * Launches a fullscreen window with specified configurations.
 */
export async function launchGameWindow(options?: {
  title?: string;
  width?: number;
  height?: number;
  resizable?: boolean;
}): Promise<void>;
```

#### **Shared Memory**

```typescript
/**
 * Allocates and clears shared memory for inter-process communication.
 */
export function createSharedMouseBuffer(): SharedArrayBuffer;
export function clearSharedBuffer(buffer: SharedArrayBuffer): void;
```

---

### **5.3 Native Layer**

#### **Mouse Input (C)**

```c
// Handles raw mouse input and writes to the shared memory buffer.
void initialize_mouse_input(SharedMemory* buffer);
void lock_pointer(); // implies hiding system cursor
void unlock_pointer(); // implies unhiding system cursor
```

#### **Window Management (C)**

```c
// Creates and manages a fullscreen window.
void launch_fullscreen_window(const char* title, int width, int height, int resizable);
void destroy_window();
```

#### **Shared Memory (C)**

```c
// Allocates a shared memory buffer for input data.
SharedMemory* create_shared_memory(size_t size);
void clear_shared_memory(SharedMemory* buffer);
```

---

## **6. Limitations**

1. **Fullscreen Only:** The framework does not support windowed or multi-monitor setups.
2. **Mouse Input Only:** Keyboard, touch, and gamepad inputs are out of scope.
3. **No Asset Optimization:** Basic asset serving is provided without additional optimizations.
4. **Cross-Browser Constraints:** Requires `SharedArrayBuffer` support with appropriate headers.
5. **Simplified UI Integration:** UI containers must be fullscreen and do not support nested overlays.

---

## **7. Testing Notes**

- **Cross-Platform Validation:**
  - Test fullscreen rendering, input latency, and DPI scaling on Windows, macOS, and Linux.
- **Input Performance:**
  - Verify that mouse input is captured with minimal latency (<1ms).
- **Security Compliance:**
  - Ensure correct `COOP` and `COEP` headers are set for `SharedArrayBuffer` usage.
