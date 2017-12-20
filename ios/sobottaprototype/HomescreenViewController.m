//
//  HomescreenViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "HomescreenViewController.h"
#import "MainSplitViewController.h"
#import "AppDelegate.h"
#import "NAImageAnnotationView.h"
#import "SimpleAnnotation.h"
#import "LineView.h"
#import "HumanOverlay.h"
#import "SOBNavigationViewController.h"
#import "Contest100Provider.h"
#import "RepetitionResumeViewController.h"
#import "GAI.h"
#import "GAIFields.h"
//#import <FacebookSDK/FacebookSDK.h>

#define DETAIL_SCALE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.40 : 0.9

@interface HomescreenViewController ()

@property (weak, nonatomic) IBOutlet UIView *resumeContainer;
@property RepetitionResumeViewController *resumeViewController;
@property (weak, nonatomic) IBOutlet UIView *buyLascheWrapper;

@end

@implementation HomescreenViewController

- (void)updateScrollViewScale {
    _scrollView.contentSize = _imageView.image.size;
    _scrollView.minimumZoomScale = _scrollView.frame.size.height / _imageView.image.size.height;
    _imageView.frame = [self centeredFrameForScrollView:_scrollView andUIView:_imageView];
    _drawView.frame = _scrollView.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _scrollView.maximumZoomScale = 0.42;
        _scrollView.minimumZoomScale = MAX(_scrollView.minimumZoomScale, 0.11);
    }
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width/2, 0, 5, 5) animated:YES];
    [self repositionAnnotations];

}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    //NSLog(@"Did rotate! - scrollview: %f %f image frame size: %f %f", _scrollView.frame.size.width, _scrollView.frame.size.height, _imageView.image.size.width, _imageView.image.size.height);
    [self updateScrollViewScale];
}

- (void) didRotate:(NSNotification *)notification
{

}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
//    _resumeContainer.intrinsicContentSize =
    RepetitionResumeViewController *ctrl = (RepetitionResumeViewController *) container;
    CGRect frame = _resumeContainer.frame;
    CGFloat bottom = CGRectGetMaxY(frame);
    frame.size.height = ctrl.preferredContentSize.height;
    frame.origin.y = bottom - frame.size.height;
    DDLogVerbose(@"weird.. wtf is this? Changing frame from %@ to %@", NSStringFromCGRect(_resumeContainer.frame), NSStringFromCGRect(frame));
    _resumeContainer.frame = frame;
    [self updateBuyLascheWrapperPosition];
}

- (void)updateBuyLascheWrapperPosition {
    if (IS_PHONE) {
        // in Phone mode the buy lasche must be moved down to align with the start training view.
        if (_resumeContainer.hidden) {
            CGRect buyFrame = _buyLascheWrapper.frame;
            buyFrame.origin.y = CGRectGetMaxY(_scrollView.frame) - buyFrame.size.height;
            _buyLascheWrapper.frame = buyFrame;
        } else {
            CGRect frame = _resumeContainer.frame;
            CGRect buyFrame = _buyLascheWrapper.frame;
            buyFrame.origin.y = frame.origin.y - buyFrame.size.height;
            _buyLascheWrapper.frame = buyFrame;
        }
    }
}

- (void)viewWillLayoutSubviews {
//- (void)viewDidLayoutSubviews {
    if (IS_PHONE) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        
        if (isPortrait) {
            _resumeContainer.hidden = NO;
            CGFloat originX = _resumeContainer.frame.origin.y;
            CGRect frame = self.scrollWrapper.frame;
            frame.size.height = originX;
            self.scrollWrapper.frame = frame;
            
            DDLogVerbose(@"resumeViewController.frame: %@", NSStringFromCGRect(self.resumeViewController.view.frame));
            [self.resumeViewController.view sizeToFit];
            DDLogVerbose(@"resumeViewController.frame: %@", NSStringFromCGRect(self.resumeViewController.view.frame));
            
        } else {
            CGFloat maxY = CGRectGetMaxY(_resumeContainer.frame);
            _resumeContainer.hidden = YES;
            CGRect frame = self.scrollWrapper.frame;
            frame.size.height = maxY;
            self.scrollWrapper.frame = frame;
        }
        [self updateBuyLascheWrapperPosition];
        DDLogVerbose(@"_resumeContainer.frame: %@ / scrollWrapper frame: %@", NSStringFromCGRect(_resumeContainer.frame), NSStringFromCGRect(self.scrollWrapper.frame));
        [self.scrollWrapper setNeedsLayout];
    }
}

