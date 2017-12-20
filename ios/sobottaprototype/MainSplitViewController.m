//
//  MainSplitViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MainSplitViewController.h"
#import "SOBNavigationViewController.h"
#import "ImageGridViewController.h"
#import "HomescreenViewController.h"
#import "AutocompleteViewController.h"
#import "ImageViewController.h"
#import <Apptentive/Apptentive.h>

#define kLeftMargin 319

@interface MainSplitViewController ()

@end

@implementation MainSplitViewController


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        NSLog(@"Initialized with coder.");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setPresentsWithGesture:)]) {
        self.presentsWithGesture = NO;
    }
//    self.view.backgroundColor = [UIColor greenColor];
//    self.view.backgroundColor = [UIColor colorWithRed:6./256. green:113./256. blue:171./256. alpha:1];
    
//    [[ATConnect sharedConnection] engage:@"appStarted" fromViewController:self];
    [[Apptentive sharedConnection] engage:@"appStarted" fromViewController:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSeuge: %@", [segue identifier]);
}


-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    self.leftPopupController = pc;
    NSLog(@"Will hide view controller...");
    barButtonItem.title = NSLocalizedString(@"Chapters", nil);
    SOBNavigationViewController *navigationController = [self.viewControllers lastObject];
    _splitViewBarButton = barButtonItem;
    navigationController.splitViewBarButton = barButtonItem;
    
    [navigationController.topViewController.navigationItem setLeftBarButtonItem:barButtonItem];
    self.leftPopupController = pc;
}
- (void) willPresentMasterViewControllerInImageGrid {
    UINavigationController* nav = [[self viewControllers] lastObject];
    if ([[nav.viewControllers lastObject] isKindOfClass:[ImageGridViewController class]]) {
        CGRect frame = nav.view.frame;
        _origFrame = frame;
        _leftMargin = kLeftMargin;
        //        nav.view.frame = CGRectMake(frame.origin.x + 315, frame.origin.y, frame.size.width, frame.size.height);
        [self.view setNeedsLayout];
        [nav.view setNeedsDisplay];
    }
}

-(void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
    self.leftPopupController = pc;
    NSLog(@"popoverController willPresentViewController - frame: %@", NSStringFromCGRect(aViewController.view.frame));
    pc.delegate = self;
    UINavigationController* nav = [[self viewControllers] lastObject];
    if ([[nav.viewControllers lastObject] isKindOfClass:[ImageGridViewController class]]) {
        CGRect frame = nav.view.frame;
        _origFrame = frame;
        _leftMargin = kLeftMargin;
//        nav.view.frame = CGRectMake(frame.origin.x + 315, frame.origin.y, frame.size.width, frame.size.height);
        [self.view setNeedsLayout];
        [nav.view setNeedsDisplay];
    }
//    aViewController.view.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height);
    
    UINavigationController *navcontroller = [self.viewControllers objectAtIndex:0];
    UIViewController *mastervc = [[nav viewControllers] lastObject];
    
//    if ([[navcontroller.viewControllers lastObject] isKindOfClass:[AutocompleteViewController class]]) {
//        [navcontroller popViewControllerAnimated:NO];
//    }
    if ([mastervc isKindOfClass:[ImageGridViewController class]]) {
        ImageGridViewController* igvc = (ImageGridViewController *) mastervc;
        [igvc loadMasterView:NO];
    } else if ([mastervc isKindOfClass:[HomescreenViewController class]]) {
        [navcontroller popToRootViewControllerAnimated:NO];
    } else if ([mastervc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController*) mastervc;
        if (ivc.trainingMode) {
            [navcontroller popToRootViewControllerAnimated:YES];
        }
    }

}

- (void)viewDidLayoutSubviews {
    if (_leftMargin) {
        UINavigationController* nav = [[self viewControllers] lastObject];
        CGRect frame = nav.view.frame;
        _origFrame = frame;
        [UIView animateWithDuration:0.2 animations:^{
            float leftMargin = _leftMargin;
            if (IS_IOS_8_OR_LATER) {
                leftMargin = [self primaryColumnWidth];
                NSLog(@"leftMargin: %f", leftMargin);
            }
            nav.view.frame = CGRectMake(frame.origin.x + leftMargin, frame.origin.y, frame.size.width, frame.size.height);
            [nav.view setNeedsDisplay];
        }];
        
    }
}

- (void)updateMargin {
    
}

- (SOBNavigationViewController *)sobNavigationViewController {
    return (SOBNavigationViewController *) [self.viewControllers lastObject];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSLog(@"willShowViewController.");
    
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    NSLog(@"shouldHideViewController?");
    return YES;
}

- (void)setChapterId:(int)chapterId {
//    _chapterId = chapterId;
    SOBNavigationViewController *navigationController = [self.viewControllers lastObject];
    UIViewController *vc = [[navigationController viewControllers] lastObject];
    if ([vc isKindOfClass:[ImageGridViewController class]]) {
        [((ImageGridViewController*)vc) loadForChapterId:chapterId];
    }
//    [(ImageGridViewController*)navigationController.topViewController loadForChapterId:chapterId];
}

- (void) dismissLeftPopoverAnimated:(BOOL)animated {
    [self.leftPopupController dismissPopoverAnimated:animated];
    [self restoreMasterViewSize];
}


- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    DDLogVerbose(@"popoverControllerShouldDismissPopover (gestures: %d)", self.presentsWithGesture);
    UIViewController* nav = [[self viewControllers] lastObject];
    [UIView animateWithDuration:0.2 animations:^{
        _leftMargin = 0;
        nav.view.frame = _origFrame;
    }];
    return YES;
}
//
//- (void) initiateSearch {
//    [_splitViewBarButton.target performSelector: _splitViewBarButton.action withObject: _splitViewBarButton];
//    
//    UINavigationController *leftnav = [self.viewControllers objectAtIndex:0];
//    leftnav
//}
//
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover controller was dismissed.");
    _leftMargin = 0;
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    NSLog(@"willChangeToDisplayMode: %ld", (long)displayMode);
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        [self restoreMasterViewSize];
    }
}

- (void) restoreMasterViewSize {
    if (_leftMargin == 0) {
        return;
    }
    UIViewController* nav = [[self viewControllers] lastObject];
    [UIView animateWithDuration:0.2 animations:^{
        _leftMargin = 0;
        nav.view.frame = _origFrame;
    }];
}


@end
