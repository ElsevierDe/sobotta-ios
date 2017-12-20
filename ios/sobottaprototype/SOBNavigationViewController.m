//
//  SOBNavigationViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/16/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SOBNavigationViewController.h"
#import "MainSplitViewController.h"
#import "HomescreenViewController.h"
#import "AppDelegate.h"
#import "ImageActionsViewController.h"
#import "ImageViewController.h"
#import "SOBButtonImage.h"
#import "MoreMenuTableViewController.h"
#import "MyNotesRootViewController.h"
#import "TrainingResultsTableViewController.h"
#import "StaticContentViewController.h"
#import "TrainingViewController.h"
#import "AutocompleteViewController.h"
#import "GAI.h"
#import <Crashlytics/Crashlytics.h>

@interface SOBNavigationViewController ()

@end

@implementation SOBNavigationViewController
@synthesize actionsButton = _actionsButton;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"SOB Navigation View Controller.");
        self.delegate = self;
        _dbController = [DatabaseController Current];
        _notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
    }
    return self;
}

- (void)languageChanged:(NSNotification *)notification {
    if (_languageButton) {
        SOBButtonImage *img =  (SOBButtonImage *)_languageButton.customView;
        img.sobLabel.text = _dbController.currentLanguage.label;
        img.accessibilityLabel = _dbController.currentLanguage.label;
        [self dismissPopovers:nil];
    }
    UIViewController *vc = self.topViewController;
    NSString *category = @"Misc";
    if ([vc isKindOfClass:[HomescreenViewController class]]) {
        category = @"Homescreen";
    } else if ([vc isKindOfClass:[ImageGridViewController class]]) {
        category = @"FigureList";
    } else if ([vc isKindOfClass:[ImageViewController class]]) {
        category = @"FigureView";
    }
    [_dbController trackEventWithCategory:category withAction:@"switchedLanguage" withLabel:_dbController.langcolname withValue:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.view.backgroundColor = [UIColor colorWithRed:6./256. green:113./256. blue:171./256. alpha:1];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    if (self.popover) {
        [self.popover dismissPopoverAnimated:NO];
        self.popover = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == nil) {
        DDLogError(@"Trying to push a nil view controller?!");
        return;
    }
    CLS_LOG(@"SOBNavigationViewController: pushViewController %@", [viewController class]);
    _isPushingViewController = YES;
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"mäh" style:UIBarButtonItemStylePlain target:nil action:nil];

    [super pushViewController:viewController animated:animated];
}

- (void)setSplitViewBarButton:(UIBarButtonItem *)splitViewBarButton {
    _splitViewBarButton = splitViewBarButton;
    NSMutableArray *tmp = [self.topViewController.navigationItem.leftBarButtonItems mutableCopy];
    [tmp insertObject:splitViewBarButton atIndex:0];
    //self.topViewController.navigationItem.leftBarButtonItems = tmp;
}

- (ImageViewController *) imageViewController {
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc isKindOfClass:[ImageViewController class]]) {
        return (ImageViewController*) vc;
    }
    return nil;
}


- (ImageGridViewController *) imageGridViewController:(BOOL)requireOnTop {
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc isKindOfClass:[ImageGridViewController class]]) {
        return (ImageGridViewController*) vc;
    } else {
        if (!requireOnTop && [self.viewControllers count] > 2) {
            vc = [self.viewControllers objectAtIndex:1];
            if ([vc isKindOfClass:[ImageGridViewController class]]) {
                return (ImageGridViewController*) vc;
            }
            if (IS_PHONE) {
                // on phone it might also be on position 3
                for (UIViewController* tmp in self.viewControllers) {
                    if ([tmp isKindOfClass:[ImageGridViewController class]]) {
                        return (ImageGridViewController*) tmp;
                    }
                }
            }
        }
    }
    return nil;
}
- (HomescreenViewController *) homescreenViewController {
    return (HomescreenViewController *) [self.viewControllers objectAtIndex:0];
}


#pragma mark UINavigationControllerDelegate


