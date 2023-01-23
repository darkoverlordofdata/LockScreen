#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Imlib2.h>
#import <X11/Xlib.h>
#import <Xft/Xft.h>
#import "XGuiControl.h"
/**
 * X11 Label Class
 */
@interface XGuiLabel : XGuiControl
{
    int _x;
    int _y;
    BOOL _visible;
    XftColor _color;        // color to draw
    XftColor _bgcolor;      // color tp draw
    NSString *_text;
    XftFont *_font;
    XftDraw *_surface;      // drawable


}

- (instancetype)init;
- (void) draw;
- (void) move: (NSPoint) to;
- (void) setFont:(XftFont*) font;
- (void) setText: (NSString*) text;
- (void) setVisible: (BOOL) visible;

@end