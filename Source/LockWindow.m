#import "LockWindow.h"
#import <GNUstepGUI/GSDisplayServer.h>
#import <X11/Xlib.h>


@implementation LockWindow
@synthesize title = _title;
@synthesize description = _description;
@synthesize copyright = _copyright;
@synthesize currentDate = _currentDate;
@synthesize currentTime = _currentTime;

- (instancetype)init {
  counter = 0;
  input = [NSString new];

  NSSize resolution =  [[NSScreen mainScreen] frame].size;
  NSLog(@"resolution = %fx%f", resolution.width, resolution.height);

  _title = @"the title";
  _description = @"description";

  wallpaper = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, resolution.width, resolution.height)] autorelease];
  // [wallpaper setImage:[NSImage imageNamed:@"Logo.png"]];
  [wallpaper setImage:[NSImage imageNamed:@"wallpaper.locked.jpg"]];
  // [wallpaper setImageFrameStyle:(NSImageFrameGrayBezel)];



  // [super initWithContentRect:NSMakeRect(100, 100, WIDTH, HEIGHT) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable backing:NSBackingStoreBuffered defer:NO];
  [super initWithContentRect:NSMakeRect(0, 0, resolution.width, resolution.height) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  [[self contentView] addSubview:wallpaper];

  [self setIsVisible:YES];
  [self setLevel: NSScreenSaverWindowLevel-1];
  [self setAutodisplay: YES];
  [self makeFirstResponder: self];
  [self setExcludedFromWindowsMenu: YES];
  [self setHasShadow:NO];
  [self setOpaque:NO];
  // [self setBackgroundColor: [NSColor blackColor]];
  [self setBackgroundColor: [NSColor clearColor]];
  [self setOneShot:YES];

 
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];


  return self;
}

- (void)onTimerTick:(NSTimer*)timer {
  // NSLog(@"Counter = %i", counter);
  counter++;
  if (counter > 5)
    [[NSApplication sharedApplication] terminate:nil];

  // date & time:

}


- (BOOL)windowShouldClose:(id)sender {
  [NSApp terminate:sender];
  return YES;
}

- (void) setAction: (SEL)a forTarget: (id)t
{
  action = a;
  target = t;
}

/** 
 * On KwyDown, display text input (NSTextField)
 * NSTextFieldRoundedBezel = 1
 *
 * setBezeled:YES
 * setBordered:YES
 * drawsBackground:YES  
 * backgroundColor:
 * bezelStyle:NSTextFieldRoundedBezel
 *
 */
- (void) keyDown: (NSEvent *)theEvent
{
  if([self level] != NSDesktopWindowLevel)
    {
      [NSApp sendAction: action to: target from: self];
      NSString *str = [theEvent characters];
      int keyCode = [theEvent keyCode];
      // NSUInteger flags = [theEvent modifierFlags];
      int ch = [str characterAtIndex:0];
      switch (keyCode) {
        case 22:  //  backspace
          NSLog(@"<backspace> %i", ch);
          break;
        case 36:  //  return
          NSLog(@"<return> %i", ch);
          break;
        default:
          NSLog(@"key code %@ | %i", str, ch);    
      }

    }
}

- (void) mouseUp: (NSEvent *)theEvent
{
  if([self level] != NSDesktopWindowLevel)
    {
      [NSApp sendAction: action to: target from: self];
    }
}

- (BOOL) canBecomeKeyWindow
{
  return YES;
}

- (BOOL) canBecomeMainWindow
{
  return YES;
}

- (void) hide: (id)sender
{
  // Don't react to hide.  This window cannot be hidden.
}


@end

/**
 * A delegate to use with NSCustomImageRep.
 */
@implementation DrawingDelegate
- (instancetype)initWithWindow:(LockWindow *)window {
  _window = window;
  return self;
}

- (void) draw: (NSCustomImageRep*)rep
{
  
  [_window.title drawInRect: NSMakeRect(10,20,58,30)
	     withAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSFont userFontOfSize: 10], NSFontAttributeName,
					   nil]];

  [_window.description drawInRect: NSMakeRect(10,40,400,30)
	  withAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
					      [NSFont userFontOfSize: 24], NSFontAttributeName,
					nil]];
}

@end
