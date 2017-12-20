//
//  AppDelegate.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SOB_APP ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (AppDelegate *)shared;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)openCategoriesGallery:(int)chapterId;

@end