- (IBAction)bookmarksPressed:(id)sender {
    if (_bookmarksPopover) {
        [_bookmarksPopover dismissPopoverAnimated:YES];
        _bookmarksPopover = nil;
        return;
    }
    UIStoryboard *bookmarks = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:nil];
    UINavigationController *controller = [bookmarks instantiateInitialViewController];
    BookmarksTableViewController *bookmarksController = [[controller childViewControllers] lastObject];
    bookmarksController.bookmarksDelegate = self;
    //[self performSegueWithIdentifier:@"BookmarksPopover" sender:sender];
    _bookmarksPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
    _bookmarksPopover.delegate = self;
    [_bookmarksPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections: UIPopoverArrowDirectionAny animated:YES];
}


- (void) languageChanged:(NSNotification *)notification {
    for (SimpleAnnotation *a in _drawView.annotations) {
        if (a.chapterId) {
//            NSLog(@"changing name to %@", [dbController chapterNameById:a.chapterId]);
            a.image.label.text = [dbController chapterNameById:a.chapterId];
        }
    }
}

- (IBAction)pressedBuySobotta:(id)sender {
    FullVersionController *fvc = [FullVersionController instance];
    if ([fvc hasPurchased]) {
        if (fvc.status == DownloadStatusPaused) {
            [fvc resumeDownload];
            return;
        } else if (fvc.status == DownloadStatusInProgress) {
            [fvc pauseDownload];
            return;
        }
        if ([fvc hasFullVersion]) {
            return;
        }
    }
    [dbController trackEventWithCategory:@"Home" withAction:@"touched" withLabel:@"BuyButton" withValue:nil];
    NSLog(@"pressed buy button. opening %@", SOB_PAID_APPLINK);
    
  
    [[FullVersionController instance] askForVoucherOnBuyClick:self chapterId:nil];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SOB_PAID_APPLINK]];
}

- (void) showContestView {
    UIViewController *root = self.splitViewController;
    if (IS_PHONE) {
        root = self.navigationController;
    }
    
    
    ContestView *cv = [[ContestView alloc] initForView:root.view];
    if (cv) {
        [root.view addSubview:cv];
        Contest100Provider *contest = [Contest100Provider defaultProvider];
        [contest didShowDialog];
        [[DatabaseController Current] trackEventWithCategory:@"Home" withAction:@"showed" withLabel:@"ContestView" withValue:nil];
    }
}

- (void)downloadStatusChanged: (NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(updateLasche) withObject:self waitUntilDone:NO];
//    [self updateLasche];
}

- (void)updateLasche {
    [self updateLasche:NO];
}

