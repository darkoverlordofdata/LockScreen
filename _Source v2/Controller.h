#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Imlib2.h>
#import "Application.h"

// #import "LockWindow.h"
@class Application;

@interface Controller : NSObject
{
    Application *app;
}


- (void)applicationWillFinishLaunching:(NSNotification *) aNotification;
- (void)applicationDidFinishLaunching:(NSNotification *) aNotification;

@end