- (UIBarButtonItem*) headerBarButtonItemWithImage:(UIImage*)image andText:(NSString*)text target:(id)target action:(SEL)selector {
    return [self headerBarButtonItemWithImage:image andText:text target:target action:selector accessibilityIdentifier:nil accessibilityLabel:nil];
}
- (UIBarButtonItem*) headerBarButtonItemWithImage:(UIImage*)image andText:(NSString*)text target:(id)target action:(SEL)selector accessibilityIdentifier:(NSString *)accessibilityId accessibilityLabel:(NSString *)accessibilityLabel {
    return [self headerBarButtonItemOfType:BARBUTTON withImage:image andText:text target:target action:selector accessibilityIdentifier:accessibilityId accessibilityLabel:accessibilityLabel];
}
- (UIBarButtonItem*) headerBarButtonItemOfType:(ButtonType)buttonType withImage:(UIImage*)image andText:(NSString*)text target:(id)target action:(SEL)selector {
    return [self headerBarButtonItemOfType:buttonType withImage:image andText:text target:target action:selector accessibilityIdentifier:nil accessibilityLabel:nil];
}
- (UIBarButtonItem*) headerBarButtonItemOfType:(ButtonType)buttonType withImage:(UIImage*)image andText:(NSString*)text target:(id)target action:(SEL)selector accessibilityIdentifier:(NSString *)accessibilityId accessibilityLabel:(NSString *)accessibilityLabel {
    
    
    if (buttonType == BARBUTTON || buttonType == BARBACKBUTTON) {
        UIBarButtonItem *button = nil;
        if (image) {
            button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
        } else {
            button = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:target action:selector];
        }
        if (accessibilityId) {
            button.isAccessibilityElement = YES;
            button.accessibilityLabel = accessibilityLabel ? accessibilityLabel : text;
            button.accessibilityIdentifier = accessibilityId;
        }
        return button;
    }
    
//    SOBButtonImage* buttonWithImage
//    = [[SOBButtonImage alloc] initContentButtonWithImage:image andText:text];
    SOBButtonImage* buttonWithImage = [[SOBButtonImage alloc] initButtonOfType:buttonType withImage:image andText:text];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonWithImage];
    [barButtonItem setTarget:target];
    [barButtonItem setAction:selector];
    if (accessibilityId) {
        buttonWithImage.isAccessibilityElement = YES;
        buttonWithImage.accessibilityLabel = accessibilityLabel ? accessibilityLabel : text;
        buttonWithImage.accessibilityIdentifier = accessibilityId;
    }
    [buttonWithImage addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Default"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return barButtonItem;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    CLS_LOG(@"SOBNavigationViewController: willShowViewController. %@", [viewController class]);
    [self updateNavigationButtonItems:viewController];
}

- (void)updateNavigationButtonItems:(UIViewController *)viewController {
    NSLog(@"will show view controller.");
    
    BOOL isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    BOOL isHomescreen = [viewController isKindOfClass:[HomescreenViewController class]];
    BOOL isImageGrid = [viewController isKindOfClass:[ImageGridViewController class]];
    BOOL isImageView = [viewController isKindOfClass:[ImageViewController class]];
    BOOL isMyNotes = [viewController isKindOfClass:[MyNotesRootViewController class]];
    BOOL isStaticContent = [viewController isKindOfClass:[StaticContentViewController class]];
    BOOL isBookmarksTable = [viewController isKindOfClass:[BookmarksTableViewController class]];
    BOOL isTrainingViewController = [viewController isKindOfClass:[TrainingViewController class]];
    if (isStaticContent && !IS_PHONE) {
        // we want the same buttons for my notes as for static content.
        isMyNotes = isStaticContent;
    }
    BOOL isPrevTrainingResults = [viewController isKindOfClass:[TrainingResultsTableViewController class]];
    BOOL isMasterViewController = [viewController isKindOfClass:[MasterViewController class]];
    BOOL isTrainingMode = NO;
    BOOL isTrainingPaused = NO;
    BOOL isTrainingEnded = NO;
    
    NSString *title = nil;
    if (isImageView) {
        ImageViewController *ivc = ((ImageViewController *)viewController);
        isTrainingMode = ivc.trainingMode;
        isTrainingPaused = ivc.pausedTraining;
        isTrainingEnded = ivc.trainingEnded;
        
        title = ivc.navigationBarTitle;
        
        if (!title && isTrainingMode) {
            title = [[FigureDatasource defaultDatasource] trainingNameLocalized];
        }
    }
    if (isTrainingViewController) {
        isTrainingMode = YES;
        isTrainingPaused = YES;
        isTrainingEnded = NO;
        TrainingViewController *tvc = ((TrainingViewController *) viewController);
        if (tvc.viewMode == cTrainingViewModeEndResult) {
            isTrainingEnded = YES;
//            isTrainingPaused = YES;
        } else if (tvc.viewMode == cTrainingViewModePageResult) {
            isTrainingPaused = NO;
        }
    }

    
    NSMutableArray *leftButtons = [NSMutableArray array];
    NSMutableArray *rightButtons = [NSMutableArray array];
    
    if (IS_PHONE && isBookmarksTable) {
        rightButtons = [viewController.navigationItem.rightBarButtonItems mutableCopy];
    }
    
    if (IS_PHONE && isMasterViewController) {
        if (!((MasterViewController*)viewController).chapterId) {
            [rightButtons addObject:[self headerBarButtonItemWithImage:nil andText:NSLocalizedString(@"Index", nil) target:self action:@selector(pressedIndex:)]];
        }
    }
    
    
    if (isHomescreen && !IS_PHONE) {
        
        _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed:)];
        [rightButtons addObject:_searchButton];
        

    }
    
    Language *lang = [_dbController currentLanguage];