- (void)updateLasche:(BOOL)forceChange {
//    NSLog(@"status changed, update lasche.");
    FullVersionController *fvc = [FullVersionController instance];
    NSString* iphoneImage = NSLocalizedString(@"lasche-iphone", nil);
    NSString* ipadImage = NSLocalizedString(@"lasche", nil);
    
    BOOL changed = forceChange || _downloadStatus != fvc.status;
    _downloadStatus = fvc.status;

    BOOL hideStatusLabels = NO;
    BOOL hideLasche = NO;
    
    switch (fvc.status) {
        case DownloadStatusInit:
            _lascheLblStatus.text = NSLocalizedString(@"Initializing", nil);
            _lascheLblProgress.text = @"";
            break;
        case DownloadStatusFree:
            iphoneImage = NSLocalizedString(@"curliphone", nil);
            ipadImage = NSLocalizedString(@"curlipad", nil);
            hideStatusLabels = YES;
            break;
        case DownloadStatusSync:
            NSLog(@"Preparing ...");
            _lascheLblStatus.text = NSLocalizedString(@"Preparing...", nil);
            _lascheLblProgress.text = @"";
            break;
        case DownloadStatusInProgress:
            NSLog(@"Downloading ... %@", [fvc formatSizeAsMB:fvc.downloadProgress withPrecision:1]);
            _lascheLblStatus.text = NSLocalizedString(@"Downloading...", nil);
            _lascheLblProgress.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of %@ MB\nPress to pause", nil), [fvc formatSizeAsMB:fvc.downloadProgress withPrecision:1], [fvc formatSizeAsMB:fvc.downloadTotalSize withPrecision:0]];
//            NSLog(@"Downloading ... %@ // %@", [fvc formatSize:fvc.downloadProgress], _lascheLblProgress.text);
            break;
        case DownloadStatusPaused:
            _lascheLblStatus.text = NSLocalizedString(@"Paused", nil);
            _lascheLblProgress.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of %@ MB\nPress to resume", nil), [fvc formatSizeAsMB:fvc.downloadProgress withPrecision:1], [fvc formatSizeAsMB:fvc.downloadTotalSize withPrecision:0]];
            break;
        case DownloadStatusDone:
            _lascheLblStatus.text = NSLocalizedString(@"Finished", nil);
            _lascheLblProgress.text = @"";
            hideStatusLabels = YES;
            if (!fvc.hasFullVersion) {
                iphoneImage = NSLocalizedString(@"curliphone", nil);
                ipadImage = NSLocalizedString(@"curlipad", nil);
            }
            hideLasche = fvc.hasFullVersion;
            break;
    }
    if (!changed) {
        return;
    }
    _lascheLblStatus.hidden = hideStatusLabels;
    _lascheLblProgress.hidden = hideStatusLabels;
    _btnBuySobottaImage.hidden = hideLasche;
    if (IS_PHONE) {
        [_btnBuySobottaImage setImage:[UIImage imageNamed:iphoneImage]];
        //        [_btnBuySobottaImage setImage:[UIImage imageNamed:NSLocalizedString(@"curliphone", nil)]];
//        [_btnBuySobottaImage setImage:[UIImage imageNamed:NSLocalizedString(@"lasche-iphone", nil)]];
    } else {
        [_btnBuySobottaImage setImage:[UIImage imageNamed:ipadImage]];
        //        [_erbtnBuySobottaImage setImage:[UIImage imageNamed:NSLocalizedString(@"curlipad", nil)]];
//        [_btnBuySobottaImage setImage:[UIImage imageNamed:NSLocalizedString(@"lasche", nil)]];
    }
}

- (void) openUrlNotification:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"got openUrlNotification for user info: %@", userInfo);
    NSURL *url = [userInfo objectForKey:@"url"];
    if ([[url host] isEqualToString:@"upgrade"]) {
        [self pressedBuySobotta:nil];
    } else if ([[url host] isEqualToString:@"purchase"]) {
        // 0 is just the leading '/'
        NSString *productId = [[url pathComponents] objectAtIndex:1];
        NSLog(@"Starting in app purchase for %@", productId);
        [[FullVersionController instance] startInAppPurchaseWithActivityView:productId];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _downloadStatus = nil;
    
    [_btnBuySobotta setTitle:@"" forState:UIControlStateNormal];
    _downloadStatus = DownloadStatusInit;
    [self updateLasche:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStatusChanged:) name:SOBDOWNLOADSTATUSCHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openUrlNotification:) name:NOTIFICATION_OPEN_URL object:nil];

//    [self showContestView];
    
