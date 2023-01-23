#import "Controller.h"
#import "Application.h"

@implementation Controller

- (void) applicationWillFinishLaunching: (NSNotification *)aNotification;
{

}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{

    NSMutableDictionary *options = [@{
        @"pin":     @"1234",
        @"font":    @"SanFranciscoDisplay sans-",
        @"theme":   @"wallpaper",
        @"name":    @"bruce davidson",
        @"user":    @"darko",
        @"debug":   @"false"
    } mutableCopy];    

    /**
     * Parse command line options
     */
    NSArray *argv = [[NSProcessInfo processInfo] arguments];
    __block NSString *pgm;
    __block NSString *key = nil;


    [argv enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            pgm = [[NSString alloc] initWithString:object];
            return;
        }
        if ([[object substringToIndex:2] isEqualToString:@"--"]) {
            key = [[NSString alloc] initWithString:[object substringFromIndex:2]];
        }
        else if ([[object substringToIndex:1] isEqualToString:@"-"]) {
            key = [[NSString alloc] initWithString:[object substringFromIndex:1]];
            if ([key isEqualToString:@"f"])
                key = [[NSString alloc] initWithString:@"font"];
            if ([key isEqualToString:@"p"])
                key = [[NSString alloc] initWithString:@"pin"];
            if ([key isEqualToString:@"t"])
                key = [[NSString alloc] initWithString:@"theme"];
            if ([key isEqualToString:@"n"])
                key = [[NSString alloc] initWithString:@"name"];
            if ([key isEqualToString:@"u"])
                key = [[NSString alloc] initWithString:@"user"];
            if ([key isEqualToString:@"d"])
                key = [[NSString alloc] initWithString:@"debug"];
        }
        else {
            options[key] = object;
            key = nil;
        }
    }];

    // app = [[Application alloc] init];
    app = [[Application alloc] initWithOptions:options];
    [app setLockedImage:@"/usr/GNUstep/Local/Applications/DailyBing.app/Resources/themes/wallpaper.locked.jpg"];
    [app setUnlockImage:@"/usr/GNUstep/Local/Applications/DailyBing.app/Resources/themes/wallpaper.authorize.jpg"];

    [app run];
}

@end