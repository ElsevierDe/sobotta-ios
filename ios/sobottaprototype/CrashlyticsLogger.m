//
//  CrashlyticsLogger.m
//  sobottaprototype
//
//  Created by Herbert Poul on 1/10/17.
//  Copyright © 2017 Stephan Kitzler-Walli. All rights reserved.
//

#import "CrashlyticsLogger.h"

OBJC_EXTERN void CLSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@implementation CrashlyticsLogger

-(void) logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->_message;
    
    if (_logFormatter)
    {
        logMsg = [_logFormatter formatLogMessage:logMessage];
    }
    
    if (logMsg)
    {
        CLSLog(@"%@",logMsg);
    }
}


+(CrashlyticsLogger*) sharedInstance
{
    static dispatch_once_t pred = 0;
    static CrashlyticsLogger *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

@end
