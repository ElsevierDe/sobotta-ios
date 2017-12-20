//
//  MainSplitViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SOBNavigationViewController;

@interface MainSplitViewController : UISplitViewController<UISplitViewControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate> {
    CGRect _origFrame;
    float _leftMargin;
}

//- (void) initiateSearch;

- (SOBNavigationViewController *) sobNavigationViewController;
- (void) willPresentMasterViewControllerInImageGrid;
- (void) dismissLeftPopoverAnimated:(BOOL)animated;

@property (weak, nonatomic) UIPopoverController *leftPopupController;

//@property (nonatomic) int chapterId;
@property (weak, nonatomic) UIBarButtonItem *splitViewBarButton;

@end
