#import <AppKit/AppKit.h>
#import "Controller.h"
// #import "CatLockController.h"
/*
 * Initialise and go!
 */

 //https://ios-developer.net/iphone-ipad-programmer/development/date-and-time/date-and-time-examples

int main(int argc, const char *argv[]) 
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    Controller *controller = [Controller new];
    [[NSApplication sharedApplication] setDelegate: controller];
    NSApplicationMain(argc, argv);
  }
}
