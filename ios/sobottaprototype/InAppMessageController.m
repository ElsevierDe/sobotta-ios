//
//  InAppMessageController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 28/07/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import "InAppMessageController.h"
#import "FullVersionController.h"
#import "InAppMessagePanel.h"
#import <Crashlytics/Crashlytics.h>

@implementation InAppMessageController

static InAppMessageController *current;

+ (InAppMessageController *)instance {
	if(!current){
		current = [[InAppMessageController alloc] init];
	}
	
	return current;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dbController = [DatabaseController Current];
    }
    return self;
}

- (void) fetchMessages:(NSString*) urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req setDelegate:self];
    [req startAsynchronous];
}

- (void) showNewMessages:(UIView *)parentView {
    _parentView = parentView;
    [self fetchMessages:MESSAGE_URL];
}

- (void) showNewTestMessages:(UIView *)parentView {
    _parentView = parentView;
    [self fetchMessages:MESSAGE_TEST_URL];
}


- (NSString *) localizedValue:(NSDictionary *) dict forKey:(NSString *)key {
    NSString * language = [[NSBundle preferredLocalizationsFromArray:@[@"de", @"en"]] firstObject];
    if (!language) {
        language = @"en";
    }
    NSString * localKey = [NSString stringWithFormat:@"%@_%@", key, language];
    NSString * value = [dict objectForKey:localKey];
    if (!value) {
        value = [dict objectForKey:key];
    }
    return value;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"request finished. parsing ressult.");
    NSData *data = [request responseData];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:nil error:&err];
    if (err) {
        NSLog(@"Error while parsing json: %@", err);
    }
    NSArray *messages = [dict objectForKey:@"messages"];
    
    NSMutableArray *parsedMessages = [NSMutableArray array];
    for (NSDictionary *message in messages) {
        InAppMessage* msg = [[InAppMessage alloc] init];
        msg.msgId = [message objectForKey:@"id"];
        msg.title = [self localizedValue:message forKey:@"title"];
        msg.message = [self localizedValue:message forKey:@"message"];
        msg.targetAppId = [message objectForKey:@"target_appid"];
        msg.targetFreeUnlocked = [[message objectForKey:@"target_free_unlocked"] boolValue];
        msg.targetFreeLocked = [[message objectForKey:@"target_free_locked"] boolValue];
        NSString *dateStart = [message objectForKey:@"date_start"];
        if (dateStart) {
            msg.dateStart = [NSDate dateWithTimeIntervalSince1970:[dateStart longLongValue]];
        }
        NSString *dateEnd = [message objectForKey:@"date_end"];
        if (dateEnd) {
            msg.dateEnd = [NSDate dateWithTimeIntervalSince1970:[dateEnd longLongValue]];
        }
        msg.button1Label = [self localizedValue:message forKey:@"button1_label"];
        msg.button1ActionCmd = [message objectForKey:@"button1_action_cmd"];
        msg.button1ActionUrl = [message objectForKey:@"button1_action_url"];

        msg.button2Label = [self localizedValue:message forKey:@"button2_label"];
        msg.button2ActionCmd = [message objectForKey:@"button2_action_cmd"];
        msg.button2ActionUrl = [message objectForKey:@"button2_action_url"];

        NSLog(@"Got message with id: %@", [msg description]);
        [parsedMessages addObject:msg];
    }
    
    [self checkForNewMessages:parsedMessages];
}

