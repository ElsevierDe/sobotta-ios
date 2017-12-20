//
//  iOSDocumentMigrator.m
//  ElsevierKLF
//
//  Created by Herbert Poul on 3/12/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "iOSDocumentMigrator.h"
#include <sys/xattr.h>

@implementation iOSDocumentMigrator


/// Set a flag that the files shouldn't be backuped to iCloud.
+ (void)addSkipBackupAttributeToFile:(NSString *)filePath {
    u_int8_t b = 1;
    setxattr([filePath fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

/// Returns the legacy storage path, used when the com.apple.MobileBackup file attribute is not available.
+ (NSString *)legacyStoragePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/// Returns YES if system supports com.apple.MobileBackup file attribute, marks files/folders as not iCloud-backupable.
+ (BOOL)isBackupXAttributeAvailable {
    static BOOL isModern;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // since there is no kCFCoreFoundationVersionNumber_iPhoneOS_5_0_1, we have to do it the ugly way
        NSString *version = [[UIDevice currentDevice] systemVersion];
        isModern = ![version isEqualToString:@"5.0.0"] && [version intValue] >= 5;
        //isModern = NO; // To test migration, enable this to "fake" an old system.
        //NSLog(@"Modern OS detected, com.apple.MobileBackup is allowed. Using Documents folder."); // log optionally
    });
    return isModern;
}

/// Storage Path is Documents for iOS >= 5.0.1, and Caches for iOS <= 5.0.
/// This must be done to fully comply with the iCloud storage guidelines.
/// Don't forget to set the xattr on iOS >= 5.0.1!
/// http://developer.apple.com/library/ios/#qa/qa1719/_index.html
/// https://developer.apple.com/icloud/documentation/data-storage/
/// 
/// The result is cached for faster future access. Can be invoked from any thread.
#define kPSLegacyStoragePathUsed @"PSLegacyStoragePathUsed"
+ (NSString *)storagePath {
    static NSString *storagePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([self isBackupXAttributeAvailable]) {
            storagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        }else {
            storagePath = [self legacyStoragePath];
            // mark that we use the legazy storage.
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPSLegacyStoragePathUsed];
            // No need for manual synchronize, we assume that our app is running long enough for the automatic sweep.
        }
    });
    return storagePath;
}

/// Invoke this in the AppDelegate - moves your documents around.
/// Note: we only support *upgrading* - not OS downgrades.
/// Can be invoked from any thread.
/// Returns YES if a migration was done.
+ (BOOL)checkAndIfNeededMigrateStoragePathBlocking:(BOOL)blocking completionBlock:(void(^)(void))completionBlock {
    __block BOOL migrationNeeded = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL wasUsingLegacyPath = [[NSUserDefaults standardUserDefaults] boolForKey:kPSLegacyStoragePathUsed];
        if (wasUsingLegacyPath && [self isBackupXAttributeAvailable]) {
            void (^moveBlock)(void) = ^{
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                NSString *legacyPath = [self legacyStoragePath];
                NSString *modernPath = [self storagePath];
                NSError *error = nil;
                NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:legacyPath error:&error];
                if (!directoryContents) {
                    NSLog(@"Error while getting contents of directory: %@.", [error localizedDescription]);
                }
                for (NSString *file in directoryContents) {
                    NSString *targetPath = [modernPath stringByAppendingPathComponent:file];
                    if(![fileManager moveItemAtPath:[legacyPath stringByAppendingPathComponent:file]
                                             toPath:targetPath error:&error]) {
                        NSLog(@"Error while moving %@ from path %@ to %@.", file, legacyPath, modernPath);
                        // just continue with next file - can't do much about this.
                    }else {
                        // apply the new attribute to the file/folder (no need to put it on every file, a parent folder will do)
                        [self addSkipBackupAttributeToFile:targetPath];
                    }
                }
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPSLegacyStoragePathUsed];
            };
            if(blocking) {
                moveBlock();
                if (completionBlock) completionBlock();
            }else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    moveBlock();
                    if (completionBlock) completionBlock();
                });
            }
            migrationNeeded = YES;
        }
    });
    return migrationNeeded;
}
@end
