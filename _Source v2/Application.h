#import <Cocoa/Cocoa.h>
#import <X11/Xlib.h>
#import <Xft/Xft.h>
#import <Imlib2.h>


typedef enum  { ApplicationDate, ApplicationPassword } ApplicationState;
typedef enum  { ApplicationInit, ApplicationKeyPress, ApplicationEscape, ApplicationTimeout } ApplicationEvent;


@interface Application : NSObject 
{
    Display *_display;      // application display
    Window _root;
    int _screen;
    int _width;
    int _height;
    Colormap _cm;
    Window _top;            // top level window
    Window _active;         // the active window
    Window _panel;          // drawing panel
    unsigned int _len;
    BOOL _running;
    NSString *_imgfn;
    NSString *_boximgfn;
    NSMutableString *_fontnameBase;
    NSMutableString *_fontnameSmall;
    NSMutableString *_fontnameName;
    NSMutableString *_fontnamePwd;
    NSMutableString *_fontnameTime;
    NSMutableString *_fontnameDate;
    Pixmap _pmap;
    Cursor _invisible;
    XftColor _color;        // color to draw
    XftColor _bgcolor;      // color tp draw
    XftFont *_fontSmall;
    XftFont *_fontName;
    XftFont *_fontPwd;
    XftFont *_fontTime;
    XftFont *_fontDate;
    XftDraw *_surface;      // drawable



    NSDateFormatter *_dateFormatter;
    NSMutableDictionary *_options;
    BOOL _first;         // ignore 1st esc key press
    /* Application values */
    NSMutableString *_calendar;
    // Holidays *holidays;
    NSArray *_script;
    NSString *_debug;
    NSString *_user;
    NSString *_full;
    NSString *_pin;
    NSString *_theme;
    NSString *_font;
    NSMutableString *_uline;
    NSMutableString *_pline;
    NSMutableString *_tline;
    NSMutableString *_dline;
    NSMutableString *_passwd;
    char *_buf;
    ApplicationState _state;

    int _pass_num_show;
    int _timeout;
    
    XEvent _ev;
    KeySym _ksym;
    int _num;
    int _ticks;
    int _inactive;
    NSTimer* _timer;


}

- (void)setLockedImage:(NSString*) imagefilename;
- (void)setUnlockImage:(NSString*) imagefilename;
- (instancetype)initWithOptions:(NSMutableDictionary*) options;
- (void)run;
- (void)timerSetup;
- (void)onTimerTick:(NSTimer *)timer;
- (void)onTimerTick1:(NSTimer *)timer;
- (void)createWindow;
- (BOOL)lock;
- (void)loop;
- (void)dispose;
- (void)setFonts:(NSString*) fontName;
- (void)draw;
- (void)doEvents:(ApplicationEvent) event;
@end
