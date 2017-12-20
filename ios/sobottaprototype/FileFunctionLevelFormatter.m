//
//  FileFunctionLevelFormatter.m
//  sobottaprototype
//
//  Created by Herbert Poul on 27/09/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "FileFunctionLevelFormatter.h"

@implementation FileFunctionLevelFormatter


- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString* logLevel = nil;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }
    
    return [NSString stringWithFormat:@"[%@][%@ %@][Line %lu] %@",
            logLevel,
            logMessage->_fileName,
            logMessage->_function,
            (unsigned long)logMessage->_line,
            logMessage->_message];
}

@end
