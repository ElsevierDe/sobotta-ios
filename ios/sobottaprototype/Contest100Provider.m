//
//  Contest100Provider.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Contest100Provider.h"

#import "ASIHTTPRequest.h"
#import "NSString+MD5.h"
#import "FigureDatasource.h"

@implementation Contest100Provider


- (id)init {
    self = [super init];
    if (self) {
        _endDate = nil;
        _requestSent = NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *enddate = [userDefaults objectForKey:PREF_CONTEST_ENDDATE];
        if (enddate) {
            NSLog(@"We have an end date");
            _endDate = enddate;
        }
    }
    return self;
}

static Contest100Provider *_instance;

+ (Contest100Provider *)defaultProvider {
    if (!_instance) {
        _instance = [[Contest100Provider alloc] init];
    }
    return _instance;
}


- (NSString *) orientation {
    return @"portrait";
}

- (void) didShowDialog {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:PREF_CONTEST_DIDSHOWDIALOG];
    [userDefaults synchronize];
}


- (NSString *) contestDialogPath:(NSString *)orientation {
    if (orientation == nil) {
        orientation = self.orientation;
    }
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"contest"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:documentsDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"contestimage-%@.png", orientation]];
    return documentsDirectoryPath;
}


- (void)fetchContestInfoIfRequired {
    if (!_requestSent) {
        _requestSent = YES;
        [self fetchContestInfo];
    }
}

- (void)fetchContestInfo {
    NSString *device = @"ipad";
    if (IS_PHONE) {
        device = @"iphone";
    }
    NSString *orientation = self.orientation;
    float scale = [UIScreen mainScreen].scale;
    NSString *lang = NSLocalizedString(@"contest lang", @"en or de");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int lastChange = [userDefaults integerForKey:PREF_CONTEST_LASTCHANGE];
    NSString *urlstr = [NSString stringWithFormat:@"http://inapp.elsevier-verlag.de/sobotta-100percent/contest2.php?since=%d&device=%@&orientation=%@&scale=%f&language=%@", lastChange, device, orientation, scale, lang];
    NSURL *url = [NSURL URLWithString:urlstr];

    NSLog(@"Sending contest request to %@ -- saving it to %@", urlstr, [self contestDialogPath:nil]);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request setDownloadDestinationPath:[self contestDialogPath: nil]];
    [request startAsynchronous];
}

- (BOOL) needShowDialog {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:PREF_CONTEST_DIDSHOWDIALOG]) {
        return NO;
    }
    return [self isContestActive];
}

- (void)forceEnableContest {
    _endDate = [NSDate dateWithTimeIntervalSinceNow:3600.];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PREF_CONTEST_DIDSHOWDIALOG];
    [userDefaults synchronize];
}

- (BOOL)isContestActive {
    return NO;
#ifdef SOB_FREE
    [self fetchContestInfoIfRequired];
    if (_endDate && [_endDate laterDate:[NSDate date]] == _endDate) {
        return YES;
    }
    return NO;
#else
    return NO;
#endif
}

- (NSString *)infoUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:PREF_CONTEST_INFO_URL];
}
- (int) scale {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:PREF_CONTEST_SCALE];
}

- (UIImage *)dialogImage {
    UIImage *tmp = [UIImage imageWithContentsOfFile:[self contestDialogPath:nil]];
    if ([self scale] == 2) {
        tmp = [UIImage imageWithCGImage:tmp.CGImage scale:2 orientation:tmp.imageOrientation];
    }
    return tmp;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (NSString *)winUrlForFigure:(NSString*) figureName {
//    http://sobottadigital.elsevier.de/app/100percent.php?figure=chp001_014&uniq=2344-2342-1234-1111-2222-3333&check=a6a6a6a6a6a66a6a6a6a&language=
    NSString *lang = NSLocalizedString(@"contest lang", @"en or de");
    NSString *uniq = [self genRandStringLength:15];
    NSString *secret = @"EinGeheimerStringFuerSobotta";
    NSString *check = [NSString stringWithFormat:@"%@|%@|%@", figureName, secret, uniq];
    NSString *cheatMode = @"";
    if ([FigureDatasource defaultDatasource].cheatMode) {
        cheatMode = @"&cheatMode=1";
    }
    NSString *urlstr = [NSString stringWithFormat:@"http://sobottadigital.elsevier.de/app/100percent.php?figure=%@&uniq=%@&check=%@&language=%@%@", figureName, uniq, [check MD5], lang, cheatMode];
    return urlstr;
}


#pragma mark ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        NSDictionary *headers = [request responseHeaders];
        NSString *enddatestr = [headers objectForKey:@"X-ENDDATE"];
        NSTimeInterval tmp = [enddatestr doubleValue];
        NSDate *enddate = [NSDate dateWithTimeIntervalSince1970:tmp];
        _endDate = enddate;
        
        NSString *lastchange = [headers objectForKey:@"X-LASTCHANGE"];
        int lastChange = [lastchange intValue];
        
        NSString *infoUrl = [headers objectForKey:@"X-URL_INFO"];
        NSString *scalestr = [headers objectForKey:@"X-SCALE"];
        int scale = 1;
        if (scalestr) {
            scale = [scalestr intValue];
        }
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:lastChange forKey:PREF_CONTEST_LASTCHANGE];
        [userDefaults setObject:enddate forKey:PREF_CONTEST_ENDDATE];
        [userDefaults setObject:infoUrl forKey:PREF_CONTEST_INFO_URL];
        [userDefaults setInteger:scale forKey:PREF_CONTEST_SCALE];
        [userDefaults synchronize];
        
        
        NSLog(@"End Date: %@ / infoUrl: %@", enddate, infoUrl);
//        [[NSNotificationCenter defaultCenter] postNotificationName:SOB_CONTEST_INFO_CHANGED object:self];
    } else {
        NSLog(@"contest request finished with status code %d", [request responseStatusCode]);
    }
}


@end
