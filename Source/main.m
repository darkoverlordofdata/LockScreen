#import <AppKit/AppKit.h>
#import "Controller.h"
// #import "CatLockController.h"
/*
 * Initialise and go!
 */

int main(int argc, const char *argv[]) 
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    Controller *controller = [Controller new];
    [[NSApplication sharedApplication] setDelegate: controller];
    NSLog(@"NSHomeDirectory= %@", NSHomeDirectory());

    NSApplicationMain(argc, argv);

  }
}