//    UIAlertView *tmp = [[UIAlertView alloc] initWithTitle:nil message:@"Leider nein" delegate:nil cancelButtonTitle:@"Weiter" otherButtonTitles:@"Nochmal", nil];
//    [tmp show];
    
    dbController = [DatabaseController Current];
    [dbController trackLang:[dbController langcolname]];
	// Do any additional setup after loading the view.
    
    [_imageView removeFromSuperview];
    UIImageView *tmpimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"human-narrow"]];
    self.imageView = tmpimg;
    _scrollView.contentSize = _imageView.frame.size;
    [_scrollView addSubview:_imageView];
    LineView *tmpview = [[LineView alloc] initWithFrame:self.scrollView.frame andViewController:self];
    self.drawView = tmpview;
    [self.scrollView.superview addSubview:self.drawView];
    //[self.view addSubview:self.drawView];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
     
    
    _scrollView.contentSize = _imageView.image.size;
    _scrollView.minimumZoomScale = _scrollView.frame.size.height / _imageView.image.size.height;
    _scrollView.maximumZoomScale = 1.0;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale];
    _imageView.userInteractionEnabled = YES;
    _imageView.frame = [self centeredFrameForScrollView:_scrollView andUIView:_imageView];


    /*
    [self addAnnotation:@"kopf-label.png" at:CGPointMake(100, 150) pointingTo:CGPointMake(1024,323) onRight:NO];
//    [self addAnnotation:@"gehirn-label.png" at:CGPointMake(200, 2500)];
    // allgemeine anatomie
    [self addAnnotation:@"kopf-label.png" at:CGPointMake(100, 400) pointingTo:CGPointMake(680, 1600) onRight:NO];
    // obere extremitaet
    [self addAnnotation:@"kopf-label.png" at:CGPointMake(-100, 80) pointingTo:CGPointMake(1270, 580) onRight:YES];
    // rumpf
    [self addAnnotation:@"kopf-label.png" at:CGPointMake(-100, 280) pointingTo:CGPointMake(1000, 867) onRight:YES];
    // untere extremitaet
    [self addAnnotation:@"kopf-label.png" at:CGPointMake(-100, 480) pointingTo:CGPointMake(1100, 1570) onRight:YES];
    [self repositionAnnotations];
     */
    
    
    SimpleAnnotation *tmpa;
    
    // Kopf in overview
    tmpa = [self addAnnotation:@"headzoom" label:@"Kopf" at:CGPointMake(100, 50) pointingTo:CGPointMake(280,300) onRight:NO chapterId:8];
    //tmpa.zoomTo = CGPointMake(_imageView.frame.size.width/2., 450);
    //tmpa.zoomTo = CGPointMake(_imageView.frame.size.width/2., 400);
    tmpa.zoomTo = CGPointMake(_imageView.frame.size.width/2., 1);
    tmpa.maxScale = DETAIL_SCALE;
    
    // Kopf in detail
    tmpa = [self addAnnotation:@"chp008_000" label:@"Kopf" at:CGPointMake(100, 80) pointingTo:CGPointMake(300,240) onRight:NO chapterId:8];
    tmpa.minScale = DETAIL_SCALE;
    
    //    [self addAnnotation:@"gehirn-label.png" at:CGPointMake(200, 2500)];
    // allgemeine anatomie
    tmpa = [self addAnnotation:@"chp001_000" label:@"Allgemeine Anatomie" at:CGPointMake(100, 870) pointingTo:CGPointMake(59, 1100) onRight:NO chapterId:1];
    tmpa.maxScale = DETAIL_SCALE;
    // obere extremitaet
    tmpa = [self addAnnotation:@"chp003_000" label:@"Obere Extremität" at:CGPointMake(-100, 350) pointingTo:CGPointMake(700, 750) onRight:YES chapterId:3];
    tmpa.maxScale = DETAIL_SCALE;
    
    // obere extremitaet rangezoomed
    tmpa = [self addAnnotation:@"chp003_000" label:@"Obere Extremität" at:CGPointMake(-100, 730) pointingTo:CGPointMake(3000, 680) onRight:YES chapterId:3];
    tmpa.minScale = DETAIL_SCALE;
    
    // rumpf
    tmpa = [self addAnnotation:@"rumpfzoom" label:@"Rumpf" at:CGPointMake(-100, 1100) pointingTo:CGPointMake(530, 1000) onRight:YES chapterId:2];
    tmpa.zoomTo = CGPointMake(_imageView.frame.size.width/2., 920);
    tmpa.maxScale = DETAIL_SCALE;
    // rumpf rangezoomed
    tmpa = [self addAnnotation:@"chp002_000" label:@"Rumpf" at:CGPointMake(-100, 1050) pointingTo:CGPointMake(379, 840) onRight:YES chapterId:2];
    tmpa.minScale = DETAIL_SCALE;
    // untere extremitaet
    tmpa = [self addAnnotation:@"chp004_000" label:@"Untere Extremität" at:CGPointMake(100, 1700) pointingTo:CGPointMake(100, 1700) onRight:NO chapterId:4];
    tmpa.maxScale = DETAIL_SCALE;
    
    
    // gehirn und rückenmark
    tmpa = [self addAnnotation:@"chp012_000" label:@"Gehirn und Rückenmark" at:CGPointMake(-100, 20) pointingTo:CGPointMake(420, 230) onRight:YES chapterId:12];
    tmpa.minScale = DETAIL_SCALE;
    // auge
    tmpa = [self addAnnotation:@"chp009_000" label:@"Auge" at:CGPointMake(-100, 240) pointingTo:CGPointMake(460, 290) onRight:YES chapterId:9];
    tmpa.minScale = DETAIL_SCALE;
    // ohr
    tmpa = [self addAnnotation:@"chp010_000" label:@"Ohr" at:CGPointMake(-100, 460) pointingTo:CGPointMake(500, 385) onRight:YES chapterId:10];
    tmpa.minScale = DETAIL_SCALE;
    // hals
    tmpa = [self addAnnotation:@"chp011_000" label:@"Hals" at:CGPointMake(100, 300) pointingTo:CGPointMake(380, 500) onRight:NO chapterId:11];
    tmpa.minScale = DETAIL_SCALE;
    
    
    
    // brusteingeweide
    tmpa = [self addAnnotation:@"chp005_000" label:@"Brusteingeweide" at:CGPointMake(100, 560) pointingTo:CGPointMake(380, 720) onRight:NO chapterId:5];
    tmpa.minScale = DETAIL_SCALE;
    // baucheingeweide
    tmpa = [self addAnnotation:@"chp006_000" label:@"Baucheingeweide" at:CGPointMake(100, 780) pointingTo:CGPointMake(310, 1030) onRight:NO chapterId:6];
    tmpa.minScale = DETAIL_SCALE;
    // Becken und Retroperitonealraum
    tmpa = [self addAnnotation:@"chp007_000" label:@"Becken und Retroperitonealraum" at:CGPointMake(100, 1000) pointingTo:CGPointMake(280, 1220) onRight:NO chapterId:7];
    tmpa.minScale = DETAIL_SCALE;
    // allgemeine anatomie reingezoomt
    tmpa = [self addAnnotation:@"chp001_000" label:@"Allgemeine Anatomie" at:CGPointMake(100, 1270) pointingTo:CGPointMake(100, 1270) onRight:NO chapterId:1];
    tmpa.minScale = DETAIL_SCALE;
    // untere extremitäten reingezoomt
    tmpa = [self addAnnotation:@"chp004_000" label:@"Untere Extremität" at:CGPointMake(100, 1490) pointingTo:CGPointMake(0, 1490) onRight:NO chapterId:4];
    tmpa.minScale = DETAIL_SCALE;

    
    [self repositionAnnotations];
