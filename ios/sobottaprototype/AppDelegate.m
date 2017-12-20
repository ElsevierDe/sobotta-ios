//
//  AppDelegate.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "Theme/Theme.h"
#import "Contest100Provider.h"
#import "iOSDocumentMigrator.h"
#import "FullVersionController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import "GoogleConversionPing.h"

#import <Apptentive/Apptentive.h>
#import <ACTReporter.h>
#import <Bolts/Bolts.h> 
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleConversionTracking/ACTReporter.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "FileFunctionLevelFormatter.h"

#import "MainSplitViewController.h"
#import "SOBNavigationViewController.h"
#import "CrashlyticsLogger.h"

#import "GAI.h"
@import Firebase;


@implementation AppDelegate
    

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)shared {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // initializing logging
    [DDTTYLogger sharedInstance].logFormatter = [[FileFunctionLevelFormatter alloc] init];
    [DDASLLogger sharedInstance].logFormatter = [[FileFunctionLevelFormatter alloc] init];
    
//    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
    DDLogInfo(@"initialized logging.");
    
    //[Crashlytics startWithAPIKey:@"daed8da2015bb74fed78cfe0b070ca09bec546a1"];
    [Fabric with:@[[Crashlytics class]]];
    
//    // Apptentive api key
//    [ATConnect sharedConnection].apiKey = SOB_AT_APIKEY;
//    // app store id
//    [ATConnect sharedConnection].appID = SOB_APPID;
    [Apptentive sharedConnection].APIKey = SOB_AT_APIKEY;
    [Apptentive sharedConnection].appID = SOB_APPID;
    
#ifdef SOB_FREE
    [ACTAutomatedUsageTracker enableAutomatedUsageReportingWithConversionID:@"980522511"];
    // Google iOS Download tracking snippet
    [ACTConversionReporter reportWithConversionID:@"980522511" label:@"-yEuCOG1qA4Qj6zG0wM" value:@"1.00" isRepeatable:NO];
#endif
    
    NSLog(@"application didFinishLaunchingWithOptions.");
    [iOSDocumentMigrator checkAndIfNeededMigrateStoragePathBlocking:YES completionBlock:nil];
    Contest100Provider *contest = [Contest100Provider defaultProvider];
    [contest isContestActive];
    [SOThemeManager customizeAppAppearance];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    if (IS_PHONE) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    }

    [FullVersionController instance];
    
    
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-26491935-4"];
    tracker.allowIDFACollection = YES;

#ifdef SOB_DEBUG
    // TODO REMOVE ME FOR RELEASE
//    [TestFlight takeOff:@"dd1e0a40e3af04eae719a94ac57a6a86_MTM2ODAyMjAxMi0wOS0yNyAwNToyNzowOC4yMDg0OTQ"];
    
    // FIXME strip me out!!
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
//    [GoogleConversionPing pingWithConversionId:@"980522511" label:@"-yEuCOG1qA4Qj6zG0wM" value:@"1" isRepeatable:NO];
    [ACTConversionReporter reportWithConversionID:@"980522511" label:@"-yEuCOG1qA4Qj6zG0wM" value:@"1" isRepeatable:NO];
    
#ifdef SOB_FREE
    [[FullVersionController instance] updateCustomDimension];
#endif
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
    // we currently have to execute it on the main thread, because the managed object context is created this way.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAnalytics];
        // make sure bundle service is initialized, will prefetch app store prices.
        [BundleService instance];
    });
    

    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    //UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	    //UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
	    //splitViewController.delegate = (id)navigationController.topViewController;
	    
	    //UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
	    //MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
	} else {
	    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
	    //MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
	}
    
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (error) {
                NSLog(@"Received error while fetching deferred app link %@", error);
            }
            if (url) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    }

  
     [FIRApp configure];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void) updateAnalytics {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmarklist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deleted == %@", [NSNumber numberWithBool:NO]];
    fetchRequest.includesSubentities = NO;
    NSError *err;
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&err];
    if (!err) {
        [[DatabaseController Current] trackBookmarklistCount:count];
    }
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    fetchRequest.includesSubentities = NO;
    count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&err];
    if (!err) {
        [[DatabaseController Current] trackNotesCount:count];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    CLS_LOG(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    CLS_LOG(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //default from .plist are taken
    //[FBSettings setDefaultAppID:SOB_FB_APPID];
    
    
    [FBSDKAppEvents activateApp];
    
    CLS_LOG(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	//[self saveContext];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"sobottauser" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"application openURL");
   /*
    [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        NSLog(@"FB: Unhandled deep link.");
    }]; */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_URL object:self userInfo:@{@"url": url}];
    
    if ([[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"application handleOpenURL");
    return YES;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"sobottauser.sqlite"];
    
    NSLog(@"Using sqlite at %@", storeURL);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary* dict = @{NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:dict error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"applicationDidReceiveMemoryWarning");
}

#pragma mark - utility methods usable throughout the app

- (void)openCategoriesGallery:(int)chapterId {
    SOBNavigationViewController *sobNavController;
    if (IS_PHONE) {
        sobNavController = (SOBNavigationViewController *)self.window.rootViewController;
    } else {
        
        MainSplitViewController *rootController = (MainSplitViewController *) self.window.rootViewController;
        sobNavController = rootController.sobNavigationViewController;
    }
    [sobNavController.homescreenViewController openCategoriesGallery:chapterId requestItem:RequestedItemNone currentViewController:nil];
}

@end