//    if (!isTrainingMode && (!isMyNotes || isStaticContent) && !isPrevTrainingResults) {
    if (!isTrainingMode && ((isHomescreen && !IS_PHONE) || isImageView || isImageGrid)) {
        _languageButton = [self headerBarButtonItemWithImage:nil andText:lang.label target:self action:@selector(languagePressed:) accessibilityIdentifier:@"language switcher" accessibilityLabel:nil];
        [rightButtons addObject:_languageButton];
    }
    
    if ((IS_PHONE && (isImageGrid || isImageView || isTrainingMode))
        || (!IS_PHONE && (!isMyNotes && !isPrevTrainingResults))) {
        NSString *trainingText = NSLocalizedString(@"Training", nil);
        if (isPhone) {
            trainingText = nil;
        }
        if (isTrainingMode && isTrainingEnded) {
            _resumeTrainingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(startTraining:)];
            [rightButtons addObject:_resumeTrainingItem];
        } else if (isTrainingMode && !isTrainingPaused) {
            _resumeTrainingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(startTraining:)];
            [rightButtons addObject:_resumeTrainingItem];
        } else if ((isTrainingMode && isTrainingPaused) || [_dbController hasRunningTraining]) {
            _resumeTrainingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startTraining:)];
            [rightButtons addObject:_resumeTrainingItem];
        } else {
            if (isImageView || isImageGrid) {
                _resumeTrainingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startTraining:)];
                [rightButtons addObject:_resumeTrainingItem];
                if (isImageView) {
                    if (!((ImageViewController *)viewController).isFigureInteractive) {
//                        _resumeTrainingItem.enabled = NO;
                        SOBButtonImage *btn = (SOBButtonImage *)_resumeTrainingItem.customView;
//                        btn.layer.opacity = 0.5;
//                        btn.opaque = NO;
//                        btn.alpha = 0.5;
//                        btn.imageView.alpha = 0.5;
                        
//                        UIView *mask = [[UIView alloc] initWithFrame:btn.frame];
//                        [mask setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
//                        [btn addSubview:mask];
                        [btn fakeDisable:YES];
                    }
                }
            }
        }
    }

    
//    if ((!isImageView && !isMyNotes && !isPrevTrainingResults) || isTrainingMode) {
    if ((IS_PHONE && (isImageGrid || isHomescreen)) ||
         (!IS_PHONE && (isImageGrid || isTrainingMode || isHomescreen))) {
//        [leftButtons addObject:_splitViewBarButton];
            [leftButtons addObject:[self headerBarButtonItemWithImage:[UIImage imageNamed:@"burger"]
                                                              andText:nil
                                                               target:self
                                                               action:@selector(chaptersPressed:)
                                    
                                              accessibilityIdentifier:@"chapters"
                                                   accessibilityLabel:NSLocalizedString(@"Chapters", nil)]];
    }
    
    if (isHomescreen) {
        
        
        _moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more-icon-white"] style:UIBarButtonItemStylePlain target:self action:@selector(morePressed:)];
        [rightButtons addObject:_moreButton];
        
        
        
        UIImage *image = [UIImage imageNamed:@"header-sobotta"];
        UIImageView *tmp = [[UIImageView alloc] initWithImage:image];
        tmp.contentMode = UIViewContentModeCenter;
        //tmp.frame = CGRectMake(0, 0, image.size.width, 30);
//        tmp.layer.backgroundColor = [UIColor greenColor].CGColor;
        //tmp.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        UIBarButtonItem *logo = [[UIBarButtonItem alloc] initWithCustomView:tmp];
        
        [leftButtons addObject:logo];
        
    }
    
    if (isImageGrid || isMyNotes || isPrevTrainingResults || isTrainingMode) {
//        [leftButtons addObject:[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(homePressed:)]];
        [leftButtons addObject:
         [self headerBarButtonItemWithImage:[UIImage imageNamed:@"header-button-home"]
                                    andText:nil
                                     target:self
                                     action:@selector(homePressed:)
                    accessibilityIdentifier:@"home"
                         accessibilityLabel:NSLocalizedString(@"Home", nil)]];
    }
    
    
    if ((IS_PHONE && isHomescreen) || (!IS_PHONE && !isTrainingMode)) {
        NSString *bookmarkTitle = NSLocalizedString(@"Bookmarks", nil);
        if (IS_PHONE) {
            bookmarkTitle = nil;
        }
        [rightButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarksPressed:)]];
    }
