#import "Controller.h"

@implementation Controller

- (void) applicationWillFinishLaunching: (NSNotification *)aNotification;
{

}

- (void) applicationDidFinishLaunching: (NSNotification *) not
{
    window = [LockWindow new];
    [window setDelegate:self];
    // [window setLevel:kCGMainMenuWindowLevel-1];
    // [window setCollectionBehavior:NSWindowCollectionBehaviorStationary|NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];

}

@end