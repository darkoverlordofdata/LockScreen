#import <Cocoa/Cocoa.h>



@interface LockWindow : NSWindow 
{
  id  target;
  SEL action;
  NSImageView *wallpaper;
  NSTimer *timer;
  int counter;
  NSString *input;

  NSString* _title;
  NSString* _description;
  NSString* _copyright;
  NSString* _currentDate;
  NSString* _currentTime;

}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* copyright;
@property (nonatomic, retain) NSString* currentDate;
@property (nonatomic, retain) NSString* currentTime;
- (void) setAction: (SEL)action forTarget: (id) target;
- (instancetype)init;
- (BOOL)windowShouldClose:(id)sender;
- (void)onTimerTick:(NSTimer*)timer;

@end

@interface DrawingDelegate : NSObject
{
  LockWindow* _window;
}

- (instancetype)initWithWindow:(LockWindow *)window;
@end