//    [rightButtons addObject:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bookmarks", nil) style:UIBarButtonItemStylePlain target:self action:@selector(bookmarksPressed:)]];
    //[buttons addObject:bookmarkButtonItem];
    
    //    [rightButtons addObject:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Resume Training", nil) style:UIBarButtonItemStylePlain target:self action:@selector(startTraining:)]];
    
    
    if (isImageView && !isTrainingMode) {
//        _actionsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsClicked:)];
        
        // the new designs somehow renamed the 'actions' button to 'more' .. whatever..
        _actionsButton = [self headerBarButtonItemWithImage:[UIImage imageNamed:@"header-button-action"]
                                   andText:nil
                                    target:self
                                    action:@selector(actionsClicked:)];
        [rightButtons addObject:_actionsButton];
        
        UIBarButtonItem *item = [self headerBarButtonItemWithImage:[UIImage imageNamed:@"barbutton-layers"] andText:NSLocalizedString(@"Layers", nil) target:self action:@selector(pressedLayers:)];
        [rightButtons insertObject:item atIndex:0];
    }
    if ((isImageView && !isTrainingMode) || [leftButtons count] == 0) {
//        viewController.navigationItem.backBarButtonItem = [self headerBarButtonItemWithImage:nil andText:@"back" target:nil action:nil];
        NSString* backtitle = nil;
        if ([self.viewControllers count] >= 2) {
            backtitle = [[self.viewControllers objectAtIndex:[self.viewControllers count]-2] title];
        }
        if (!backtitle || isImageView || isBookmarksTable) {
            backtitle = NSLocalizedString(@"Back", nil);
        }
        NSLog(@"SOBNavigationViewController - %@ : BackButton: %@", [viewController class], backtitle);
        UIBarButtonItem *backButton = [self headerBarButtonItemOfType:BARBACKBUTTON
                                                            withImage:nil
                                                              andText:backtitle
                                                               target:self action:@selector(backPressed:)
                                              accessibilityIdentifier:@"back"
                                                   accessibilityLabel:nil];
        [leftButtons addObject:backButton];
    }
    

    
    
    viewController.navigationItem.leftBarButtonItems = leftButtons;
    viewController.navigationItem.rightBarButtonItems = rightButtons;
    if (title){
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.text = title;
        titleView.numberOfLines = 2;
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.minimumScaleFactor = 0.5;
        [[SOThemeManager sharedTheme] prepareNavigationBarTitle:titleView];
        [titleView sizeToFit];
        NSLog(@"setting titleview.");
        viewController.navigationItem.titleView = titleView;
//        [viewController.navigationItem.titleView setBackgroundColor:[UIColor greenColor]];
    } else {
        viewController.navigationItem.titleView = [[UIView alloc] init];
//        [viewController.navigationItem.titleView setBackgroundColor:[UIColor greenColor]];
    }
    
    
    
    /*
    if (viewController.navigationItem.leftItemsSupplementBackButton) {
        // since the above property is by default NO, we can assume we already customized this navigationItem.
        return;
    }
    
    BOOL isImageGrid = [viewController isKindOfClass:[ImageGridViewController class]];
    
    NSMutableArray *leftButtons;
    if (viewController.navigationItem.leftBarButtonItems != nil) {
        leftButtons = [viewController.navigationItem.leftBarButtonItems mutableCopy];
    } else {
        leftButtons = [NSMutableArray arrayWithCapacity:1];
    }
    
    //UIBarButtonItem* tmp = [[UIBarButtonItem alloc] initWithTitle:@"Blah" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
    //viewController.navigationItem.backBarButtonItem = tmp;
    viewController.navigationItem.leftItemsSupplementBackButton = YES;
    //if (viewController == self.topViewController && self.splitViewBarButton) {
    //    [buttons addObject:self.splitViewBarButton];
    //}
    
    
    if (isImageGrid) {
        _homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(homeClicked:)];
        [leftButtons insertObject:_homeButton atIndex:0];
    }

    if (![leftButtons containsObject:_splitViewBarButton]) {
        [leftButtons addObject:_splitViewBarButton];
    }
    
    [leftButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    [leftButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    
    
    
    
    
    
    viewController.navigationItem.leftBarButtonItems = leftButtons;

    
    NSMutableArray *rightButtons;
    if (viewController.navigationItem.rightBarButtonItems != nil) {
        rightButtons = [viewController.navigationItem.rightBarButtonItems mutableCopy];
    } else {
        rightButtons = [NSMutableArray arrayWithCapacity:1];
    }

    [rightButtons addObject:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bookmarks", nil) style:UIBarButtonItemStylePlain target:self action:@selector(bookmarksPressed:)]];
    //[buttons addObject:bookmarkButtonItem];
    [rightButtons addObject:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Resume Training", nil) style:UIBarButtonItemStylePlain target:self action:@selector(startTraining:)]];
    
    
    if (!isImageGrid) {
        _actionsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsClicked:)];
        [rightButtons addObject:_actionsButton];
    }


    viewController.navigationItem.rightBarButtonItems = rightButtons;
     */

    NSMutableArray *leftButtonsDebug = [NSMutableArray array];
    NSMutableArray *rightButtonsDebug = [NSMutableArray array];
    for (UIBarButtonItem *item in leftButtons) {
        if (item.title) {
            [leftButtonsDebug addObject:item.title];
        } else if (item.action) {
            [leftButtonsDebug addObject:NSStringFromSelector(item.action)];
        } else {
            [leftButtonsDebug addObject:@"nil?"];
        }
    }
    for (UIBarButtonItem *item in rightButtons) {
        if (item.title) {
            [rightButtonsDebug addObject:item.title];
        } else if (item.action) {
            [rightButtonsDebug addObject:NSStringFromSelector(item.action)];
        } else {
            [rightButtonsDebug addObject:@"nil?"];
        }
    }
    CLS_LOG(@"updated navigation buttons. leftButtons: %@ rightButtons: %@", leftButtonsDebug, rightButtonsDebug);
}

