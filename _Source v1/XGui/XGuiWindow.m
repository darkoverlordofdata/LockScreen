#import "XGuiWindow.h"
/**
 * Base abstract class for X11 Controls
 */
@implementation XGuiWindow
@synthesize display = _display;
@synthesize screen = _screen;
@synthesize root =_root;
@synthesize width = _width;
@synthesize height = _height;
@synthesize cm = _cm;
@synthesize top = _top;
@synthesize active = _active;
@synthesize panel = _panel;
@synthesize lockedFilename = _lockedFilename;
@synthesize unlockFilename = _unlockFilename;
@synthesize pmap = _pmap;
@synthesize invisible = _invisible;

+ (id)sharedWindow {
    static XGuiWindow *_sharedWindow = nil;
    @synchronized(self) {
        if (_sharedWindow == nil)
            _sharedWindow = [[self alloc] init];
    }    return _sharedWindow;
}

- (void)setLockedImage:(NSString*) imagefilename {
    _lockedFilename = imagefilename;
}

- (void)setUnlockImage:(NSString*) imagefilename {
    _unlockFilename = imagefilename;
}

- (instancetype)init {
    if(!(_display = XOpenDisplay(0))) { 
        NSLog(@"Error: cannot open display");
        [NSApp terminate:nil];
    }
    _screen = DefaultScreen(_display);
    int depth = DefaultDepth(_display, _screen);
    _root = RootWindow(_display, _screen);

    _width = DisplayWidth(_display, _screen);
    _height = DisplayHeight(_display, _screen);

    _cm = DefaultColormap(_display, _screen);

    XColor bg = { 0, 0, 0, 0 }; // black
    XColor fg = { 0, 65535, 65535, 65535 }; // white

    XAllocColor(_display, _cm, &bg);
    XAllocColor(_display, _cm, &fg);

    /* Create the top level window */
    XSetWindowAttributes wa = { .override_redirect = 1, .background_pixel = bg.pixel };
    Visual *vis = DefaultVisual(_display, _screen);
    _top = XCreateWindow(_display, _root, 0, 0, _width, _height,
                      0, depth, CopyFromParent,
                      vis, CWOverrideRedirect | CWBackPixel, &wa);
    

    imlib_context_set_dither(1);
    imlib_context_set_display(_display);
    imlib_context_set_visual(vis);

    /* Load the top level background image */
    Imlib_Image image = imlib_load_image([_lockedFilename UTF8String]);
    imlib_context_set_image(image);
    int width = imlib_image_get_width();
    int height = imlib_image_get_height();

    /* Set the top level background image */
    Pixmap pixm = XCreatePixmap(_display, _top, width, height, depth);
    imlib_context_set_drawable(pixm);
    imlib_render_image_on_drawable(0, 0);
    XSetWindowBackgroundPixmap(_display, _top, pixm);
    XFreePixmap(_display, pixm);

    /* Load the panel background image */
    Imlib_Image box_image = imlib_load_image([_unlockFilename UTF8String]);
    imlib_context_set_image(box_image);
    int panel_width = imlib_image_get_width();
    int panel_height = imlib_image_get_height();

    // create the 2nd window
    _active = _panel = XCreateSimpleWindow(_display, _top, 0, 0, panel_width, panel_height,
                          0, fg.pixel, bg.pixel);

    Pixmap pix = XCreatePixmap(_display, _panel, panel_width, panel_height, depth);
    imlib_context_set_drawable(pix);
    imlib_render_image_on_drawable(0, 0);
    XSetWindowBackgroundPixmap(_display, _panel, pix);
    XFreePixmap(_display, pix);

    // // set color to white 
    XColor black, dummy;
    XRenderColor xrb = {.red = bg.red, .green = bg.green, .blue = bg.blue, .alpha = 0xffff };
    XRenderColor xrc = {.red = fg.red, .green = fg.green, .blue = fg.blue, .alpha = 0xffff };
    XftColorAllocValue(_display, DefaultVisual(_display, _screen), _cm, &xrb, &_bgcolor);
    XftColorAllocValue(_display, DefaultVisual(_display, _screen), _cm, &xrc, &_color);
    XAllocNamedColor(_display, _cm, "black", &black, &dummy);

    char curs[] = {0, 0, 0, 0, 0, 0, 0, 0};
    _pmap = XCreateBitmapFromData(_display, _top, curs, 8, 8);
    _invisible = XCreatePixmapCursor(_display, _pmap, _pmap, &black, &black, 0, 0);


    return self;
}


/**
* Locks window by 'grabbing' the keyboard and mouse
*/
- (BOOL)lock {
    int running = YES;
    int count;

    for(count = 1000; count; count--) {
        if(XGrabPointer(_display, _root, false,
                      ButtonPressMask | ButtonReleaseMask | PointerMotionMask,
                      GrabModeAsync, GrabModeAsync, None, _invisible, CurrentTime)
            == GrabSuccess) {
            break;
        }
        usleep(100);
    }

    if((running = running && (count > 0))) {
        for(count = 1000; count; count--) {
            if(XGrabKeyboard(_display, _root, true, GrabModeAsync, GrabModeAsync,
                        CurrentTime) == GrabSuccess) {
                break;
            }
            usleep(100);
        }
        running = (count > 0);
    }
    return running;
}


@end