#ifndef SOB_FREE
    _btnBuySobotta.hidden = YES;
    _btnBuySobottaImage.hidden = YES;
#endif


    [[InAppMessageController instance] showNewMessages: self.view];

}

- (SimpleAnnotation*)addAnnotation:(NSString *)imageName
                             label:(NSString *)label
                                at:(CGPoint)point
                        pointingTo:(CGPoint)targetPos
                           onRight:(BOOL)isRight
                         chapterId:(int) chapterId {
    if (chapterId) {
        label = [dbController chapterNameById:chapterId];
    }
    //UIImageView *annotation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HumanOverlay *annotation = [[HumanOverlay alloc] initWithImage:[UIImage imageNamed:imageName] andLabel:label];
    annotation.isAccessibilityElement = YES;
    annotation.accessibilityLabel = label;
    annotation.accessibilityIdentifier = imageName;
    CGSize size = annotation.frame.size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        size = CGSizeMake(75, 80);
    }
    [self.scrollWrapper addSubview:annotation];
    CGPoint imageLocation = point;
    annotation.frame = CGRectMake(imageLocation.x, imageLocation.y, size.width, size.height);
    //NSLog(@"annotation at %f %f / %f %f", annotation.frame.origin.x, annotation.frame.origin.y, annotation.frame.size.width, annotation.frame.size.height);
    SimpleAnnotation *a = [[SimpleAnnotation alloc] initWithTarget:targetPos at:(CGPoint)point image:annotation onRight:isRight];
    annotation.controller = self;
    annotation.annotation = a;
    [_drawView.annotations addObject:a];
    a.chapterId = chapterId;
    
    /*
    UIImage *kopf = [UIImage imageNamed:imageName];
    NAAnnotation *tmp = [NAAnnotation annotationWithPoint:point];
    NAImageAnnotationView *imageAnnotationView = [[NAImageAnnotationView alloc] initWithAnnotation:tmp andImage:kopf onView:_mapView animated:NO];
    //    [_mapView addAnnotation:imageAnnotationView animated:YES];
    [_mapView.pinAnnotations addObject:imageAnnotationView];
	[_mapView addObserver:imageAnnotationView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
     */
    return a;
}

