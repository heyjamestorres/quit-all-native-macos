#import <AppKit/AppKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSSet<NSString *> *excludedBundleIdentifiers;
@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        // Finder is deliberately preserved. Most of the other processes are not
        // normal foreground apps, but are listed defensively so they can never be
        // targeted if a future macOS release classifies them differently.
        _excludedBundleIdentifiers = [NSSet setWithArray:@[
            @"com.apple.finder",
            @"com.apple.dock",
            @"com.apple.SystemUIServer",
            @"com.apple.loginwindow",
            @"com.apple.WindowManager",
            @"com.apphousekitchen.aldente-pro"
        ]];
    }
    return self;
}

- (BOOL)isAlDente:(NSRunningApplication *)application {
    NSString *name = application.localizedName ?: @"";
    return [name compare:@"AlDente"
                 options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)] == NSOrderedSame;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    pid_t ownPID = NSProcessInfo.processInfo.processIdentifier;

    #if !defined(QUITALL_DRY_RUN)
    // Finder is a permanent part of the macOS desktop and relaunches when quit.
    // Closing its windows gives the expected result without disrupting the
    // desktop. macOS asks for Finder Automation permission on the first run.
    NSAppleScript *closeFinderWindows = [[NSAppleScript alloc]
        initWithSource:@"tell application \"Finder\" to close every window"];
    NSDictionary<NSString *, id> *scriptError = nil;
    [closeFinderWindows executeAndReturnError:&scriptError];
    #endif

    for (NSRunningApplication *application in NSWorkspace.sharedWorkspace.runningApplications) {
        NSString *bundleIdentifier = application.bundleIdentifier ?: @"";
        BOOL shouldQuit = application.processIdentifier != ownPID
            && application.activationPolicy == NSApplicationActivationPolicyRegular
            && !application.terminated
            && ![self.excludedBundleIdentifiers containsObject:bundleIdentifier]
            && ![self isAlDente:application];

        #if defined(QUITALL_DRY_RUN)
        const char *name = (application.localizedName ?: @"(unnamed)").UTF8String;
        const char *identifier = bundleIdentifier.UTF8String;
        fprintf(stdout, "%s\t%s\t%s\n", shouldQuit ? "QUIT" : "KEEP", name, identifier);
        #else
        if (shouldQuit) {
            // Ask, don't force. Apps with unsaved work can show their normal save
            // interface or decline the termination request.
            [application terminate];
        }
        #endif
    }

    #if defined(QUITALL_DRY_RUN)
    fflush(stdout);
    exit(EXIT_SUCCESS);
    #else
    [NSApp terminate:nil];
    #endif
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        #if defined(QUITALL_DRY_RUN)
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [delegate applicationDidFinishLaunching:nil];
        #else
        NSApplication *application = NSApplication.sharedApplication;
        AppDelegate *delegate = [[AppDelegate alloc] init];
        application.delegate = delegate;
        [application setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [application run];
        #endif
    }
    return 0;
}
