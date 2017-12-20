//
//  InAppMessageController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 28/07/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "DatabaseController.h"


#define MESSAGE_URL @"http://inapp.elsevier-verlag.de/sobotta-data/iam/msg.json"
#define MESSAGE_TEST_URL @"http://inapp.elsevier-verlag.de/sobotta-data/iam/msgtest.json"

@class InAppMessage;

@interface InAppMessageController : NSObject<ASIHTTPRequestDelegate, UIAlertViewDelegate> {
    UIView *_parentView;
    
    InAppMessage *_displayedMessage;
    DatabaseController *_dbController;
}


+ (InAppMessageController*) instance;

- (void) showNewMessages:(UIView *)parentView;
- (void) showNewTestMessages:(UIView *)parentView;

@end


@interface InAppMessage : NSObject


@property (strong, nonatomic) NSString* msgId;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* targetAppId;
@property (nonatomic) BOOL targetFreeUnlocked;
@property (nonatomic) BOOL targetFreeLocked;
@property (strong, nonatomic) NSDate *dateStart;
@property (strong, nonatomic) NSDate *dateEnd;
@property (strong, nonatomic) NSString *button1Label;
@property (strong, nonatomic) NSString *button1ActionCmd;
@property (strong, nonatomic) NSString *button1ActionUrl;

@property (strong, nonatomic) NSString *button2Label;
@property (strong, nonatomic) NSString *button2ActionCmd;
@property (strong, nonatomic) NSString *button2ActionUrl;


/**
 * return the user default setting name under which
 * to store whether the user already see this message.
 */
- (NSString *) userDefaultKey;

@end