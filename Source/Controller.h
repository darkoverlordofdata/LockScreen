#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "LockWindow.h"

@interface Controller : NSObject
{
    LockWindow *window;

}

- (void)applicationWillFinishLaunching:(NSNotification *) not;
- (void)applicationDidFinishLaunching:(NSNotification *) not;

@end