- (void) checkForNewMessages:(NSArray *) messages {
    NSDate *now = [NSDate date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (InAppMessage *msg in messages) {
        if (false) {
            [self showMessage:msg];
            return;
        }
        
        // Check if we are in the date range of the message.
        if (msg.dateStart && [msg.dateStart compare:now] == NSOrderedDescending) {
            NSLog(@"Message starts in the future. %@ now: %@", msg, now);
            continue;
        }
        if (msg.dateEnd && [msg.dateEnd compare:now] == NSOrderedAscending) {
            NSLog(@"Message ends in the past. %@ now: %@", msg, now);
            continue;
        }
        
        // Validate that this is the correct target app.
        if (msg.targetAppId && ![msg.targetAppId isEqualToString:SOB_APPID]) {
            NSLog(@"Message is not targeted at our app id: %@ vs %@", msg.targetAppId, SOB_APPID);
            continue;
        }
        
#ifdef SOB_FREE
        // If we are the free version, we have to check for targetFreeUnlocked
        if (msg.targetFreeUnlocked) {
            // it is only targeting unlocked users..
            if (![[FullVersionController instance] hasFullVersion]) {
                NSLog(@"User has not unlocked free version, although message required it. igoring.");
                continue;
            }
        }
        // If we are the free version, we have to check for targetFreeUnlocked
        if (msg.targetFreeLocked) {
            // it is only targeting unlocked users..
            if ([[FullVersionController instance] hasFullVersion]) {
                NSLog(@"User has unlocked free version, but message doesn't target unlocked versions. igoring.");
                continue;
            }
        }
#endif
        
        // check if we have already shown this message to the user.
        if ([defaults boolForKey:[msg userDefaultKey]]) {
            NSLog(@"User has already seen this message. ignoring. %@", msg);
            continue;
        }
        
        // ok the message has to be shown.
        if ([self showMessage:msg]) {
            return;
        }
    }
}

- (BOOL) showMessage:(InAppMessage *) msg {
    NSLog(@"showing message %@", msg);
    if (!msg || !msg.button1Label || !msg.message) {
        CLS_LOG(@"Requested to show empty message, ignoring it. %@", msg);
        return NO;
    }
    
    [_dbController trackView:@"InAppMessageController/showMessage"];
    [_dbController trackView:[NSString stringWithFormat:@"InAppMessageController/showMessage/%@", msg.msgId]];
    
    _displayedMessage = msg;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:msg.title message:msg.message delegate:self cancelButtonTitle:msg.button1Label otherButtonTitles:msg.button2Label, nil];
    [view show];
    return YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed. %@", [request error]);
}



- (void) doAction:(NSString *)actionCmd actionUrl:(NSString *)actionUrl {
    if (actionCmd && [actionCmd isEqualToString:@"close"]) {
        // umm.. noting to do.. dialog is already dismissed anyway.
    }
    if (actionUrl) {
#ifdef SOB_FREE
        actionUrl = [actionUrl stringByReplacingOccurrencesOfString:@"sobotta:" withString:@"sobottafree:"];
#else
        actionUrl = [actionUrl stringByReplacingOccurrencesOfString:@"sobotta:" withString:@"sobottafull:"];
#endif
        NSLog(@"doing action actionCmd: %@ actionUrl: %@", actionCmd, actionUrl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionUrl]];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // mark message as shown ...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:true forKey:[_displayedMessage userDefaultKey]];
    [defaults synchronize];
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [_dbController trackEventWithCategory:@"inappmessage" withAction:@"dismissed" withLabel:@"cancel" withValue:nil];
        // button 1
        [self doAction:_displayedMessage.button1ActionCmd actionUrl:_displayedMessage.button1ActionUrl];
    } else if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [_dbController trackEventWithCategory:@"inappmessage" withAction:@"dismissed" withLabel:@"confirm" withValue:nil];
        // button 2
        [self doAction:_displayedMessage.button2ActionCmd actionUrl:_displayedMessage.button2ActionUrl];
    }
}

@end

@implementation InAppMessage


- (NSString *)userDefaultKey {
    return [NSString stringWithFormat:@"inappmessage_%@", self.msgId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{InAppMessage: msgId=%@, title=%@, message=%@, dateStart=%@, dateEnd=%@, targetAppId: %@, button1Label: %@, button2Label: %@}", self.msgId, self.title, self.message, self.dateStart, self.dateEnd, self.targetAppId, self.button1Label, self.button2Label];
}

@end