- (void) languagePressed: (id) sender {
    if ([self dismissPopovers:_languagePopover]) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_shared" bundle:[NSBundle mainBundle]];
    if (IS_PHONE) {
        UINavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LanguageChooserTable"];
        
        //[self pushViewController:[vc topViewController] animated:YES];
        [self pushViewController:vc animated:YES];
        return;
    } else {
        UINavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LanguageChooser"];
        _languagePopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [_languagePopover presentPopoverFromBarButtonItem:_languageButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) pressedLayers: (id) sender {
    ImageViewController *ivc = (ImageViewController*) [self topViewController];
    [ivc pressedLayerButton:sender];
}

- (void) pressedIndex: (id) sender {
//    [self.storyboard ]
    [self.topViewController performSegueWithIdentifier:@"showIndex" sender:self];
}

- (void) backPressed: (id) sender {
    [self popViewControllerAnimated:YES];
}

- (void) searchPressed: (id) sender {
    HomescreenViewController *homescreen = [[self viewControllers] objectAtIndex:0];
    if (homescreen) {
        [homescreen openCategoriesGallery:0 requestItem:RequestedItemSearch currentViewController:nil];
    }
}

- (void) morePressed: (id) sender {
    if ([self dismissPopovers:_morePopover]) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MoreMenu" bundle:[NSBundle mainBundle]];
    UINavigationController *controller = [storyboard instantiateInitialViewController];
    MoreMenuTableViewController *moretvc = controller.topViewController;
    moretvc.sobNavigationController = self;
    
    if (IS_PHONE) {
        // on iphone, view must only be shown on homescreen.
        if ([[self topViewController] isKindOfClass:[HomescreenViewController class]]) {
            [self pushViewController:moretvc animated:YES];
        } else {
            CLS_LOG(@"morePressed, not pushing more menu because topViewController is not HomescreenViewController");
            [[DatabaseController Current] trackEventWithCategory:@"bug" withAction:@"doublepress" withLabel:@"morePressed" withValue:0];
        }
        return;
    }
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popover presentPopoverFromBarButtonItem:_moreButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    popover.delegate = self;
//    [popover presentPopoverFromRect:CGRectMake(0,0,0,0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.morePopover = popover;
}


- (BOOL) dismissPopovers:(UIPopoverController *)sender {
    for (NSString* popoverName in
         @[ @"_popover",
         @"_morePopover",
         @"_actionsPopover",
         @"_languagePopover",]) {
        UIPopoverController *popover = [self valueForKey:popoverName];
        if (popover) {
            [popover dismissPopoverAnimated:YES];
            [self setValue:nil forKey:popoverName];
            if (popover == sender) {
                return YES;
            }
        }
    }
    return NO;
    /*
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
        _popover = nil;
        return YES;
    }
    if (_morePopover) {
        [_morePopover dismissPopoverAnimated:YES];
        _morePopover = nil;
        return YES;
    }
    if (_actionsPopover) {
        [_actionsPopover dismissPopoverAnimated:YES];
        _actionsPopover = nil;
        return YES;
    }
    if (_gridSizePopover) {
        [_gridSizePopover dismissPopoverAnimated:YES];
        _gridSizePopover = nil;
        return YES;
    }
    if (_languagePopover) {
        [_languagePopover dismissPopoverAnimated:YES];
        return YES;
    }
    return NO;*/
}

- (void) chaptersPressed: (id) sender {
    [_dbController trackEventWithCategory:@"Home" withAction:@"touched" withLabel:@"Chapter" withValue:nil];
    if (_isPushingViewController) {
        return;
    }
    if (IS_PHONE) {
        ImageGridViewController *igvc = nil;
        if ([self.viewControllers count] > 1) {
            NSLog(@"SOBNavigationViewController: viewControllers is > 1");
            UINavigationController *top = [self.viewControllers lastObject];
            if ([top isKindOfClass:[ImageGridViewController class]]) {
                igvc = (ImageGridViewController *)top;
            }
            UINavigationController *tmp = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
            if ([tmp isKindOfClass:[AutocompleteViewController class]]) {
                [self popViewControllerAnimated:YES];
                return;
            }
            tmp = [self.viewControllers objectAtIndex:1];
            if ([tmp isKindOfClass:[MasterViewController class]]) {
                tmp = [self.viewControllers objectAtIndex:2];
                if ([tmp isKindOfClass:[MasterViewController class]]) {
                    //                MasterViewController *mvc = (MasterViewController *)tmp;
                    [self popViewControllerAnimated:YES];
                    return;
                }
            }
        }
        MasterViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
        
        if ([self.viewControllers count] == 1) {
            NSLog(@"SOBNavigationViewController: viewControllers count == 1, pushing view controller.");
            [self pushViewController:mvc animated:YES];
            return;
        }
        NSMutableArray *arr = [self.viewControllers mutableCopy];
        [self updateNavigationButtonItems:mvc];
        
        
        MasterViewController *mvc2 = nil;
        if (igvc) {
            mvc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
            FigureDatasource *fd = [FigureDatasource defaultDatasource];
            mvc2.chapterId = fd.chapterId;
            if (fd.sections) {
                mvc2.sections = fd.sections;
            } else {
                mvc2.sections = [NSArray array];
            }
            [self updateNavigationButtonItems:mvc2];
            [arr insertObject:mvc2 atIndex:1];
        }
        
        [arr insertObject:mvc atIndex:1];
        self.viewControllers = arr;
        [self popToViewController:mvc2 ? mvc2 : mvc animated:YES];
        return;
    }
    if (_splitViewBarButton) {
        [_splitViewBarButton.target performSelector: _splitViewBarButton.action withObject: _splitViewBarButton];

    }
}

- (void) homePressed: (id) sender {
    if (_isPushingViewController) {
        DDLogError(@"homePressed, but isPushingViewController is nil. doing nothing.");
        return;
    }
    [self popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kStartTrainingAlert) {
        if (buttonIndex == 2) {
            [self doStartTraining:YES];
        } else if (buttonIndex == 1) {
            [self doStartTraining:NO];
        }
    } else if (alertView.tag == kAlertPhoneStartTraining) {
        if (buttonIndex == 1) {
            [self doStartTraining:YES];
        }
    } else if (alertView.tag == kAlertPhoneResumeTraining) {
        if (buttonIndex == 1) {
            [self doStartTraining:NO];
        }
    }
}

- (void) startTraining: (id) sender {
    [_dbController trackEventWithCategory:@"Menu" withAction:@"touched" withLabel:@"TrainingStart" withValue:nil];
    UIViewController *vc = [self.viewControllers lastObject];
	BOOL createNewTraining = YES;
    
    if ([vc isKindOfClass:[ImageViewController class]]) {
        if (!((ImageViewController *)vc).isFigureInteractive) {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"This figure can not be used for training.", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
    }
    
    if (IS_PHONE) {
        if ([vc isKindOfClass:[TrainingViewController class]]){
            // training is (probably) paused.
            TrainingViewController *tvc = ((TrainingViewController *) vc);
            ImageViewController *ivc = [self.viewControllers objectAtIndex:[self.viewControllers count] - 2];
            if (tvc.viewMode == cTrainingViewModeEndResult) {
                // training is ended.
                [self popToViewController:[self imageGridViewController:NO] animated:YES];
                return;
            } else if (tvc.viewMode == cTrainingViewModePageResult) {
                if ([ivc isKindOfClass:[ImageViewController class]]) {
                    [ivc pauseTraining];
                    [self updateNavigationButtonItems:tvc];
                    return;
                }
            } else if (tvc.viewMode == cTrainingViewModeIntermediateResult) {
                if ([ivc isKindOfClass:[ImageViewController class]]) {
                    if ([ivc numberOfLabelsToGuess] < 1) {
                        [ivc showPageResult];
                        [self updateNavigationButtonItems:tvc];
                        return;
                    }
                }
            }
            [ivc continueTraining:tvc];
//            [self popViewControllerAnimated:YES];
            return;
        }
    }
    
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)vc;
        if (ivc.trainingMode) {
            createNewTraining = NO;
        }
    }
    
    if (createNewTraining && ([vc isKindOfClass:[ImageViewController class]]
        || [vc isKindOfClass:[ImageGridViewController class]])) {

        // only ask the user if he actually CAN create a new training, otherwise it will always be a resume.
        
        if ([_dbController hasRunningTraining]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Training in Progress", nil) message:NSLocalizedString(@"Do you want to resume the current training or start a new one?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Resume Training", nil), NSLocalizedString(@"Start New Training", nil), nil];
            alertView.tag = kStartTrainingAlert;
            [alertView show];
            return;
        }
    } else {
        createNewTraining = NO;
    }
    if (IS_PHONE) {
        ImageViewController *ivc = [self imageViewController];
        if (!ivc || ![ivc trainingMode]) {
            if (createNewTraining) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Start Training", nil) message:NSLocalizedString(@"Do you want to start a new training?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                alertView.tag = kAlertPhoneStartTraining;
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Resuming Training", nil) message:NSLocalizedString(@"Do you want to resume the currently running training?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                alertView.tag = kAlertPhoneResumeTraining;
                [alertView show];
            }
            return;
        }
    }
    [self doStartTraining:createNewTraining];
}


