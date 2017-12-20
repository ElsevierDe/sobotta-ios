

#import "SOBApplication.h"

@implementation SOBApplication

- (BOOL)openURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:@"googlechrome-x-callback:"]) {
        return NO;
    } else if ([[url absoluteString] hasPrefix:@"https://accounts.google.com/o/oauth2/auth"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
        return NO;
    }
    return [super openURL:url];
}

@end