- (void)repositionAnnotations {
    if (NO) {
        CGSize size = _scrollWrapper.frame.size;
        CGPoint center = [_scrollWrapper convertPoint:CGPointMake(size.width/2, size.height/2) toView:self.imageView];
        //NSLog(@"Current center: %f, %f", center.x, center.y);
    }
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    
    float scale = self.scrollView.zoomScale;
    for (SimpleAnnotation *a in _drawView.annotations) {
        BOOL ishidden = NO;
        if (a.minScale) {
            ishidden = scale < a.minScale;
        }
        if (a.maxScale) {
            ishidden = scale > a.maxScale;
        }
        if (ishidden) {
            //a.hidden = ishidden;
            //continue;
        }
        CGPoint imageLocation = a.point;
        CGPoint newLocation = [_scrollWrapper convertPoint:imageLocation fromView:self.imageView];
        
        CGSize size = a.image.frame.size;
        if (a.isRight) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                newLocation.x = _scrollView.frame.size.width - size.width - 20;
            } else {
                newLocation.x = _scrollView.frame.size.width - size.width + (isLandscape ? imageLocation.x : imageLocation.x / 2);
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                newLocation.x = 20;
            } else {
                newLocation.x = isLandscape ? imageLocation.x : imageLocation.x / 2;
            }
        }
        a.image.frame = CGRectMake(newLocation.x, newLocation.y, size.width, size.height);
        a.hidden = ishidden;
    }
}

- (void) viewDidAppear:(BOOL)animated {
//    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
//    [self repositionAnnotations];
    [dbController trackView:@"Home"];
    [self updateScrollViewScale];

    UINavigationController *navController = [self.splitViewController.viewControllers objectAtIndex:0];
    if (navController) {
        [navController popToRootViewControllerAnimated:NO];
    }
    Contest100Provider *contest = [Contest100Provider defaultProvider];
    if ([contest needShowDialog]) {
        [self showContestView];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBDOWNLOADSTATUSCHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_OPEN_URL object:nil];
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setScrollWrapper:nil];
    [self setBtnBuySobotta:nil];
    [self setBtnBuySobottaImage:nil];
    [self setLascheLblStatus:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)openImageGrid {
    [self openImageGridNoPopNavController:NO];
}
- (void)openImageGridNoPopNavController:(BOOL)noPop {
    SOBNavigationViewController *sobNav = (SOBNavigationViewController *) self.navigationController;
    UIViewController *lastvc = [sobNav.viewControllers lastObject];
    if ([lastvc isKindOfClass:[ImageGridViewController class]]) {
        // nothing to do ..
    } else {
        BOOL pushImageGrid = YES;
        if (!noPop) {
            if ([sobNav.viewControllers count] > 2) {
                UIViewController *vc = [sobNav.viewControllers objectAtIndex:1];
                if ([vc isKindOfClass:[ImageGridViewController class]]) {
                    [sobNav popToViewController:vc animated:YES];
                    pushImageGrid = NO;
                } else {
                    [sobNav popToRootViewControllerAnimated:NO];
                }
            }
        }
        if (pushImageGrid) {
            _requestItem = RequestedItemNone;
            [self performSegueWithIdentifier:@"showImageGrid" sender:self];
        }
    }
}

