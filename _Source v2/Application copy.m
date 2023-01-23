#import "Application.h"


#define BUFLEN 256

@implementation Application

- (void)setLockedImage:(NSString*) imagefilename {
    _imgfn = imagefilename;
}

- (void)setUnlockImage:(NSString*) imagefilename {
    _boximgfn = imagefilename;
}


- (instancetype)initWithOptions: (NSMutableDictionary*) options {
	_dateFormatter = [[NSDateFormatter alloc] init];
    _buf = calloc(BUFLEN, sizeof(char));
    _running = YES;
    // from command line args
    _pin = [[NSString alloc] initWithString:options[@"pin"]];
    _font = [[NSString alloc] initWithString:options[@"font"]];
    _theme =  [[NSString alloc] initWithString:options[@"theme"]];
    _full =  [[NSString alloc] initWithString:options[@"name"]];
    _user =  [[NSString alloc] initWithString:options[@"user"]];
    _debug =  [[NSString alloc] initWithString:options[@"debug"]];

    return self;

}


- (void)run {
    [self createWindow];
    _running = [self lock];


    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Start Timer!");
        NSTimer* timer = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(onTimerTick1:) userInfo:self repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer: timer forMode:NSDefaultRunLoopMode];
    });


    [self loop];
    [self dispose];
    [NSApp terminate:nil];

}

