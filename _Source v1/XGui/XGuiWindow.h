#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Imlib2.h>
#import <X11/Xlib.h>
#import <Xft/Xft.h>
#import "XGuiControl.h"
/**
 * Base abstract class for X11 Controls
 */
@interface XGuiWindow : XGuiControl
{
    Display *_display;
    Window _root;
    int _screen;
    int _width;
    int _height;
    Colormap _cm;
    Window _top;
    Window _active;
    Window _panel;
    NSString *_lockedFilename;
    NSString *_unlockFilename;
    Pixmap _pmap;
    Cursor _invisible;
    XftColor _color;        // color to draw
    XftColor _bgcolor;      // color tp draw

}
@property (nonatomic, assign) Display *display;
@property (nonatomic, assign) Window root;
@property (nonatomic, assign) int screen;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) Colormap cm;
@property (nonatomic, assign) Window top;
@property (nonatomic, assign) Window active;
@property (nonatomic, assign) Window panel;
@property (nonatomic, retain) NSString *lockedFilename;
@property (nonatomic, retain) NSString *unlockFilename;
@property (nonatomic, assign) Pixmap pmap;
@property (nonatomic, assign) Cursor invisible;

+ (id)sharedWindow;

- (void)setLockedImage:(NSString*) imagefilename;
- (void)setUnlockImage:(NSString*) imagefilename;
- (instancetype)init;
- (BOOL)lock;

@end