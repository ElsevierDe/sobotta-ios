//
//  iOSDocumentMigrator.h
//  ElsevierKLF
//
//  Created by Herbert Poul on 3/12/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//


@interface iOSDocumentMigrator : UITableViewCell

+ (void)addSkipBackupAttributeToFile:(NSString *)filePath;
+ (NSString *)legacyStoragePath;
+ (BOOL)isBackupXAttributeAvailable;
+ (NSString *)storagePath;
+ (BOOL)checkAndIfNeededMigrateStoragePathBlocking:(BOOL)blocking completionBlock:(void(^)(void))completionBlock;
@end