- (void)createWindow {
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
    Imlib_Image image = imlib_load_image([_imgfn UTF8String]);
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
    Imlib_Image box_image = imlib_load_image([_boximgfn UTF8String]);
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
/**
 * Expand the base font name to all required sizes
 */
- (void)setFonts:(NSString *) name {

    _fontnameSmall = [[_font stringByAppendingString:@"8"] mutableCopy];
    _fontnameName = [[_font stringByAppendingString:@"24"] mutableCopy];
    _fontnamePwd = [[_font stringByAppendingString:@"24"] mutableCopy];
    _fontnameDate = [[_font stringByAppendingString:@"32"] mutableCopy];
    _fontnameTime = [[_font stringByAppendingString:@"64"] mutableCopy];

    _fontName = XftFontOpenName(_display, _screen, [_fontnameName UTF8String]);
    if (_fontName == NULL) {
        NSLog(@"font \"%s\" does not exist\n", [_fontnameBase UTF8String]);
        [self setFonts:@"6x10-"];
        _fontName = XftFontOpenName(_display, _screen, [_fontnameName UTF8String]);
    }
  
    _fontSmall = XftFontOpenName(_display, _screen, [_fontnameSmall UTF8String]);
    _fontPwd = XftFontOpenName(_display, _screen, [_fontnamePwd UTF8String]);
    _fontTime = XftFontOpenName(_display, _screen, [_fontnameTime UTF8String]);
    _fontDate = XftFontOpenName(_display, _screen, [_fontnameDate UTF8String]);

}

/**
 * Draw a frame
 */
- (void)draw {
	NSDate *now = [NSDate date];

	[_dateFormatter setDateFormat:@"hh:mm a"];
	_tline = [[_dateFormatter stringFromDate:now] mutableCopy];

	[_dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
	_dline = [[_dateFormatter stringFromDate:now] mutableCopy];

    NSString *instruc = @"Enter PIN";

    XClearWindow(_display, _active);

    /**
     * rough stab at font metrics...
     * 300 pixels wide fits about 17-18 chars at 24 pt. 
     */
    const float fac24 = 300.0f/17.0f;
    /** 
     * and 8pt is 1/3 of 24 pt... 
     */
    const float fac08 = (300.0f/17.0f)/3.0f;

    int c = (_width-(int)([_uline length] * fac24))/2;
    int c1 = ((_width-300)/2);
    int c2 = (_width- (int)([instruc length] * fac08))/2;

    switch (_state) {

    case ApplicationDate:
        XftDrawString8(_surface, &_color, _fontTime, 40, 600, (XftChar8 *)[_tline UTF8String], [_tline length]);
        XftDrawString8(_surface, &_color, _fontDate, 40, 670, (XftChar8 *)[_dline UTF8String], [_dline length]);
        break;

    case ApplicationPassword:
        XftDrawString8(_surface, &_color, _fontName, c,  480, (XftChar8 *)[_uline UTF8String], [_uline length]);
        XftDrawRect(_surface, &_color, c1-1, 529, 302, 32);
        XftDrawRect(_surface, &_bgcolor, c1, 530, 300, 30);
        XftDrawString8(_surface, &_color, _fontPwd,  c1, 560, (XftChar8 *)[_pline UTF8String], [_pline length]);
        XftDrawString8(_surface, &_color, _fontSmall,  c2, 660, (XftChar8 *)[instruc UTF8String], [instruc length]);
        break;

    default: 
        exit(1);

    }


}

- (void)timerSetup {
    XSync(_display, false);

    [self setFonts:_font];
    [self doEvents:ApplicationInit];

    // if (_holidays != NULL)
    //     holidays_filter(_holidays, 20210101, fn_iterate);

    /* how many characters of password to show visually */
    _pass_num_show = 32;
    _timeout = 100;
    
    _ev = (XEvent) { 0 };
    _ticks = 0;
    _inactive = _timeout;

    /* main event loop */
    _uline = [[NSMutableString alloc]initWithString:_full];
    _pline = [NSMutableString string];
    [self draw];

    _passwd = [NSMutableString string];
    _len = 0;

    _timer = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(onTimerTick:) userInfo:self repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];


}

- (void)onTimerTick1:(NSTimer *)timer {
    NSLog(@"Timer!");
}

- (void)onTimerTick:(NSTimer *)timer {
    if(_ev.type == KeyRelease) {
        _buf[0] = 0;
    }
    else if(_ev.type == KeyPress) {
        [self doEvents:ApplicationKeyPress];
        _inactive = _timeout;

        _buf[0] = 0;
        _num = XLookupString(&_ev.xkey, _buf, BUFLEN, &_ksym, 0);

        switch(_ksym) {

        /**
            * Enter
            */
        case XK_Return:
            if ([_pin isEqualToString:@""]) { 
                _running = NO;
                break;
            }
            // Warning: Superstitious Code:
            // Since we check in default, it should never get here unless it's wrong...
            if (![_pin isEqualToString:@""] && ![_passwd isEqualToString:@""]) { 
                _running = ![_passwd isEqualToString:_pin];
                if (_running == NO) break;
            }

            if (_running == YES) {
                XBell(_display, 100);
                NSLog(@"Password failed!! Try again!\n");
                _pline = [NSMutableString string];
                [self draw];
            }
            _passwd = [NSMutableString string];
            _len = 0;
            break;

        /**
            * ESC
            */
        case XK_Escape:
            if ([_debug isEqualToString:@"true"]) {
                _running = false;
                break;
            }

            if (_state == ApplicationDate) break;

            if (_first) {
                _first = NO;
                break;
            }
            _passwd = [NSMutableString string];
            _len = 0;
            _pline = [NSMutableString string];
            [self doEvents:ApplicationEscape];
            break;

        /**
            * BackSpace
            */
        case XK_BackSpace:
            if(_len) {
                --_len;
                _pline = [[_pline substringToIndex:[_pline length]-1] mutableCopy];
                [self draw];
            }
            break;

        /**
            * Alpha
            */
        default:
            if (_num && !iscntrl((int) _buf[0]) && (_len + _num < BUFLEN)) {
                NSString *str = @(_buf);
                [_passwd appendString:str];
                _len += _num;
                if ([_pline length] < _pass_num_show) { [_pline appendFormat:@"%c", '*']; }
                // int new_pline_len = [_pline length];
                [self draw];

                if (![_pin isEqualToString:@""] && ![_passwd isEqualToString:@""]) { 
                    _running = ![_passwd isEqualToString:_pin];
                }

            }
            else if (_len + _num >= BUFLEN) {
                XBell(_display, 100);
                NSLog(@"Specified password is *unreasonably* long!! Try again!\n");
                _passwd = [NSMutableString string];
                _len = 0;
                _pline = [NSMutableString string];
                [self draw];
            }
            break;
        }
    }
    else if (_ev.type == MotionNotify || _ev.type == ButtonPress) {
        [self draw];
    }

    // _ev.type = -1;
    // if (_inactive) {
    //     _inactive--;
    //     if (_inactive <= 0) {
    //         _passwd = [NSMutableString string];
    //         _len = 0;
    //         _pline = [NSMutableString string];
    //         [self doEvents:ApplicationTimeout];
    //     }
    // }
    // while(XPending(_display))420420
    //     XNextEvent(_display, &ev);
    // usleep(50000);

    // if (ticks++ >= (20*60)) {
    //     ticks = 0;
    //     [self draw];
    // }


}

/**
 * Run loop
 */
- (void)loop {
    XSync(_display, false);

    [self setFonts:_font];
    [self doEvents:ApplicationInit];

    // if (_holidays != NULL)
    //     holidays_filter(_holidays, 20210101, fn_iterate);

    /* how many characters of password to show visually */
    // const int _pass_num_show = 32;
    // const int timeout = 100;
    
    // XEvent ev = { };
    // KeySym ksym;
    // int _num;
    // int ticks = 0;
    // int _inactive = timeout;

    _pass_num_show = 32;
    _timeout = 100;
    
    _ev = (XEvent) { 0 };
    _ticks = 0;
    _inactive = _timeout;

    /* main event loop */
    _uline = [[NSMutableString alloc]initWithString:_full];
    _pline = [NSMutableString string];
    [self draw];

    _passwd = [NSMutableString string];
    _len = 0;

    while(_running) {
        if(_ev.type == KeyRelease) {
            _buf[0] = 0;
        }
        else if(_ev.type == KeyPress) {
            [self doEvents:ApplicationKeyPress];
            _inactive = _timeout;

            _buf[0] = 0;
            _num = XLookupString(&_ev.xkey, _buf, BUFLEN, &_ksym, 0);

            switch(_ksym) {

            /**
             * Enter
             */
            case XK_Return:
                if ([_pin isEqualToString:@""]) { 
                    _running = NO;
                    break;
                }
                // Since we check in default, it should never get here unless it's wrong..., but...
                if (![_pin isEqualToString:@""] && ![_passwd isEqualToString:@""]) { 
                    _running = ![_passwd isEqualToString:_pin];
                    if (_running == NO) break;
                }

                if (_running == YES) {
                    XBell(_display, 100);
                    NSLog(@"Password failed!! Try again!\n");
                    _pline = [NSMutableString string];
                    [self draw];
                }
                _passwd = [NSMutableString string];
                _len = 0;
                break;

            /**
             * ESC
             */
            case XK_Escape:
                if ([_debug isEqualToString:@"true"]) {
                    _running = false;
                    break;
                }

                if (_state == ApplicationDate) break;

                if (_first) {
                    _first = NO;
                    break;
                }
                _passwd = [NSMutableString string];
                _len = 0;
                _pline = [NSMutableString string];
                [self doEvents:ApplicationEscape];
                break;

            /**
             * BackSpace
             */
            case XK_BackSpace:
                if(_len) {
                    --_len;
                    _pline = [[_pline substringToIndex:[_pline length]-1] mutableCopy];
                    [self draw];
                }
                break;

            /**
             * Alpha
             */
            default:
                if (_num && !iscntrl((int) _buf[0]) && (_len + _num < BUFLEN)) {
                    NSString *str = @(_buf);
                    [_passwd appendString:str];
                    _len += _num;
                    if ([_pline length] < _pass_num_show) { [_pline appendFormat:@"%c", '*']; }
                    // int new_pline_len = [_pline length];
                    [self draw];

                    if (![_pin isEqualToString:@""] && ![_passwd isEqualToString:@""]) { 
                        _running = ![_passwd isEqualToString:_pin];
                    }

                }
                else if (_len + _num >= BUFLEN) {
                    XBell(_display, 100);
                    NSLog(@"Specified password is *unreasonably* long!! Try again!\n");
                    _passwd = [NSMutableString string];
                    _len = 0;
                    _pline = [NSMutableString string];
                    [self draw];
                }
                break;
            }
        }
        else if (_ev.type == MotionNotify || _ev.type == ButtonPress) {
            [self draw];
        }

        _ev.type = -1;
        if (_inactive) {
            _inactive--;
            if (_inactive <= 0) {
                _passwd = [NSMutableString string];
                _len = 0;
                _pline = [NSMutableString string];
                [self doEvents:ApplicationTimeout];
            }
        }
        while(XPending(_display))
            XNextEvent(_display, &_ev);
        usleep(50000);

        if (_ticks++ >= (20*60)) {
            _ticks = 0;
            [self draw];
        }

    }

}

/**
 * Switch state between background windows (_top / _panel)
 */
- (void)doEvents:(ApplicationEvent) event {
    switch (event) {
    case ApplicationInit:
        _state = ApplicationDate;
        _active = _top;
        break;

    case ApplicationKeyPress:
        _state = ApplicationPassword;
        _active = _panel;
        break;

    case ApplicationTimeout:
        _state = ApplicationDate;
        _active = _top;
        XUnmapWindow(_display, _panel);
        break;

    case ApplicationEscape:
        if (_state == ApplicationDate) break;
        _state = ApplicationDate;
        _active = _top;
        XUnmapWindow(_display, _panel);
        break;
    }

    XDefineCursor(_display, _active, _invisible);
    XMapRaised(_display, _active);
    // if the font does not exist, then fallback to fixed and give warning 
    if (_surface != NULL) free(_surface);
    _surface = XftDrawCreate(_display, _active, DefaultVisual(_display, _screen), _cm);
    // Display the pixmaps, if applicable 
    XClearWindow(_display, _active);
    [self draw];

}


- (void)dispose {
    XUngrabPointer(_display, CurrentTime);
    XFreePixmap(_display, _pmap);
    XftColorFree(_display, DefaultVisual(_display, _screen), _cm, &_color);
    XftDrawDestroy(_surface);
    XDestroyWindow(_display, _top);
    XCloseDisplay(_display);

    if (_buf != NULL) free(_buf);
}
@end