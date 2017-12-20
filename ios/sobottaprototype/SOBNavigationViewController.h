//
//  SOBNavigationViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/16/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Crashlytics/Crashlytics.h>
#import "DatabaseController.h"
#import "BookmarksTableViewController.h"
#import "HomescreenViewController.h"
#import "Training.h"

#define kStartTrainingAlert 1
#define kAlertPhoneResumeTraining 2
#define kAlertPhoneStartTraining 3
#define kActionSheetActions 1

@class ImageViewController;
@class ImageGridViewController;

@interface SOBNavigationViewController : UINavigationController <UINavigationControllerDelegate, UIPopoverControllerDelegate, BookmarksDelegate, UIAlertViewDelegate, UIActionSheetDelegate > {
    
    
    DatabaseController *_dbController;
    
    UIBarButtonItem *_homeButton;
    UIBarButtonItem *_actionsButton;
    UIBarButtonItem *_moreButton;
    UIBarButtonItem *_searchButton;
    UIBarButtonItem *_resumeTrainingItem;
    UIBarButtonItem *_languageButton;
    
    UIPopoverController *_actionsPopover;
    UIPopoverController *_languagePopover;
    
    NSNotificationCenter *_notificationCenter;
    
    BOOL _isPushingViewController;
    
}


- (BOOL) dismissPopovers:(UIPopoverController *)sender;
- (void) showActionsPopover:(UIViewController *)vc;
- (void)updateNavigationButtonItems:(UIViewController *)viewController;

/**
 * returns the currently active image view controller
 * (if any, nil otherwise)
 */
- (ImageViewController *) imageViewController;
- (ImageGridViewController *) imageGridViewController:(BOOL)requireOnTop;
- (void)doStartTraining:(BOOL)createNewTraining;

@property (weak, nonatomic) UIBarButtonItem* splitViewBarButton;
@property (strong, nonatomic) UIPopoverController *popover;

@property (strong, nonatomic) UIPopoverController *actionsPopover;
@property (strong, nonatomic) UIPopoverController *nextActionsPopover;
@property (strong, nonatomic) UIPopoverController *morePopover;
@property (strong, nonatomic) UIBarButtonItem *actionsButton;
@property (strong, readonly) UIBarButtonItem *resumeTrainingItem;
@property (readonly) HomescreenViewController *homescreenViewController;

@end
