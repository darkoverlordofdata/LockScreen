#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Imlib2.h>
/**
 * Base abstract class for X11 Controls
 */
@interface XGuiControl : NSObject
{
    NSRect _bounds;
    NSMutableArray *_controls;
    
}

- (instancetype)init;

@end