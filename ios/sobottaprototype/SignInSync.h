//
//  SignInSync.h
//  sobottaprototype
//
//  Created by Herbert Poul on 30/08/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * helper class to manage itunes store receipt synchronization
 * based on google+ sign in.
 */
@interface SignInSync : NSObject

+ (SignInSync *)instance;

- (void) syncReceipt;

@end