- (void) doStartTraining: (BOOL)createNewTraining {
    ImageViewController *ivc = [self imageViewController];
        
    BOOL animateIvcPush = YES;
    if (ivc && ![ivc trainingMode] && !createNewTraining) {
        // when just switching ImageViewController with a new instance, do not animate it at all.
        [self popViewControllerAnimated:NO];
        animateIvcPush = NO;
        ivc = nil;
    }
    if (!ivc) {
        ImageGridViewController *igvc = [self imageGridViewController:NO];
        FigureDatasource *figureDatasource;
        if (igvc && createNewTraining) {
            figureDatasource = igvc.figureDatasource;
            FigureInfo *firstFigure = [figureDatasource figureAtGlobalIndex:0];
            [figureDatasource setCurrentSelection:firstFigure];
        } else {
            figureDatasource = [FigureDatasource defaultDatasource];
        }
        ivc = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
        if (!createNewTraining) {
            Training *training = [_dbController getRunningTraining];
            training.laststart = [[NSDate alloc] init];
            [training.managedObjectContext save:nil];
            int idx = [training.currentindex intValue];
            if (idx < 0 || idx > 10000) {
                idx = 0;
            }
            [figureDatasource setCurrentSelectionIndex:idx];
            [figureDatasource loadForTraining:training finished:^{
                [ivc setFigure:figureDatasource];
                [ivc startTrainingOrPostpone:_resumeTrainingItem createOption:(createNewTraining ? CreateTrainingOptionAllFromDatasource : CreateTrainingOptionResume)];
                [self pushViewController:ivc animated:animateIvcPush];
            }];
        } else {
            [ivc setFigure:figureDatasource];
            [ivc startTrainingOrPostpone:_resumeTrainingItem createOption:(createNewTraining ? CreateTrainingOptionAllFromDatasource : CreateTrainingOptionResume)];
            [self pushViewController:ivc animated:animateIvcPush];
        }
    } else {
        if (ivc.trainingMode) {
            [ivc pauseTraining];
        } else {
            
            [ivc startTrainingOrPostpone:_resumeTrainingItem createOption:(createNewTraining ? CreateTrainingOptionSingleFigure : CreateTrainingOptionResume)];
        }
    }
}