- (void)openCategoriesGallery:(int)chapterId currentViewController:(UIViewController *)viewController {
    [self openCategoriesGallery:chapterId requestItem:RequestedItemNone currentViewController:viewController];
}
- (void)openCategoriesGallery:(int)chapterId requestItem:(RequestedItem)requestedItem currentViewController:(UIViewController *)viewController {
    if (viewController != nil && [self.navigationController topViewController] != viewController) {
        NSLog(@"WARNING, pushing stupid stuff.");
        [[DatabaseController Current] trackEventWithCategory:@"bug" withAction:@"doublepressCatGallery" withLabel:[NSString stringWithFormat:@"c:%d r:%d", chapterId, requestedItem] withValue:0];
        return;
    }
    if (_currentPopover) {
        [_currentPopover dismissPopoverAnimated:NO];
    }
    if (_bookmarksPopover) {
        [_bookmarksPopover dismissPopoverAnimated:NO];
    }
    
    
    _selectedChapterId = chapterId;
    FigureDatasource *datasource = [FigureDatasource defaultDatasource];
    if (requestedItem != RequestedItemJumpToSection || datasource.chapterId != chapterId) {
        [datasource loadForChapterId:chapterId];
    }
//    MainSplitViewController *msvc = (MainSplitViewController*)self.splitViewController;
//    msvc.chapterId = chapterId;
    _requestItem = requestedItem;
    
    [self performSegueWithIdentifier:@"showImageGrid" sender:self];

//    if (IS_PHONE) {
//        MasterViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
//        MasterViewController *mvc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
//        mvc2.chapterId = chapterId;
//        [(SOBNavigationViewController *)self.navigationController updateNavigationButtonItems:mvc];
//        [(SOBNavigationViewController *)self.navigationController updateNavigationButtonItems:mvc2];
//        
//        [self.navigationController pushViewController:mvc animated:NO];
//        [self.navigationController pushViewController:mvc2 animated:NO];
//        
//    }
    
    
    return;
    /*
    MainSplitViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesGallery"];
    controller.chapterId = chapterId;
    //    controller
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIViewController *tmpRootController = appDelegate.window.rootViewController;
    
    [appDelegate.window setRootViewController:controller];
    [appDelegate.window setRootViewController:tmpRootController];
    
    
    if (requestedItem == RequestedItemSearch) {
        [UIView transitionFromView:tmpRootController.view toView:controller.view duration:.2 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionTransitionCrossDissolve ) completion:^(BOOL finished){
            if (finished) {
                [appDelegate.window setRootViewController:controller];
                UINavigationController *tmp = [controller.viewControllers lastObject];
                ImageGridViewController *imageGrid = (ImageGridViewController *)tmp.topViewController;
                [imageGrid.searchBar becomeFirstResponder];
                NSLog(@"finished.");
            } else {
                NSLog(@"Unfinished.");
            }
        }];
    } else {
        [UIView transitionFromView:tmpRootController.view toView:controller.view duration:.5 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionTransitionCurlUp ) completion:^(BOOL finished){
            if (finished) {
                [appDelegate.window setRootViewController:controller];
                NSLog(@"finished.");
            } else {
                NSLog(@"Unfinished.");
            }
        }];
    }
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}




#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
    /*
    UIImageView *human = imageView;
    CGSize size = human.image.size;
    human.frame = CGRectMake(0, 0, size.width, size.height);
    
    return human;*/
}


- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imageView.frame = [self centeredFrameForScrollView:scrollView andUIView:_imageView];
    NSLog(@"we did zoom. %f", scrollView.zoomScale);
    [_drawView setNeedsDisplay];
    [self repositionAnnotations];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_drawView setNeedsDisplay];
    [self repositionAnnotations];
}

- (void) dealloc {
    NSLog(@"Dealloc HomescreenViewController.");
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"HomescreenViewController.prepareForSegue: %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showChapterPopover"]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
		action = [barButton action];
		target = [barButton target];
		
		[barButton setTarget:self];
		[barButton setAction:@selector(dismiss:)];

		UINavigationController* dest = [segue destinationViewController];
        
        MasterViewController *master = (MasterViewController*)[dest topViewController];
        master.homescreen = self;
		self.currentPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
		self.currentPopover.delegate = self;
		
		//[[segue destinationViewController] setParentViewController:self];
	} else if ([[segue identifier] isEqualToString:@"showImageGrid"]) {
        ImageGridViewController *imageGrid = [segue destinationViewController];
        if (_requestItem == RequestedItemSearch){
            imageGrid.requestSearch = YES;
        }
        if (_requestItem == RequestedItemSearchWithinMasterview) {
            imageGrid.requestSearch = YES;
            imageGrid.requestSearchFromMasterView = YES;
        }
        if (_requestItem == RequestedItemShowChapter) {
            [imageGrid loadMasterView:YES];
        }
        if (_requestItem == RequestedItemJumpToSection) {
            [imageGrid jumpToSectionAtPosition:_jumpToSectionPosition];
        }
    } else if ([segue.destinationViewController isKindOfClass:[RepetitionResumeViewController class]]) {
        self.resumeViewController = segue.destinationViewController;
        self.resumeViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        DDLogVerbose(@"resumeViewController.frame: %@", NSStringFromCGRect(self.resumeViewController.view.frame));
        [self.resumeViewController.view sizeToFit];
        DDLogVerbose(@"resumeViewController.frame: %@", NSStringFromCGRect(self.resumeViewController.view.frame));
        
        __weak HomescreenViewController *weakSelf = self;
        self.resumeViewController.onResumeClicked = ^void() {
            SOBNavigationViewController *nc = (SOBNavigationViewController *) weakSelf.navigationController;
            [nc doStartTraining:NO];
        };
    }

}

-(void)dismiss:(id)sender
{
    [self.showChapterButton setAction:action];
    [self.showChapterButton setTarget:target];
    ////or
	//  [sender setAction:action];
	//  [sender setTarget:target];
    [self.currentPopover dismissPopoverAnimated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	[self.showChapterButton setAction:action];
	[self.showChapterButton setTarget:target];
    self.currentPopover = nil;
	
	return YES;
}

//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    CGRect innerFrame = view.frame;
//    CGRect scrollerBounds = scrollView.bounds;
//    
//    if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) )
//    {
//        CGFloat tempx = view.center.x - ( scrollerBounds.size.width / 2 );
//        CGFloat tempy = view.center.y - ( scrollerBounds.size.height / 2 );
//        CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);
//        
//        scrollView.contentOffset = myScrollViewOffset;
//        
//    }
//    
//    UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
//    if ( scrollerBounds.size.width > innerFrame.size.width )
//    {
//        anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
//        anEdgeInset.right = -anEdgeInset.left; // I don't know why this needs to be negative, but that's what works
//    }
//    if ( scrollerBounds.size.height > innerFrame.size.height )
//    {
//        anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
//        anEdgeInset.bottom = -anEdgeInset.top; // I don't know why this needs to be negative, but that's what works
//    }
//    scrollView.contentInset = anEdgeInset;
//}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self openCategoriesGallery:0 requestItem:RequestedItemSearch currentViewController:self];
    searchBar.delegate = nil;
    return NO;
}

#pragma mark actions

#pragma mark - BookmarksDelegate

- (void)openFiguresForBookmarkList:(int)bookmarkListId {
    [self openCategoriesGallery:1 currentViewController:self];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == _bookmarksPopover) {
        _bookmarksPopover = nil;
    }
}


@end
