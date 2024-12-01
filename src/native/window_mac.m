/*
 * MacOS Window Handler for Fullscreen Games
 * ---------------------------------------
 *
 * Creating a clean fullscreen window in macOS is surprisingly tricky due to how
 * the operating system handles window creation and fullscreen transitions.
 *
 * The Challenge:
 * -------------
 * macOS's window system is built around the concept of standard windows that can
 * optionally enter fullscreen mode. Simply creating a borderless window at screen size
 * doesn't integrate properly with macOS's window management, Spaces, or Mission Control.
 * Additionally, the transition to fullscreen mode is normally animated, which can
 * cause visual artifacts if not handled carefully.
 *
 * The Solution:
 * ------------
 * The key insight is that we must:
 * 1. Create a standard window (with normal chrome/decorations) first
 * 2. Configure it for fullscreen operation before showing it
 * 3. Request the transition to fullscreen while the window is still invisible
 * 4. Only then make the window visible
 *
 * This approach works because macOS will honor the fullscreen request on an invisible
 * window, and when the window becomes visible, it will already be in fullscreen mode
 * or transitioning to it. This prevents any visible "jumping" or intermediate states.
 *
 * Important Implementation Details:
 * ------------------------------
 * - We use NSWindowCollectionBehaviorFullScreenPrimary to properly integrate with
 *   macOS's window management system
 * - The initial window must have standard window styling (NSWindowStyleMaskTitled)
 *   for proper fullscreen behavior
 * - We maintain an autorelease pool to handle memory management correctly
 * - The window delegate tracks window close requests for clean shutdown
 *
 * Usage Notes:
 * -----------
 * The window creation is designed to be synchronous and will return true when
 * the window has been created and is entering fullscreen mode. The actual
 * fullscreen transition may still be in progress when the function returns.
 */

#import <Cocoa/Cocoa.h>

@interface GameWindowDelegate : NSObject <NSWindowDelegate>
@property (atomic) bool windowShouldClose;
@end

@implementation GameWindowDelegate
@synthesize windowShouldClose;

- (id)init {
    self = [super init];
    if (self) {
        self.windowShouldClose = false;
    }
    return self;
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    self.windowShouldClose = true;
    return YES;
}
@end

static NSWindow* gameWindow = nil;
static GameWindowDelegate* windowDelegate = nil;

void initialize_cocoa() {
    if (!NSApp) {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        NSMenu *mainMenu = [NSMenu new];
        [NSApp setMainMenu:mainMenu];

        [NSApp activateIgnoringOtherApps:YES];
        [NSApp finishLaunching];
    }
}

bool create_fullscreen_window(const char* title) {
    @autoreleasepool {
        initialize_cocoa();

        if (gameWindow != nil) {
            return false;
        }

        NSRect screenFrame = [[NSScreen mainScreen] frame];

        // Create window with minimal visible frame initially
        NSRect initialFrame = NSMakeRect(
            NSMidX(screenFrame) - 400,
            NSMidY(screenFrame) - 300,
            800,
            600
        );

        gameWindow = [[NSWindow alloc]
            initWithContentRect:initialFrame
            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
            backing:NSBackingStoreBuffered
            defer:NO];

        // Configure window
        [gameWindow setTitle:@(title)];
        [gameWindow setReleasedWhenClosed:NO];
        [gameWindow setAcceptsMouseMovedEvents:YES];
        [gameWindow setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
        [gameWindow setBackgroundColor:[NSColor blackColor]];

        // Configure content view
        NSView *contentView = [gameWindow contentView];
        contentView.wantsLayer = YES;
        contentView.layer.backgroundColor = [NSColor blackColor].CGColor;

        windowDelegate = [[GameWindowDelegate alloc] init];
        [gameWindow setDelegate:windowDelegate];

        // Toggle fullscreen *before* showing the window
        [gameWindow toggleFullScreen:nil];

        // Now make the window key and front
        [gameWindow makeKeyAndOrderFront:nil];

        return true;
    }
}


bool window_should_close() {
    return windowDelegate ? windowDelegate.windowShouldClose : false;
}

void destroy_window() {
    @autoreleasepool {
        if (gameWindow != nil) {
            if ([gameWindow styleMask] & NSWindowStyleMaskFullScreen) {
                [gameWindow toggleFullScreen:nil];
            }
            [gameWindow close];
            gameWindow = nil;
        }

        if (windowDelegate != nil) {
            windowDelegate = nil;
        }
    }
}