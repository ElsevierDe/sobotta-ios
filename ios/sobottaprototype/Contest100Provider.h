//
//  Contest100Provider.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

#define PREF_CONTEST_ENDDATE @"contest_enddate"
#define PREF_CONTEST_LASTCHANGE @"contest_lastchange"
#define PREF_CONTEST_INFO_URL @"contest_info_url"
#define PREF_CONTEST_SCALE @"contest_scale"

#define PREF_CONTEST_DIDSHOWDIALOG @"contest_didshowdialog"

/// DEPRECATED - NO LONGER IN USE .. REMOVE ME.
@interface Contest100Provider : NSObject<ASIHTTPRequestDelegate> {
    NSDate *_endDate;
    BOOL _requestSent;
}

+ (Contest100Provider *) defaultProvider;


- (NSString *) contestDialogPath: (NSString *)orientation;
- (BOOL) isContestActive;
- (NSString *)infoUrl;
- (UIImage *)dialogImage;
- (void) didShowDialog;
- (BOOL) needShowDialog;
- (NSString *)winUrlForFigure:(NSString*) figureName;
- (void)forceEnableContest;

@end
