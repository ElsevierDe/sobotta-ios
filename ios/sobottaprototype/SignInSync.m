//
//  SignInSync.m
//  sobottaprototype
//
//  Created by Herbert Poul on 30/08/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import "SignInSync.h"

#import "ASIHTTPRequest.h"
#import "FullVersionController.h"
#import <CocoaLumberjack/DDLog.h>
#import <GoogleSignIn/GoogleSignIn.h>

@implementation SignInSync



static SignInSync *current;

+ (SignInSync *)instance {
	if(!current){
		current = [[SignInSync alloc] init];
	}
	
	return current;
}

- (void) syncReceipt {
    NSString *idToken = [[[[GIDSignIn sharedInstance] currentUser] authentication] idToken];

    if (!idToken) {
        DDLogError(@"No Google+ sign in token?! NOT synchronizing receipt!");
        return;
    }
    DDLogInfo(@"Synchronizing iOS receipt...");
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];
    if (!receiptString) {
        receiptString = @"";
    }
    
    //    NSError *error;
    //    NSString *receiptString =
    //    [[NSString alloc] initWithContentsOfFile:[receiptUrl path]
    //                                    encoding:NSASCIIStringEncoding
    //                                       error:&error];
    DDLogDebug(@"ReceiptString: %@", receiptString);

    ASIHTTPRequest *myrequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://inapp.elsevier-verlag.de/sobotta-data/api/purchasesync/sync.php"]];
    
    [[DatabaseController Current] trackEventWithCategory:@"signinsync" withAction:@"start" withLabel:[FullVersionController instance].hasFullVersion ? @"isupgraded" : @"notupgaded" withValue:@0];
    

    NSDictionary *dict = @{
                           @"useridtoken": idToken,
                           @"itunesreceiptdata": receiptString,
                           @"iosbundleid": [[NSBundle mainBundle] bundleIdentifier]};
    DDLogDebug(@"Serializing dict %@", dict);
    NSError *serialerror;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&serialerror];
    [myrequest addRequestHeader:@"Content-Type" value:@"application/json"];
    DDLogDebug(@"Setting post data.");
    if (!jsonData) {
        DDLogError(@"Json data is nil?!");
    }
    [myrequest setPostBody:[NSMutableData dataWithData:jsonData]];
    
    ASIHTTPRequest __block *blockRequest = myrequest;
    
    [myrequest setCompletionBlock:^{
        NSError *err;
        NSDictionary *value = [NSJSONSerialization JSONObjectWithData:blockRequest.responseData options:0 error:&err];
        DDLogDebug(@"request completed successfully. %@ (err: %@)", value, err);
        FullVersionController *fvc = [FullVersionController instance];
        if ([value[@"androidstatus"] isEqualToString:@"androidupgrade"]) {
            if (![fvc hasFullVersion]) {
                [fvc transformToFullVersion];
                [[DatabaseController Current] trackEventWithCategory:@"signinsync" withAction:@"transformToFullVersion" withLabel:@"androidupgrade" withValue:@0];
            } else {
                [[DatabaseController Current] trackEventWithCategory:@"signinsync" withAction:@"alreadyUpgraded" withLabel:@"androidupgrade" withValue:@0];
            }
        } else if ([value[@"androidstatus"] isEqualToString:@"androidbundlepurchase"]) {
            NSArray<NSString *> *purchasedBundleIds = value[@"androidpurchasedbundleids"];
            BundleService *bundleService = [BundleService instance];
            NSArray <Bundle *> *purchasedBundles = [purchasedBundleIds bk_map:^Bundle *(NSString *bundleId) {
                return [bundleService bundleById:bundleId];
            }];
            [fvc purchasedBundles:purchasedBundles];
            [[DatabaseController Current] trackEventWithCategory:@"signinsync" withAction:@"purchasedBundles" withLabel:@"androidbundlepurchase" withValue:@0];
        } else {
            [[DatabaseController Current] trackEventWithCategory:@"signinsync" withAction:@"finished" withLabel:@"noandroidstatus" withValue:@0];
        }
    }];
    [myrequest setFailedBlock:^{
        DDLogError(@"Request failed. %@", blockRequest.error);
    }];
    DDLogDebug(@"Starting sync request.");
    [myrequest startAsynchronous];

}

@end