- (void) actionsClicked: (id) sender {
    if (_actionsPopover) {
        [_actionsPopover dismissPopoverAnimated:YES];
        _actionsPopover = nil;
        return;
    }
    
    if (IS_PHONE) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add to Bookmarks", nil), nil, nil];
        actionSheet.tag = kActionSheetActions;
        [actionSheet showInView:self.view];
        return;
    }
    UIStoryboard *actionsStoryboard = [UIStoryboard storyboardWithName:@"ImageActionsStoryboard" bundle:[NSBundle mainBundle]];
    
    UINavigationController *vc = [actionsStoryboard instantiateInitialViewController];
    ImageActionsViewController *iavc = (ImageActionsViewController*)vc.topViewController;
    iavc.sobParentController = self;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    popover.delegate = self;
    NSLog(@"actions clicked. size: before: %f", vc.view.frame.size.height);
    [popover presentPopoverFromBarButtonItem:_actionsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    NSLog(@"actions clicked. size: before: %f", vc.view.frame.size.height);
//    [vc.view sizeToFit];
    NSLog(@"actions clicked. size: after : %f", vc.view.frame.size.height);
//    [popover setPopoverContentSize:vc.view.frame.size];
//    [popover setPopoverContentSize:CGSizeMake(300, 80) animated:NO];
    _actionsPopover = popover;
}

- (void) showActionsPopover:(UIViewController *)vc {
    _nextActionsPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    [_actionsPopover dismissPopoverAnimated:YES];
}


- (void) homeClicked: (id) sender {
    MainSplitViewController *splitViewController = (MainSplitViewController *)self.splitViewController;
    if (splitViewController.leftPopupController) {
        [splitViewController.leftPopupController dismissPopoverAnimated:NO];
    }
    HomescreenViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Homescreen"];
    //    controller
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIViewController *tmpRootController = appDelegate.window.rootViewController;
    [appDelegate.window setRootViewController:controller];
    [appDelegate.window setRootViewController:tmpRootController];
    
    /*
     [UIView beginAnimations:@"suck" context:nil];
     [UIView setAnimationTransition:116 forView:controller.view cache:YES];
     [UIView setAnimationDuration:1];
     [appDelegate.window setRootViewController:tmpRootController];
     [UIView commitAnimations];
     */
    //controller.modalTransitionStyle = 116;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [appDelegate.window.rootViewController presentViewController:controller animated:YES completion:^{
        [tmpRootController dismissViewControllerAnimated:NO completion:nil];
        appDelegate.window.rootViewController = controller;
    }];

}

