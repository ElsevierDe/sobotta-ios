//
//  CrashlyticsLogger.h
//  sobottaprototype
//
//  Created by Herbert Poul on 1/10/17.
//  Copyright © 2017 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CocoaLumberjack/CocoaLumberjack.h>

@interface CrashlyticsLogger : DDAbstractLogger

+(CrashlyticsLogger*) sharedInstance;

@end