- (void)backButtonPressed {
    
}

- (void)bookmarksPressed:(id) sender {
    if ([self dismissPopovers:_popover]) {
        return;
    }
    UIStoryboard *bookmarks = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:nil];
    UINavigationController *controller = [bookmarks instantiateInitialViewController];
    //[self performSegueWithIdentifier:@"BookmarksPopover" sender:sender];
    BookmarksTableViewController *bmViewController = (BookmarksTableViewController*)controller.topViewController;
    bmViewController.bookmarksDelegate = self;
    bmViewController.showSmartBookmarklists = YES;
    
    if (IS_PHONE) {
        // on iphone, view must only be shown on homescreen.
        if ([[self topViewController] isKindOfClass:[HomescreenViewController class]]) {
            [self pushViewController:bmViewController animated:YES];
        } else {
            CLS_LOG(@"bookmarksPressed, not pushing more menu because topViewController is not HomescreenViewController");
            [[DatabaseController Current] trackEventWithCategory:@"bug" withAction:@"doublepress" withLabel:@"bookmarksPressed" withValue:0];
        }
        return;
    }

    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popover.delegate = self;
    [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"SOBNavigationViewController: didShowViewController.");
    _isPushingViewController = NO;
    /*
    NSLog(@"did show view controller.");
    NSMutableArray *buttons;
    if (viewController.navigationItem.leftBarButtonItems != nil) {
        buttons = [viewController.navigationItem.leftBarButtonItems mutableCopy];
    } else {
        buttons = [NSMutableArray arrayWithCapacity:1];
    }
    [buttons addObject:[[UIBarButtonItem alloc] initWithTitle:@"Hahaha" style:UIBarButtonItemStylePlain target:nil action:nil]];
    viewController.navigationItem.leftBarButtonItems = buttons;
    
    self.navigationBar.
     */
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"should dismiss popover.");
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"did dismiss popover");
    if (popoverController == _popover) {
        _popover = nil;
    }
    if (popoverController == _actionsPopover) {
        _actionsPopover = nil;
    }
    if (popoverController == _morePopover) {
        _morePopover = nil;
    }
}


- (void) openFiguresForBookmarkList: (Bookmarklist *)bookmarkList {
    [self dismissPopovers:nil];
    
    if (IS_PHONE) {
        BookmarksTableViewController *btvc = (BookmarksTableViewController *)[self.viewControllers lastObject];
        if ([btvc isKindOfClass:[BookmarksTableViewController class]]) {
            if (!btvc.allowBookmarkListEditing) {
                // assume we are in the 'add to bookmarks' - scheme :)
                [self popViewControllerAnimated:YES];
                ImageViewController *ivc = [self imageViewController];
                if (ivc) {
                    // add a single figure to the bookmark.
                    FigureDatasource *ds = [FigureDatasource defaultDatasource];
                    [ds addFigure:[ds getCurrentSelection] toBookmarklist:bookmarkList];
                } else {
                    // todo
                }
                return;
            }
        }
    }
    
    ImageGridViewController *igvc = [self imageGridViewController:YES];
    if (igvc) {
        FigureDatasource *figureDatasource = igvc.figureDatasource;
        [figureDatasource loadForBookmarklist:bookmarkList];
    } else {
        [self popToRootViewControllerAnimated:NO];
        [[self homescreenViewController] openCategoriesGallery:0 requestItem:RequestedItemNone currentViewController:nil];
        FigureDatasource *figureDatasource = [FigureDatasource defaultDatasource];
        [figureDatasource loadForBookmarklist:bookmarkList];
        [self.viewControllers lastObject];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetActions) {
        if (buttonIndex == 0) {
            UIStoryboard *bookmarks = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:nil];
            UINavigationController *controller = [bookmarks instantiateInitialViewController];
            //[self performSegueWithIdentifier:@"BookmarksPopover" sender:sender];
            BookmarksTableViewController *bmViewController = (BookmarksTableViewController*)controller.topViewController;
            bmViewController.bookmarksDelegate = self;
            bmViewController.allowBookmarkListEditing = NO;
            [self pushViewController:bmViewController animated:YES];
        } /*else if (buttonIndex == 1) {
            ImageViewController *ivc = (ImageViewController *)[self.viewControllers lastObject];
            [ivc startPrinting:nil];
        }*/
    }
}


@end
