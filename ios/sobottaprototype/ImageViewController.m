//
//  ImageViewController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "DatabaseController.h"
#import	"ImageLayerViewController.h"
#import "NAPinAnnotationView.h"
#import "NAPrintRenderer.h"
#import "SOBNavigationViewController.h"
#import "DejalActivityView.h"
#import "Theme.h"
#import "Contest100Provider.h"
#import "NotesViewController.h"
#import "NAAnnotation.h"
#import "FigureProxy.h"
#import "CaptionViewController.h"
#import "GAI.h"
#import "SelectTrainingTypeViewController.h"
#import "Repetition_Figure+CoreDataClass.h"
#import "Repetition_FigureLabel+CoreDataClass.h"
#import "SpacedRepetitionCardOverlay.h"
#import "RepetitionTrainingInfoOverlayViewController.h"


@implementation QuestionInfo

@end


@interface ImageViewController ()

@property Repetition_FigureLabel *currentQuestionLabel;

@property (weak, nonatomic) IBOutlet SpacedRepetitionCardOverlay *overlayRepetitionQuestion;
@property (weak, nonatomic) IBOutlet UILabel *overlayRepetitionQuestionTitle;
@property (weak, nonatomic) IBOutlet UIButton *overlayRepetitionQuestionButton;

@property (weak, nonatomic) IBOutlet SpacedRepetitionCardOverlay *overlayRepetitionAnswer;
@property (weak, nonatomic) IBOutlet UILabel *overlayRepetitionAnswerTitle;
@property (weak, nonatomic) IBOutlet UILabel *overlayRepetitionAnswerBodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *overlayRepetitionAnswerButton1Repeat;
@property (weak, nonatomic) IBOutlet UIButton *overlayRepetitionAnswerButton2Hard;
@property (weak, nonatomic) IBOutlet UIButton *overlayRepetitionAnswerButton3Good;
@property (weak, nonatomic) IBOutlet UIButton *overlayRepetitionAnswerButton4Easy;
@property (weak, nonatomic) IBOutlet UIView *repetitionDebugView;
@property (weak, nonatomic) IBOutlet UITextView *repetitionDebugTextView;

@end

@implementation ImageViewController
@synthesize tapGestureRecognizer;
@synthesize datasource = _datasource;
@synthesize pagingScrollView;
@synthesize layerViewPopover;
@synthesize captionView;
@synthesize captionLabel;
@synthesize captionWebView;
@synthesize panGestureRecognizer;
@synthesize doubleTapGestureRecognizer;
@synthesize captionTapGestureRecognizer;
//Settings
@synthesize displayCaption;
@synthesize viewMode;
@synthesize allStructures;
@synthesize displayArtery;
@synthesize displayVein;
@synthesize displayNerve;
@synthesize displayMuscle;
@synthesize displayOther;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _currentFigureIndex = -1;
        _currentPage = -1;
        _isReloading = NO;
        _fullVersionController = [FullVersionController instance];
        _viewHasAppeared = NO;
        _currentFigure = nil;
        _currentRepetitionFigure = nil;
        _trainingNeedStart = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	KWLogDebug(@"[%@] viewDidLoad", self.class);
    
    self.pagingScrollView.backgroundColor = [UIColor whiteColor];
    self.trainingHeaderView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"sobotta-training-header-bg"]];
    self.trainingHeaderView.hidden = YES;
    self.trainingHeaderLabel.text = @"";
    self.captionLabel.text = @"";
    self.captionLabel.isAccessibilityElement = YES;
    self.captionLabel.accessibilityIdentifier = @"caption";
    self.captionWebView.opaque = NO;
    self.captionWebView.backgroundColor = [UIColor whiteColor];
	
	// Do any additional setup after loading the view, typically from a nib.
	
	self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
	self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
	[self.pagingScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
	self.tapGestureRecognizer.numberOfTapsRequired = 1;
	[self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
	self.tapGestureRecognizer.delegate = self;
	[self.pagingScrollView addGestureRecognizer:self.tapGestureRecognizer];
	
	self.captionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captionTapAction:)];
	self.tapGestureRecognizer.numberOfTapsRequired = 1;
	[self.captionView addGestureRecognizer:self.captionTapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(figureDatasourceDataChangedEvent:) name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prioritizedDownloadDone:) name:SOBPRIORITIZEDDOWNLOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_managedObjectContext = app.managedObjectContext;
	
	//Store defaults if not already available
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:@"ImageViewController.displayCaption"] == nil)
		[defaults setBool:NO forKey:@"ImageViewController.displayCaption"];
	if([defaults objectForKey:@"ImageViewController.viewMode"] == nil)
		[defaults setInteger:cViewTypeLabel forKey:@"ImageViewController.viewMode"];
	if([defaults objectForKey:@"ImageViewController.allStructures"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.allStructures"];
	if([defaults objectForKey:@"ImageViewController.displayArtery"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.displayArtery"];
	if([defaults objectForKey:@"ImageViewController.displayVein"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.displayVein"];
	if([defaults objectForKey:@"ImageViewController.displayNerve"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.displayNerve"];
	if([defaults objectForKey:@"ImageViewController.displayMuscle"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.displayMuscle"];
	if([defaults objectForKey:@"ImageViewController.displayOther"] == nil)
		[defaults setBool:YES forKey:@"ImageViewController.displayOther"];
	
	//Set default Values
	_viewLoaded = NO;
    if (IS_PHONE) {
        self.displayCaption = NO;
        self.captionLabelShadow.hidden = YES;
        [defaults setBool:NO forKey:@"ImageViewController.displayCaption"];
    }
	self.displayCaption = [defaults boolForKey:@"ImageViewController.displayCaption"];
	self.viewMode = [defaults integerForKey:@"ImageViewController.viewMode"];
	self.allStructures = [defaults boolForKey:@"ImageViewController.allStructures"];
	self.displayArtery = [defaults boolForKey:@"ImageViewController.displayArtery"];
	self.displayVein = [defaults boolForKey:@"ImageViewController.displayVein"];
	self.displayNerve = [defaults boolForKey:@"ImageViewController.displayNerve"];
	self.displayMuscle = [defaults boolForKey:@"ImageViewController.displayMuscle"];
	self.displayOther = [defaults boolForKey:@"ImageViewController.displayOther"];
	

    [self repetitionInitOverlayViews];
}

- (void)prioritizedDownloadDone:(id) sender {
    NSLog(@"PrioritizedDownloadDone.");
    [self performSelectorOnMainThread:@selector(reloadView) withObject:self waitUntilDone:NO];
//    [self performSelector:@selector(reloadView) withObject:self afterDelay:.1];
}

- (void)pressedLayerButton:(id) sender {
    ImageLayerViewController *ilvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageLayerView"];
    [ilvc setParentImageViewController:self];
//    [self presentModalViewController:ilvc animated:YES];
    if (IS_PHONE) {
        [self.navigationController pushViewController:ilvc animated:YES];
    } else {
        self.layerViewPopover = [[UIPopoverController alloc] initWithContentViewController:ilvc];
        self.layerViewPopover.delegate = self;
        UIBarButtonItem *btn = (UIBarButtonItem*) sender;
        [self.layerViewPopover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self labelDeselected];
}

- (void)viewDidAppear:(BOOL)animated {
	KWLogDebug(@"[%@] viewDidAppear", self.class);
    _viewHasAppeared = YES;

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	self.displayCaption = [defaults boolForKey:@"ImageViewController.displayCaption"];
//    [self disableCaptionInteraction];
    self.tapGestureRecognizer.enabled = YES;

	//[self.pagingScrollView updateOrientation];
	[self.pagingScrollView reloadPages];
	[self.pagingScrollView selectPageAtIndex:[self.datasource getCurrentSelectionGlobalIndex] animated:NO];
	
	_viewLoaded = YES;
    
    if (!self.trainingMode) {
        [[DatabaseController Current] trackView:@"ImageView"];
        self.tapGestureRecognizer.enabled = YES;
        if (![defaults boolForKey:@"ImageViewController.didShowNotesHint"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hint", nil) message:NSLocalizedString(@"Tap on a label to add a note.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
            [defaults setBool:YES forKey:@"ImageViewController.didShowNotesHint"];
            [defaults synchronize];
        }
    } else {
        [[DatabaseController Current] trackView:@"Training"];
        // if training mode
        if (IS_PHONE) {
            _trainingController.viewMode = cTrainingViewModeTraining;
            if ([self numberOfLabelsToGuess] < 1) {
                [self showPageResult];
            }
        }
    }
    [self updateCaptionVisibility];
    
    if (_trainingPopover) {
        [self presentTrainingPopover];
    }
}

- (void)applicationWillResignActive:(id)sender {
    [self pauseTrainingDuration];
}

- (void)applicationDidBecomeActive:(id)sender {
    [self resumeTrainingDuration];
}

- (void) updateCaptionVisibility {
    if (IS_PHONE && self.trainingMode) {
        captionView.hidden = YES;
        _captionLabelShadow.hidden = YES;
    } else if (self.viewMode == cViewTypeRepetitionTrainingPin) {
        captionView.hidden = YES;
        _captionLabelShadow.hidden = YES;
    } else {
        captionView.hidden = NO;
        _captionLabelShadow.hidden = NO;
    }
    if (IS_PHONE) {
        _captionLabelShadow.hidden = YES;
    }
}

- (void)pauseTrainingDuration {
    if (_currentTraining) {
        if (_currentTraining.laststart) {
            NSTimeInterval duration = -[_currentTraining.laststart timeIntervalSinceNow];
            DDLogDebug(@"Pausing training duration. User was active for %f second.", duration);
            duration += _currentTraining.duration ? _currentTraining.duration.doubleValue : 0;
            DDLogDebug(@"New total duration: %f seconds (%f minutes)", duration, duration / 60);
            _currentTraining.laststart = nil;
            _currentTraining.duration = @(duration);
            [_currentTraining.managedObjectContext save:nil];
        }
    }
}

- (void)resumeTrainingDuration {
    if (_currentTraining) {
        DDLogDebug(@"Resuming training duration.");
        _currentTraining.laststart = [[NSDate alloc] init];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self pauseTrainingDuration];

    if (_trainingPopover) {
        [_trainingPopover dismissPopoverAnimated:YES];
        _trainingPopover = nil;
    }
}

- (Training *)currentTraining {
    return _currentTraining;
}

- (FigureDatasource *)currentFigureDatasource {
    return _datasource;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"image view - didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"ImageViewController - dealloc");
    [self invalidate];
}

- (void)viewWillUnload {
    NSLog(@"ImageViewController - viewWillUnload");
}

- (void) invalidate {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBPRIORITIZEDDOWNLOAD object:nil];
}

- (void)viewDidUnload
{
	KWLogDebug(@"[%@] viewDidUnload", self.class);
    [self invalidate];
    
    KWLogDebug(@"Invalidated ImageViewController.");
	[self setLayerViewPopover:nil];

//	[self setCaptionView:nil];
//	[self setCaptionLabel:nil];
//	[self setCaptionWebView:nil];
//	[self setPanGestureRecognizer:nil];
//	[self setPagingScrollView:nil];
//	[self setTapGestureRecognizer:nil];
//	[self setCaptionClip:nil];
//	[self setDoubleTapGestureRecognizer:nil];
//	[self setCaptionTapGestureRecognizer:nil];
//    self.pagingScrollView.pagingDelegate = nil;
//	[self setPagingScrollView:nil];
    KWLogDebug(@"calling super viewDidUnload");
    [self setTrainingHeaderView:nil];
    [self setTrainingHeaderLabel:nil];
    [self setCaptionLabelShadow:nil];
	[super viewDidUnload];
    KWLogDebug(@"super unload.");
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	KWLogDebug(@"[%@] didRotateFromInterfaceOrientation", self.class);
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	self.displayCaption = [defaults boolForKey:@"ImageViewController.displayCaption"];
	
//    NAMapView *page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
//    if (page) {
//        [self calculatePageZoomSize:page];
//    }
	if(_slideUpView) {
		CGRect bounds = [[self view] bounds];
		if(_thumbViewShowing)
			_slideUpView.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds)-[_thumbScrollView frame].size.height, bounds.size.width, [_thumbScrollView frame].size.height);
		else
			_slideUpView.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, [_thumbScrollView frame].size.height);
	}
	if( _thumbScrollView) {
		[_thumbScrollView updateOrientation];
    }

    if (_trainingPopover) {
        [_trainingPopover dismissPopoverAnimated:NO];
        [self presentTrainingPopover];
    }
    
    [self performSelector:@selector(reloadView) withObject:self afterDelay:.1];

}

- (void) reloadView {
    NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
//    [page layoutSubviews];
//    [self calculatePageZoomSize:page];
//    [page setZoomScale:page.minimumZoomScale animated:YES];
    [self configureViewWithViewType:self.viewMode recallPosition:NO forIndex:[self.pagingScrollView indexOfSelectedPage] andPage:page loadAnnotations:YES reloadData:NO onDone:^{
        
        page.frame = [self.pagingScrollView frameForPageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
        [page setZoomScale:page.minimumZoomScale*1.01 animated:NO];
        [page setZoomScale:page.minimumZoomScale animated:NO];
        [UIView animateWithDuration:0.5 animations:^{
            page.alpha = 1;
        }];
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	KWLogDebug(@"[%@] willAnimateRotationToInterfaceOrientation", self.class);
	[pagingScrollView afterRotation];
//    [self reloadView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	KWLogDebug(@"[%@] willRotateToInterfaceOrientation", self.class);
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.pagingScrollView beforeRotation];

    NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
    [UIView animateWithDuration:0.5 animations:^{
        page.alpha = 0;
    }];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@""];
}

#pragma mark -


- (void)languageChanged:(NSNotification *)notification {
	_currentPage = [self.pagingScrollView indexOfSelectedPage];
//    if (self.isViewLoaded && self.view.window) {
//        [_datasource reloadData];
//    }
}

- (void)figureDatasourceDataChangedEvent:(NSNotification *)notification {
    NSLog(@"Figure datasource changed. reloading pages. %ld", [self.datasource getCurrentSelectionGlobalIndex]);
	[self.pagingScrollView reloadPages];
	
	//Workaround for Language Change
	if(_viewLoaded && _currentPage >= 0){
        _currentFigureIndex = -1;
        _isReloading = YES;
		[self.pagingScrollView selectPageAtIndex:_currentPage animated:NO];
        _isReloading = NO;
	} else {
        [self.pagingScrollView selectPageAtIndex:[self.datasource getCurrentSelectionGlobalIndex] animated:NO];
    }
}

- (void)setFigure:(FigureDatasource*)source
{
	self.datasource = source;
}

- (void)reloadFromDatasource {
    [self figureDatasourceDataChangedEvent:nil];
}

- (IBAction)handleCaptionPan:(id)sender {
    if (IS_PHONE) {
        return;
    }
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	CGPoint translation = [panGestureRecognizer translationInView:self.view];
	CGFloat y = self.view.bounds.size.height - cCaptionHideHeight - cCaptionSpacingBottom;
//	if((captionView.frame.origin.y + translation.y) < y) {
		y = captionView.frame.origin.y + translation.y;
		displayCaption = YES;
//	}
//	else {
//		displayCaption = NO;
//	}
	y = MAX(100, y);
	CGFloat height = self.view.bounds.size.height - y - cCaptionSpacingBottom;
    if (height < 80) {
        height = 80;
        y = self.view.bounds.size.height - height - cCaptionSpacingBottom;
    }
	[defaults setBool:displayCaption forKey:@"ImageViewController.displayCaption"];
	//[self.pagingScrollView setViewHeight:self.view.frame.size.height - height + cCaptionClipHeight];
//    panGestureRecognizer.view.frame = CGRectMake(panGestureRecognizer.view.frame.origin.x, y, panGestureRecognizer.view.frame.size.width, MIN(height,self.view.bounds.size.height-100));
    if (_captionViewHeightConstraint) {
        _captionViewHeightConstraint.constant = height;
    } else {
        captionView.frame = CGRectMake(captionView.frame.origin.x, y, captionView.frame.size.width, height);
    }
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
//    NSLog(@"caption - y: %f, height: %f, displayCaption: %d", y, height, displayCaption);
	
	UIGestureRecognizer *recognizer = sender;
	if(recognizer.state == UIGestureRecognizerStateEnded && height < 110)
		[self setDisplayCaption:NO];
}

- (void)captionTapAction:(id)sender {
    if (IS_PHONE) {
        if (_captionHtml) {
            [self performSegueWithIdentifier:@"showPhoneCaption" sender:self];
        }
        return;
    }
	[self setDisplayCaption:!self.displayCaption];
}

#pragma mark -
#pragma mark Storyboard Function

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"displayLayerSelector"]) {
		if(self.layerViewPopover)
			[self.layerViewPopover dismissPopoverAnimated:YES];
		self.layerViewPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
		self.layerViewPopover.delegate = self;
		
		[[segue destinationViewController] setParentImageViewController:self];
	} else if ([[segue identifier] isEqualToString:@"showPhoneCaption"]) {
        CaptionViewController *vc = (CaptionViewController *)segue.destinationViewController;
        vc.captionHtml = _captionHtml;
    }
}


#pragma mark -
#pragma mark Display Property Setters

- (void)setDisplayCaption:(BOOL)display {
    [[DatabaseController Current] trackEventWithCategory:@"caption" withAction:display ? @"showing caption" : @"hiding caption" withLabel:@"setDisplayCaption" withValue:0];
	KWLogDebug(@"[%@] setDisplayCaption %d", self.class, display);
	//KWLogDebug(@"[%@] Display Caption was changed", self.class);
	displayCaption = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayCaption"];
	
	if(_viewLoaded) {
		if(displayCaption) {
            [self.view layoutIfNeeded];
			[UIView animateWithDuration:0.5
					animations:^{
						//[self.pagingScrollView setViewHeight:self.view.frame.size.height - cCaptionDisplayHeight + cCaptionClipHeight];
                        if (_captionViewHeightConstraint) {
                            _captionViewHeightConstraint.constant = cCaptionDisplayHeight;
                            [self.view layoutIfNeeded];
                        } else {
                            self.captionView.frame = CGRectMake(self.captionView.frame.origin.x, self.view.bounds.size.height - cCaptionDisplayHeight - cCaptionSpacingBottom, self.captionView.frame.size.width, cCaptionDisplayHeight);
                        }
			}];
		} else {
            [self.view layoutIfNeeded];
			[UIView animateWithDuration:0.5
					 animations:^{
						 KWLogDebug(@"Height: %f", self.view.bounds.size.height);
						 //[self.pagingScrollView setViewHeight:self.view.frame.size.height - cCaptionHideHeight + cCaptionClipHeight];
                         if (_captionViewHeightConstraint) {
                             _captionViewHeightConstraint.constant = cCaptionHideHeight;
                             [self.view layoutIfNeeded];
                         } else {
                             self.captionView.frame = CGRectMake(self.captionView.frame.origin.x, self.view.bounds.size.height-cCaptionHideHeight - cCaptionSpacingBottom, self.captionView.frame.size.width, cCaptionHideHeight);
                         }
					 }];
		}
	}
	else {
		if(displayCaption) {
            if (_captionViewHeightConstraint) {
                _captionViewHeightConstraint.constant = cCaptionDisplayHeight;
            } else {
                self.captionView.frame = CGRectMake(self.captionView.frame.origin.x, self.view.frame.size.height - cCaptionDisplayHeight - cCaptionSpacingBottom, self.captionView.frame.size.width, cCaptionDisplayHeight);
            }
		}
		else {
            if (_captionViewHeightConstraint) {
                _captionViewHeightConstraint.constant = cCaptionHideHeight;
            } else {
                self.captionView.frame = CGRectMake(self.captionView.frame.origin.x, self.view.frame.size.height-cCaptionHideHeight - cCaptionSpacingBottom, self.captionView.frame.size.width, cCaptionHideHeight);
            }
		}
	}
}

- (BOOL)trainingMode {
    return (_trainingMode || _trainingNeedStart);
}
- (BOOL)trainingEnded {
    return _trainingController.viewMode == cTrainingViewModeEndResult;
}

- (void)setViewMode:(int)vm {
	viewMode = vm;
    if (viewMode != cViewTypeRepetitionTrainingPin) {
        // no need to persist repetition training view mode.
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:vm forKey:@"ImageViewController.viewMode"];
    }
	if(_viewLoaded)
		[self configureViewWithViewType:vm recallPosition:YES];
}

- (void)setAllStructures:(BOOL)structures {
	allStructures = structures;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:structures forKey:@"ImageViewController.allStructures"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

-(void)setDisplayArtery:(BOOL)display {
	displayArtery = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayArtery"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

- (void)setDisplayVein:(BOOL)display {
	displayVein = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayVein"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

- (void)setDisplayNerve:(BOOL)display {
	displayNerve = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayNerve"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

-(void)setDisplayMuscle:(BOOL)display {
	displayMuscle = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayMuscle"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

- (void)setDisplayOther:(BOOL)display {
	displayOther = display;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:display forKey:@"ImageViewController.displayOther"];
	//Redraw View
	if(_viewLoaded)
		[self configureViewWithViewType:self.viewMode recallPosition:YES];
}

#pragma mark -
#pragma mark Thumb View handling methods

- (IBAction)singleTapAction:(id)sender {
	//KWLogDebug(@"[%@] singleTapAction", self.class);
	if([self hideCallout] && !_notesView){
		[self toggleThumbView];
	}
}

-(void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
	//KWLogDebug(@"[%@] thumbImageViewWasTapped", self.class);
	[self.pagingScrollView selectPageAtIndex:tiv.imageIndex animated:NO];
    //[self toggleThumbView];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	// test if our control subview is on-screen
    if ([touch.view isKindOfClass:[NAPinAnnotationView class]]) {
		return NO; // ignore the touch
    }
	else if([touch.view isKindOfClass:[NALabelView class]]) {
		NALabelView* labelView = (NALabelView*)touch.view;
		return ![labelView checkTouch:touch];
	}
    return YES; // handle the touch
}

- (void)hideThumbView {
    if (_thumbViewShowing) {
        [self toggleThumbView];
    }
}

- (void)toggleThumbView {
	//KWLogDebug(@"[%@] toggleThumbView", self.class);
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [_slideUpView frame];
    if (_thumbViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
		if(_thumbScrollView)
			[_thumbScrollView setCurrentImage:[self.pagingScrollView indexOfSelectedPage] andCenter:YES];
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_slideUpView setFrame:frame];
	if(!_thumbViewShowing){
		if([self displayCaption]){
			//[self.pagingScrollView setViewHeight:self.view.frame.size.height - frame.size.height];
			self.captionView.frame = CGRectMake(self.captionView.frame.origin.x, self.view.frame.size.height - frame.size.height - cCaptionClipHeight, self.captionView.frame.size.width, frame.size.height + cCaptionClipHeight - cCaptionSpacingBottom);
		}
	}
    [UIView commitAnimations];
    
    _thumbViewShowing = !_thumbViewShowing;
	//[self.navigationController setNavigationBarHidden:!thumbViewShowing animated:YES];
}

- (NSArray *)imageNames {
    
	NSMutableArray *imageNames = [[NSMutableArray alloc] init];
    int count = [self.datasource figureAvailableCount];
	for (int i = 0; i< count; i++) {
		[imageNames addObject: [[self datasource] figureAtGlobalIndex:i].filename ];
	}
	
    if (!imageNames) {
        NSLog(@"Failed to read image names.");
    }
    
    return imageNames;
}

- (void)createSlideUpViewIfNecessary {
    //KWLogDebug(@"[%@] createSlideUpViewIfNecessary", self.class);
    if (!_slideUpView) {
        
        [self createThumbScrollViewIfNecessary];
		
        CGRect bounds = [[self view] bounds];
        float thumbHeight = [_thumbScrollView frame].size.height;
        
        // create container view that will hold scroll view and label
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, thumbHeight);
        _slideUpView = [[SlideUpView alloc] initWithFrame:frame];
        _slideUpView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [[self view] addSubview:_slideUpView];
        
        // add subviews to container view
        [_slideUpView addSubview:_thumbScrollView];
		[_thumbScrollView setCurrentImage:[self.pagingScrollView indexOfSelectedPage] andCenter:YES];
    }
}

- (void)createThumbScrollViewIfNecessary {
    //KWLogDebug(@"[%@] createThumbScrollViewIfNecessary", self.class);
    if (!_thumbScrollView) {
        
        NSArray* imageNames = [self imageNames];
        _thumbScrollView = [[ThumbScrollView alloc] initWithImageNames:imageNames onTarget:self];
		//thumbScrollView.delegate = self;
    }
}

#pragma mark -
#pragma mark Paging Scroll View Methods


- (void)configureViewWithViewType:(NSInteger)viewType recallPosition:(bool)recall {
    [self configureViewWithViewType:viewType recallPosition:recall onDone:nil];
}
- (void)configureViewWithViewType:(NSInteger)viewType recallPosition:(bool)recall onDone:(void (^)())doneCallback {
	//KWLogDebug(@"[%@] configureViewWithViewType:(NSInteger)viewType recallPosition:(bool)recall", self.class);
	NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
	[self configureViewWithViewType:viewType recallPosition:recall forIndex:[self.pagingScrollView indexOfSelectedPage] andPage:page loadAnnotations:YES reloadData:YES onDone:doneCallback];
}

- (void)configureViewWithViewType:(NSInteger)viewType recallPosition:(bool)recall forIndex:(NSUInteger)index andPage:(NAMapView*)page loadAnnotations:(BOOL)loadAnnotations reloadData:(BOOL)reloadData onDone:(void (^)())doneCallback
{
	//KWLogDebug(@"[%@] configureViewWithViewType:(NSInteger)viewType recallPosition:(bool)recall forIndex:(NSUInteger)index andPage:(NAMapView*)page loadAnnotations:(BOOL)load", self.class);
	FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:index];
    if (!currentFigure.interactive) {
        viewType = cViewTypeLabel;
    }
	
	//Load Data for index
	FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
	[queue inDatabase:^(FMDatabase *db) {
		
		FMResultSet *figureres = [db executeQuery:[NSString stringWithFormat:@"SELECT id,filename,realsizezoom,shortlabel_%@,longlabel_%@,legend_%@,sortorder FROM figure WHERE id = %ld", [[DatabaseController Current] langcolname], [[DatabaseController Current] langcolname], [[DatabaseController Current] langcolname], currentFigure.idval]];
		if([figureres next])
			_currentDBFigure = [figureres resultDictionary];
		[figureres close];
		
	}];
	
	//NAMapView* page = nil; //[self pageAtIndex:index];
	
    // Update the user interface for the detail item.
	CGFloat oldZoom = page.zoomScale;
	CGPoint oldCenter = page.center;
	
	[page setZoomScale:1.0 animated:NO];
	[page removeAllAnnotationsOrLabels];
	UIImage *image = nil;
    
    NSString *dbPath = [DatabaseController Current].dataPath;
	
	NSLog(@"Loading Image with FILENAME: %@", currentFigure.filename);
    if (!currentFigure.available) {
        FigureProxy *figureProxy = [_fullVersionController loadFigureProxyForFigureId:[NSNumber numberWithLong:currentFigure.idval]];
        if (figureProxy && ![figureProxy.downloaded boolValue]) {
            NSLog(@" displaying loaded.");
            [page displayLoading];
            loadAnnotations = NO;
            viewType = 99;
            [_fullVersionController prioritizeFigure:figureProxy];
        }
    }
	
	switch (viewType) {
		case cViewTypePin:
		case cViewTypeImageOnly:
		case cViewTypeTrainingPin:
        case cViewTypeTrainingLabel:
        case cViewTypeRepetitionTrainingPin:
		{
            if (currentFigure.available) {
                image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:currentFigure.filename ofType:@"jpg" inDirectory:[NSString stringWithFormat:@"%@/figures/bare/",dbPath]]];
            } else {
                NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg",_fullVersionController.figureBarePath, currentFigure.filename];
                NSLog(@"Loading figure from %@", imagePath);
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            if (image) {
                [page displayMap:image inTraining:(viewType == cViewTypeTrainingLabel || viewType == cViewTypeTrainingPin || viewType == cViewTypeRepetitionTrainingPin)];
            }
//            [page displayLoading];
		}
			break;
		case cViewTypeLabel:
		{
            if (currentFigure.available) {
                image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:currentFigure.filename ofType:@"jpg" inDirectory:[NSString stringWithFormat:@"%@/figures/lines/",dbPath]]];
            } else {
                NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg",_fullVersionController.figureLinesPath, currentFigure.filename];
                NSLog(@"Loading figure from %@", imagePath);
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
			[page displayMap:image inTraining:NO];
//            [page displayLoading];
		}
			break;
		default:
			NSLog(@"");
			break;
	}
	
	//[self.label setText:[data objectForKey:@"bare"]];
	
	//CGFloat zoom = self.mapview.frame.size.height / image.size.height;
	NSLog(@"RealSizeZoom Value: %f", [[_currentDBFigure objectForKey:@"realsizezoom"] floatValue]);
	/*
	page.minimumZoomScale = [[_currentDBFigure objectForKey:@"realsizezoom"] floatValue] * cMinZoomFactor;
	page.maximumZoomScale = [[_currentDBFigure objectForKey:@"realsizezoom"] floatValue] * cMaxZoomFactor;
	*/
    
    [self calculatePageZoomSize:page];
	page.maximumZoomScale = 2.2;
	
	if(recall){
		[page setZoomScale:oldZoom];
		[page setCenter:oldCenter];
	}
	else {
//        [page setZoomScale:page.minimumZoomScale animated:NO];

        
//         FOR NOW: always use minimum zoom level, previously only in training mode for ipad the "realsizezoom" was used
//         and it caused the images to jump right after beeing loaded.
        
        //KWLogDebug(@"Zoom Value: %f", [[_currentDBFigure objectForKey:@"realsizezoom"] floatValue]);
        if (!(self.trainingMode) || IS_PHONE) {
            [page setZoomScale:page.minimumZoomScale animated:NO];
//            [page setZoomScale:[[_currentDBFigure objectForKey:@"realsizezoom"] floatValue] * 0.5];
        } else {
            [page setZoomScale:[[_currentDBFigure objectForKey:@"realsizezoom"] floatValue] animated:NO];
        }
		[page centerMap];
	}
	
	if(loadAnnotations) {
		[self loadAnnotationsForPage:page withViewType:viewType atIndex:index reloadData:reloadData onDone:(void (^)())doneCallback];
	} else {
        if (doneCallback) {
            doneCallback();
        }
    }
}

- (void) calculatePageZoomSize:(NAMapView*)page {
//    CGFloat imagesize = MIN(page.customMap.frame.size.width, page.customMap.frame.size.height);
    //CGFloat zoomh = (page.frame.size.height-2*cCaptionHideHeight) / page.customMap.frame.size.height;
    CGFloat zoomh = (page.frame.size.height-cCaptionHideHeight) / page.customMap.frame.size.height;
    CGFloat zoomw = page.frame.size.width / page.customMap.frame.size.width;
//    NSLog(@"======= zoomh vs. zoomw: %f vs. %f (width / height: %f / %f ---- size: %f)", zoomh, zoomw, image.size.width, image.size.height, imagesize);
    CGFloat fitscale = MIN(zoomh, zoomw);
    // add an extra 5% to account for longer german text strings
    fitscale *= 0.96;
    
	page.minimumZoomScale = fitscale;

}

- (void)loadAnnotationsForCurrentPage {
	[self loadAnnotationsForPageIndex:[[self pagingScrollView] indexOfSelectedPage]];
}

- (void)loadAnnotationsForPageIndex:(NSInteger)index {
	[self loadAnnotationsForPage:[[self pagingScrollView] pageAtIndex:index] withViewType:self.viewMode atIndex:index reloadData:!_trainingMode onDone:nil];}

- (void)loadAnnotationsForPage:(UIView*)page withViewType:(NSInteger)viewType atIndex:(NSInteger)index reloadData:(BOOL)reload onDone:(void (^)())doneCallback {
	//KWLogDebug(@"[%@] loadAnnotationsForPage:(UIView*)page withViewType:(NSInteger)viewType atIndex:(NSInteger)index reloadData:(BOOL)reload", self.class);
	FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:index];
    if (!currentFigure.interactive) {
        viewType = cViewTypeLabel;
    }
	if(viewType != cViewTypeImageOnly){
        NSLog(@"loadAnnotationsForPage -- reload: %d", reload);
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
        if (!reload) {
            NSLog(@"Not reloading??");
        }
        if (!page) {
            DDLogError(@"Error while loading Annotations for page - page is nil!");
        }
        NAMapView *pageMapView = (NAMapView *)page;
		
        [self bk_performBlock:^(id obj) {
            if (index != [[self pagingScrollView] indexOfSelectedPage]) {
                DDLogWarn(@"Selected page changed since event, do not (reload) annotations.");
                return;
            }
            [self loadAnnotationsForViewType:viewType forIndex:index andPage:pageMapView reloadData:reload];
            if (doneCallback) {
                doneCallback();
            }
        } afterDelay:0];
	}
}

/**
 * will load labels and spots for the given figure and call doneCallback on the same thread.
 */
- (void)loadLabelsAndSpotsSyncForFigure:(nonnull FigureInfo *)figure forDatabase:(FMDatabase *)db doneCallback:(void(^)(NSMutableArray *labels, NSMutableDictionary *spots))doneCallback {
    
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    NSMutableDictionary *spots = [[NSMutableDictionary alloc] init];
    NSLog(@"Loading labels for figure_id %ld", figure.idval);
    
    FMResultSet *labres = [db executeQuery:[NSString stringWithFormat:@"SELECT id,x,y,align,text_%@,text_%@ text,relevant,structure,spot_count FROM label WHERE figure_id = %ld ORDER BY relevant DESC", [[DatabaseController Current] langcolname], [[DatabaseController Current] langcolname], figure.idval]];
    while ([labres next]) {
        NSMutableDictionary *labelDic = (NSMutableDictionary*)[labres resultDictionary];
        [labelDic setValue:cLabelStateNone forKey:@"state"];
        [labels addObject:labelDic];
    }
    [labres close];
    
    FMResultSet *spotres = [db executeQuery:[NSString stringWithFormat:@"SELECT label_id,x,y FROM spot WHERE figure_id = %ld ORDER BY y ASC", figure.idval]];
    while ([spotres next]) {
        if([spots.allKeys containsObject:[spotres objectForColumnName:@"label_id"]]){
            NSMutableArray* arr = [spots objectForKey:[spotres objectForColumnName:@"label_id"]];
            [arr addObject:[spotres resultDictionary]];
        } else {
            NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:[spotres resultDictionary], nil];
            [spots setObject:arr forKey:[spotres objectForColumnName:@"label_id"]];
        }
    }
    [spotres close];
    
    doneCallback(labels, spots);
    
}

- (void)loadLabelsAndSpotsForFigure:(nonnull FigureInfo *)figure doneCallback:(void(^)(NSMutableArray *labels, NSMutableDictionary *spots))doneCallback {


    //Load Data for index
    FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        
        [self loadLabelsAndSpotsSyncForFigure:figure forDatabase:db doneCallback:doneCallback];
    }];

}


- (void)loadAnnotationsForViewType:(NSInteger)viewType forIndex:(NSUInteger)index andPage:(NAMapView*)page reloadData:(BOOL)reload {
	//KWLogDebug(@"[%@] loadAnnotationsForViewType:(NSInteger)viewType forIndex:(NSUInteger)index andPage:(NAMapView*)page reloadData:(BOOL)reload", self.class);
	FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:index];
    if (!currentFigure.interactive) {
        viewType = cViewTypeLabel;
    }
	
	[page removeAllAnnotationsOrLabels];
	
    DDLogVerbose(@"LOADING LABELS? %d", reload);
	if (reload) {
        [self loadLabelsAndSpotsForFigure:currentFigure doneCallback:^(NSMutableArray *labels, NSMutableDictionary *spots) {
            DDLogDebug(@"Loaded labels for figure %ld", currentFigure.idval);
            _labels = labels;
            _spots = spots;
        }];
	}
	
	//NAMapView* page = nil; //[self pageAtIndex:index];
	
    // Update the user interface for the detail item.
	
	switch (viewType) {
		case cViewTypePin:
		{
			
			for (NSDictionary* label in _labels) {
				if([[label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]] isEqual:[NSNull null]])
					continue;
				
				if(self.allStructures || (!self.allStructures && [[label objectForKey:@"relevant"] boolValue])) {
					if( ([[label objectForKey:@"structure"] isEqualToString:@"a"] && self.displayArtery) ||
					   ([[label objectForKey:@"structure"] isEqualToString:@"v"] && self.displayVein) ||
					   ([[label objectForKey:@"structure"] isEqualToString:@"n"] && self.displayNerve) ||
					   ([[label objectForKey:@"structure"] isEqualToString:@"m"] && self.displayMuscle) ||
					   ([[label objectForKey:@"structure"] isEqualToString:@"o"] && self.displayOther)) {
						
						for (NSDictionary* spot in [_spots objectForKey:[label objectForKey:@"id"]]) {
							NAAnnotation* annotation = [NAAnnotation annotationWithPoint:CGPointMake([[spot objectForKey:@"x"] floatValue], [[spot objectForKey:@"y"] floatValue]) andColor:cPinAnnotationRed];
							annotation.title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
							[page addAnnotation:annotation animated:NO];
						}
					}
				}
			}
		}
			break;
		case cViewTypeLabel:
		{
			NSMutableArray *labelArray = [[NSMutableArray alloc] init];
			for (NSDictionary* l in _labels) {
				NALabel *label = [[NALabel alloc] init];
				label.targetPoint = CGPointMake([[l objectForKey:@"x"] floatValue], [[l objectForKey:@"y"] floatValue]);
				label.title = [l objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
				label.labelPoint = CGPointMake([[l objectForKey:@"x"] floatValue], [[l objectForKey:@"y"] floatValue]);
				label.align = [l objectForKey:@"align"];
				if((!self.allStructures && ![[l objectForKey:@"relevant"] boolValue]) ||
				   ([[l objectForKey:@"structure"] isEqualToString:@"a"] && !self.displayArtery) ||
				   ([[l objectForKey:@"structure"] isEqualToString:@"v"] && !self.displayVein) ||
				   ([[l objectForKey:@"structure"] isEqualToString:@"n"] && !self.displayNerve) ||
				   ([[l objectForKey:@"structure"] isEqualToString:@"m"] && !self.displayMuscle) ||
				   ([[l objectForKey:@"structure"] isEqualToString:@"o"] && !self.displayOther)) {
					label.disabled = YES;
				}
				label.relevant = [[l objectForKey:@"relevant"] boolValue];
				label.labelid = [[l objectForKey:@"id"] integerValue];
				
				
				//Load note for Label
				NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
				fetchRequest.predicate = [NSPredicate predicateWithFormat:@"label_id == %@", [l objectForKey:@"id"]];
				NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"label_id" ascending:YES selector:@selector(caseInsensitiveCompare:)];
				NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
				[fetchRequest setSortDescriptors:sortDescriptors];
				_resultsController = [[NSFetchedResultsController alloc]
									  initWithFetchRequest:fetchRequest
									  managedObjectContext:_managedObjectContext
									  sectionNameKeyPath:nil
									  cacheName:nil];
				
				NSError *error = nil;
				[_resultsController performFetch:&error];
				
				if(_resultsController.fetchedObjects.count > 0){
					Note *note = [_resultsController.fetchedObjects objectAtIndex:0];
					label.managedNote = note;
					label.hasNote = YES;
					NSString *color = note.color;
					if([color isEqualToString:@"red"])
						label.noteColor = cNoteColorRed;
					else if([color isEqualToString:@"green"])
						label.noteColor = cNoteColorGreen;
					else if([color isEqualToString:@"blue"])
						label.noteColor = cNoteColorBlue;
					else if([color isEqualToString:@"pink"])
						label.noteColor = cNoteColorPink;
					else if([color isEqualToString:@"violet"])
						label.noteColor = cNoteColorViolet;
				}
				
				[labelArray addObject:label];
				//[page addLabel:label withDelegate:self];
			}
			[page removeAllAnnotationsOrLabels];
			[page addLabels:labelArray withDelegate:self];
		}
			break;
		case cViewTypeTrainingLabel:
		{
			if(_trainingController.viewMode == cTrainingViewModeTraining){
				NSArray* spotsForCurrentLabel = [_spots objectForKey:[_currentTrainingLabel objectForKey:@"id"]];
				NSUInteger index = 0;
				if(spotsForCurrentLabel.count > 1){
					index = arc4random() % [spotsForCurrentLabel count];
				}
				NSDictionary* spot = [spotsForCurrentLabel objectAtIndex:index];
				
				NAAnnotation* annotation = [NAAnnotation annotationWithPoint:CGPointMake([[spot objectForKey:@"x"] floatValue], [[spot objectForKey:@"y"] floatValue]) andColor:cPinAnnotationBlue];
				annotation.title = [_currentTrainingLabel objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
				annotation.labelid = [[_currentTrainingLabel objectForKey:@"id"] integerValue];
				annotation.spotid = [[spot objectForKey:@"id"] integerValue];
				[page addAnnotation:annotation withDelegate:self];
			}
			else {
				for (NSDictionary* label in _labels) {
					if([[label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]] isEqual:[NSNull null]])
						continue;
					
					NSString *color = nil;
					switch ([[label objectForKey:@"trainingState"] integerValue]) {
						case cLabelStateNone:
							color = cPinAnnotationBlue;
							break;
						case cLabelStateSolvedWrong:
						case cLabelStateSkipped:
							color = cPinAnnotationLightRed;
							break;
						case cLabelStateSolvedCorrect:
							color = cPinAnnotationLightGreen;
							break;
						case cLabelStateResolve:
							color = cPinAnnotationGreen;
							break;
						default:
							break;
					}
					
					for (NSDictionary* spot in [_spots objectForKey:[label objectForKey:@"id"]]) {
						NAAnnotation* annotation = [NAAnnotation annotationWithPoint:CGPointMake([[spot objectForKey:@"x"] floatValue], [[spot objectForKey:@"y"] floatValue]) andColor:color];
						annotation.title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
						annotation.labelid = [[label objectForKey:@"id"] integerValue];
						annotation.spotid = [[spot objectForKey:@"id"] integerValue];
						[page addAnnotation:annotation withDelegate:self];
					}
				}
			}
		}
			break;
		case cViewTypeTrainingPin:
		{
			
			for (NSDictionary* label in _labels) {
				if([[label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]] isEqual:[NSNull null]])
					continue;
				
				NSString *color = nil;
				switch ([[label objectForKey:@"trainingState"] integerValue]) {
					case cLabelStateNone:
						color = cPinAnnotationBlue;
						break;
					case cLabelStateSolvedWrong:
					case cLabelStateSkipped:
						color = cPinAnnotationLightRed;
						break;
					case cLabelStateSolvedCorrect:
						color = cPinAnnotationLightGreen;
						break;
					case cLabelStateResolve:
						color = cPinAnnotationGreen;
						break;
					default:
						break;
				}
				
				for (NSDictionary* spot in [_spots objectForKey:[label objectForKey:@"id"]]) {
					NAAnnotation* annotation = [NAAnnotation annotationWithPoint:CGPointMake([[spot objectForKey:@"x"] floatValue], [[spot objectForKey:@"y"] floatValue]) andColor:color];
					annotation.title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
					annotation.labelid = [[label objectForKey:@"id"] integerValue];
					annotation.spotid = [[spot objectForKey:@"id"] integerValue];
					[page addAnnotation:annotation withDelegate:self];
				}
			}
		}
			break;
        case cViewTypeRepetitionTrainingPin: {
            DDLogVerbose(@"Drawing spots for label %@ (figure %@)", _currentQuestionLabel, _currentQuestionLabel.figure.figure_id);
            NSNumber *figureLabelId = _currentQuestionLabel.figure_label_id;
            NSDictionary *label = [_labels bk_match:^BOOL(id obj) {
                return [figureLabelId isEqualToNumber:obj[@"id"]];
            }];
            if (label == nil) {
                DDLogError(@"Unable to find label with id %@ - panic! - current figure: %@ - current index: %d", figureLabelId, _currentFigure.figure_id, _currentFigureIndex);
                return;
            }
            NSArray *spots = _spots[figureLabelId];
            DDLogVerbose(@"label with id %@ found: %@ - spots: %ld", figureLabelId, label[@"text"], (unsigned long)spots.count);
            NSString *color = color = cPinAnnotationBlue;
            for (NSDictionary *spot in spots) {
                NAAnnotation* annotation = [NAAnnotation annotationWithPoint:CGPointMake([[spot objectForKey:@"x"] floatValue], [[spot objectForKey:@"y"] floatValue]) andColor:color];
                annotation.title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
                annotation.labelid = [[label objectForKey:@"id"] integerValue];
                annotation.spotid = [[spot objectForKey:@"id"] integerValue];
                [page addAnnotation:annotation withDelegate:self];
            }
            break;
        }
		default:
			NSLog(@"");
			break;
	}
    page.loadedFigureId = index;
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
	//KWLogDebug(@"[%@] scrollViewDidScroll", self.class);
	[pagingScrollView scrollViewDidScroll];
}

- (NSInteger)numberOfPagesInPagingScrollView:(MHPagingScrollView *)pagingScrollView {
	return [self.datasource figureAvailableCount];
}

- (UIView *)pagingScrollView:(MHPagingScrollView *)myPagingScrollView pageForIndex:(NSInteger)index {
	//KWLogDebug(@"[%@] pagingScrollView:(MHPagingScrollView *)myPagingScrollView pageForIndex:(NSInteger)index", self.class);
	NAMapView* page = (NAMapView *)[myPagingScrollView dequeueReusablePage];
	if(page == nil)
		page = [[NAMapView alloc] initWithFrame:[myPagingScrollView frameForPageAtIndex:index]];
	
	page.index = index;
	
	//TODO: Check if in training mode
	[self configureViewWithViewType:self.viewMode recallPosition:_isReloading forIndex:index andPage:page loadAnnotations:NO reloadData:NO onDone:nil];
	
	return page;
}

- (BOOL)hideCallout {
	NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
	return [page hideCallOut];
}

- (void)currentPageChanged:(NSInteger)index {
	KWLogDebug(@"[%@] currentPageChanged - Index: %ld", self.class, (long)index);
    if (!_trainingNeedStart) {
        DDLogVerbose(@"no training starting.");
    }
    if (_currentFigureIndex == index) {
        NAMapView *page = (NAMapView *)[[self pagingScrollView] pageAtIndex:index];
        if (page.loadedFigureId != 0) {
            KWLogDebug(@"currentPageChanged - index did not change.");
            return;
        }
    }
    _currentFigureIndex = index;
    [((SOBNavigationViewController*)self.navigationController) updateNavigationButtonItems:self];
	if(_thumbScrollView)
		[_thumbScrollView setCurrentImage:index andCenter:NO];
	
	FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
    
    FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:index];
    [self.datasource setCurrentSelection:currentFigure];
    
    
	[queue inDatabase:^(FMDatabase *db) {
		
		FMResultSet *figureres = [db executeQuery:[NSString stringWithFormat:@"SELECT id,filename,realsizezoom,shortlabel_%@,longlabel_%@,legend_%@,shortlabel_enen ga_shortlabel_enen FROM figure WHERE id = %ld", [[DatabaseController Current] langcolname], [[DatabaseController Current] langcolname], [[DatabaseController Current] langcolname], currentFigure.idval]];
        _captionHtml = nil;
		if([figureres next]) {
			NSDictionary* loadedFigure = [figureres resultDictionary];

            NSString *ga_shortlabel_enen = [loadedFigure objectForKey:@"ga_shortlabel_enen"];
            if (!self.trainingMode) {
                [[DatabaseController Current] trackView:[NSString stringWithFormat:@"FigureView/%@", ga_shortlabel_enen]];
            } else {
                [[DatabaseController Current] trackView:[NSString stringWithFormat:@"Training/%@", ga_shortlabel_enen]];
            }
			
			self.captionLabel.text = [NSString stringWithFormat:@"%@ %@",
									  [loadedFigure objectForKey:[NSString stringWithFormat:@"shortlabel_%@", [[DatabaseController Current] langcolname]]],
									  [loadedFigure objectForKey:[NSString stringWithFormat:@"longlabel_%@", [[DatabaseController Current] langcolname]]]];
			
            _captionHtml = [loadedFigure objectForKey:[NSString stringWithFormat:@"legend_%@", [[DatabaseController Current] langcolname]]];
			[self.captionWebView loadHTMLString:_captionHtml baseURL:nil];

		} else {
            
        }
			
		[figureres close];
		
		[self loadAnnotationsForPageIndex:index];
	}];
    if (_trainingNeedStart) {
        UIBarButtonItem *trainingButton = ((SOBNavigationViewController *)self.navigationController).resumeTrainingItem;
        [self startTraining:trainingButton createOption:_trainingCreateNew];
    }
}

- (void)doubleTapAction:(id)sender {
	//UITapGestureRecognizer *gesture = sender;
	NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
	if(page.zoomScale > [[_currentDBFigure objectForKey:@"realsizezoom"] floatValue])
		[page setZoomScale:[[_currentDBFigure objectForKey:@"realsizezoom"] floatValue] animated:cImageViewDoubleTapAnimation];
	else {
		[page setZoomScale:cImageViewDoubleTapZoomScale animated:cImageViewDoubleTapAnimation];
		//[page centreOnPoint:[gesture locationInView:page.customMap]  animated:cImageViewDoubleTapAnimation];
	}
    
    // for now simply hide the callout.
    [page hideCallOut];
}

#pragma mark -
#pragma mark printing

- (void) startPrinting:(id)button {
    NSLog(@"starting printing..");
	[self setViewMode:cViewTypeLabel];
	
    FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:[self.pagingScrollView indexOfSelectedPage]];
    [[DatabaseController Current] trackEventWithCategory:@"Printing" withAction:@"clicked" withLabel:[NSString stringWithFormat:@"Clicked Printing:%@", currentFigure.filename] withValue:nil];
	if ([UIPrintInteractionController isPrintingAvailable])
    {
		UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
		pic.delegate = self;
		
		UIPrintInfo *printInfo = [UIPrintInfo printInfo];
		printInfo.outputType = UIPrintInfoOutputGeneral;
		printInfo.jobName = self.captionLabel.text;
		pic.printInfo = printInfo;
		
		NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
		NAPrintRenderer *renderer = [[NAPrintRenderer alloc] init];
		[renderer addPrintFormatter:[page viewPrintFormatter] startingAtPageAtIndex:0];
		//renderer.printFormatters = [[NSArray alloc] initWithObjects:[page viewPrintFormatter], nil];
		pic.printPageRenderer = renderer;
		
		//UIViewPrintFormatter *formatter = [page viewPrintFormatter];
		//pic.printFormatter = formatter;
		pic.showsPageRange = YES;
		
		void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (completed) {
                [[DatabaseController Current] trackEventWithCategory:@"Printing" withAction:@"completed" withLabel:@"Printig completed successfully" withValue:nil];
            } else {
                if (error) {
                    [[DatabaseController Current] trackEventWithCategory:@"Printing" withAction:@"error" withLabel:@"Error while printing" withValue:nil];
                    NSLog(@"Druck konnte aufgrund eines Fehlers nicht abgeschlossen werden: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error during print", nil) message:NSLocalizedString(@"Could not finish print because of an error.", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    [[DatabaseController Current] trackEventWithCategory:@"Printing" withAction:@"cancel" withLabel:@"Printing cancelled" withValue:nil];
                }
            }
		};
					  
		[pic presentFromBarButtonItem:button animated:YES completionHandler:completionHandler];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No printer available", nil) message:NSLocalizedString(@"Currently there are no printers available", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

#pragma mark -
#pragma mark Webview Events - Hyperlink handling

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//sobotta:figure/filename/chp001_001
	KWLogDebug(@"%@", request.URL.absoluteString);
	if([request.URL.absoluteString hasPrefix:@"sobotta"]){
		NSString *imagename = [request.URL.absoluteString lastPathComponent];
		//TODO: Forward information to navigationcontroller
        FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
        // find figure for the given id and the correct chapter id
        [queue inDatabase:^(FMDatabase *db) {
            NSString *query = [NSString stringWithFormat:@"select f.id,o.level1_id from figure f inner join outline o on o.chapter_id = f.chapter_id where f.filename = ?"];
            FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[imagename]];
            if ([rs next]) {
                int figureId = [rs intForColumnIndex:0];
                int chapterId = [rs intForColumnIndex:1];
                [self.datasource loadForChapterId:chapterId];
                _currentPage = -1;
                [self.datasource setCurrentSelectionFigureId:figureId];
            } else {
                NSLog(@"Error while looking for figure with filename %@", imagename);
            }
        }];
//		[self.datasource loadForChapterId:0];
//		[self.datasource setCurrentSelection:nil];
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark Training

- (void) setupTrainingController {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    _trainingController = [sb instantiateViewControllerWithIdentifier:@"TrainingViewController"];
    _trainingController.delegate = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _trainingPopover = [[UIPopoverController alloc] initWithContentViewController:_trainingController];
        _trainingPopover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 50, 10);
        _trainingController.parentPopoverController = _trainingPopover;
        [_trainingPopover setPassthroughViews:[NSArray arrayWithObjects:self.view, self.navigationController.view, nil]];
        [self presentTrainingPopover];
    } else {
        self.trainingHeaderView.hidden = NO;
    }
    [_trainingController updateTableHeight];
}

- (void) startTraining:(id)buttonUnused createOption:(enum CreateTrainingOption)createNew {
    if (_trainingMode) {
        return;
    }
    
    if (createNew != CreateTrainingOptionResume) {
        [self askForTrainingType:^(enum TrainingType trainingType) {
            NSLog(@"starting training - trainingType: %ld", (long)trainingType);
            
            [self prepareForTraining:trainingType];
            
            
            if (![DejalActivityView currentActivityView]) {
                [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Preparing Training...", nil)];
            }
            [self bk_performBlock:^(id obj) {
                [self startNewTraining:trainingType createOption:createNew];
            } afterDelay:0.1];
        }];
    } else {
        _currentTraining = [[DatabaseController Current] getRunningTraining];
        
        if (_currentTraining) {
            [self prepareForTraining:_currentTraining.trainingType];
            [self continueTraining];
        } else {
            // for repetition training we simply take the last training scope, and generate a new training session from it.
            
            _currentTraining = [[DatabaseController Current] getLastRepetitionLearningTraining];
            if (!_currentTraining) {
                DDLogError(@"Resume training requested, without running training and without last repetition learning.");
                return;
            }

            DDLogDebug(@"Starting a new repetition training based on an existing training.");

            if (![DejalActivityView currentActivityView]) {
                [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Preparing Training...", nil)];
            }
            
            [_datasource loadForTraining:_currentTraining finished:^{
                [self startNewTraining:_currentTraining.trainingType createOption:CreateTrainingOptionAllFromDatasource];
            }];
        }
    }
}

- (void) prepareForTraining:(enum TrainingType)trainingType {
    //set surrounding view in training mode
    if (trainingType == TrainingTypeSequence) {
        [self setupTrainingController];
    } else if (trainingType == TrainingTypeRepetition) {
        self.viewMode = cViewTypeRepetitionTrainingPin;
    }

    _trainingMode = YES;
    [self updateCaptionVisibility];
    [self disableCaptionInteraction];
    self.pagingScrollView.scrollEnabled = NO;
    [((SOBNavigationViewController*)self.navigationController) updateNavigationButtonItems:self];
    [self hideThumbView];
}

- (void) presentTrainingPopover {
    if (!_viewHasAppeared) {
        NSLog(@"Wanting to present training popover, but view has not appeared yet. postponing.");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBarButtonItem *trainingButton = ((SOBNavigationViewController *)self.navigationController).resumeTrainingItem;
        UIView *btnView2 = [trainingButton valueForKey:@"view"];
        CGRect tmp = btnView2.frame;
        tmp.origin.y += 20;
        NSLog(@"Presenting popover from rect%@ tmp: %@ preferredContentSize: %@", NSStringFromCGRect(btnView2.frame), NSStringFromCGRect(tmp), NSStringFromCGSize(_trainingController.preferredContentSize));
        [_trainingPopover presentPopoverFromRect:tmp inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    });
}

- (void) disableCaptionInteraction {
    self.displayCaption = NO;
    self.panGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    self.captionTapGestureRecognizer.enabled = NO;
}

- (SOBNavigationViewController*) sobNavigationViewController {
    return (SOBNavigationViewController*)self.navigationController;
}

- (void) pauseTraining {
    NSLog(@"We want to pause the training.");
    if ([self trainingEnded]) {
        [self backToList:nil];
        return;
    }

    _pausedTraining = !_pausedTraining;
    [[self sobNavigationViewController] updateNavigationButtonItems:self];
    
    if (self.viewMode == cViewTypeRepetitionTrainingPin) {
        [self repetitionShowStatusOverlay:NO];
    } else if (IS_PHONE) {
        [self showIntermediateResult];
        return;
    } else {
        if(_pausedTraining) {
            [self loadAnnotationsForCurrentPage];
            [self showIntermediateResult];
        } else {
            [self continueTraining:self];
        }
    }
}

- (BOOL) pausedTraining {
    return _pausedTraining;
}

- (void)startTrainingOrPostpone:(id)button createOption:(enum CreateTrainingOption)createNew {
    if (!self.isViewLoaded) {
        DDLogVerbose(@"view has not yet loaded. postponing starting training.");
        _trainingNeedStart = YES;
        _trainingCreateNew = createNew;
    } else {
        DDLogVerbose(@"view is aready loaded. starting training.");
        [self startTraining:button createOption:createNew];
    }
}

- (void)showNextQuestionButton {
    if (_btnNextQuestion) {
        [_btnNextQuestion removeFromSuperview];
        _btnNextQuestion = nil;
    }
    _trainingHeaderLabel.hidden = YES;
    SOBButtonImage *nextQuestion = [[SOBButtonImage alloc] initButtonOfType:BARBUTTON withImage:nil andText:NSLocalizedString(@"Next Question", nil)];
    [nextQuestion addTarget:self action:@selector(pressedNextQuestion:) forControlEvents:UIControlEventTouchUpInside];
    nextQuestion.frame = CGRectMake(_trainingHeaderView.bounds.size.width - nextQuestion.frame.size.width - 10,
                                  (_trainingHeaderView.bounds.size.height / 2) - (nextQuestion.frame.size.height/2),
                                  nextQuestion.frame.size.width, nextQuestion.frame.size.height);
    nextQuestion.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_trainingHeaderView addSubview:nextQuestion];
    _btnNextQuestion = nextQuestion;
}

- (void)pressedNextQuestion:(id) sender {
    _trainingHeaderLabel.hidden = NO;
    [_btnNextQuestion removeFromSuperview];
    [self nextQuestion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == cTrainingAlert100PercentCorrect) {
        if (buttonIndex == 1) {
            // TODO open URL.
            Contest100Provider *contest = [Contest100Provider defaultProvider];
            
            NSString *url = [contest winUrlForFigure:[_datasource getCurrentSelection].filename];
            NSLog(@"Opening URL %@", url);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
		[_trainingController deselectAllRows];
		[self selectNextQuestionAndCloseCurrentWithState:cLabelStateSolvedCorrect];
    } else if(alertView.tag == cTrainingAlertCorrect) {
		[_trainingController deselectAllRows];
		[self selectNextQuestionAndCloseCurrentWithState:cLabelStateSolvedCorrect];
	} else if (alertView.tag == cTrainingAlertWrongFirstTry){
		if(buttonIndex == 0){
			[_trainingController deselectAllRows];
		} else if(buttonIndex == 1) {
			[_trainingController deselectAllRows];
			[self selectNextQuestionAndCloseCurrentWithState:cLabelStateSolvedWrong];
		} else if (buttonIndex == 2) {
            [self nextFigureWithDialog:NO];
        }
		[self loadAnnotationsForCurrentPage];
	}
	else if(alertView.tag == cTrainingAlertWrongSecondTry){
		if(buttonIndex == 0) {
			[_trainingController deselectAllRows];
			[self solveQuestion:nil];
		}
		else if (buttonIndex == 1) {
            [self selectNextQuestionAndCloseCurrentWithState:cLabelStateSolvedWrong];
        }
	}
	else if(alertView.tag == cTrainingAlertNextFigure) {
		if(buttonIndex == 0){
			//do nothing
		}
		else if(buttonIndex == 1){
			[self nextFigureWithDialog:NO];
		}
	}
	else if(alertView.tag == cTrainingAlertEndTraining){
		if(buttonIndex == 0){
			//do nothing
		}
		else if(buttonIndex == 1){
			[self endTrainingWithDialog:NO];
		}
	}
	else {
        // HP 2016-09-26 figure out if this code is actually ever called?!
        @throw [NSException exceptionWithName:@"Not used?!" reason:@"Unused code." userInfo:nil];
		if(buttonIndex == 0) {
            if (![DejalActivityView currentActivityView]) {
                [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Preparing Training...", nil)];
            }
            [self bk_performBlock:^(id obj) {
                [self startNewTraining:TrainingTypeSequence createOption:CreateTrainingOptionAllFromDatasource];
            } afterDelay:0.1];
		} else {
			[self continueTraining];
		}
	}
}


- (void) askForTrainingType:(void (^)(enum TrainingType trainingType))callback {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SpacedRepetition" bundle:nil];
    SelectTrainingTypeViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"SelectTrainingTypeViewController"];
    ctrl.onFinish = ^void(SelectTrainingTypeViewController *sender, BOOL cancelled, enum TrainingType trainingType) {
        if (cancelled) {
            // User must make a choice.
        } else {
            [sender dismissViewControllerAnimated:YES completion:nil];
            callback(trainingType);
        }
    };
    [self presentViewController:ctrl animated:YES completion:nil];
}


- (void)startNewTraining:(enum TrainingType)trainingType createOption:(enum CreateTrainingOption)createOption {
    NSError *error = nil;
	
    [[DatabaseController Current] abortRunningTrainings];
	
	//Create new training
	Training *training = [NSEntityDescription insertNewObjectForEntityForName:@"Training" inManagedObjectContext:_managedObjectContext];
	training.start = [[NSDate alloc] init];
    training.laststart = training.start;
	training.inprogress = [NSNumber numberWithBool:YES];
	training.currentindex = [NSNumber numberWithInteger:[self.pagingScrollView indexOfSelectedPage]];
//	training.name = @"Name"; //TODO: Set name for training
    training.name = [_datasource trainingName];
    training.nametype = [NSNumber numberWithInt:[_datasource trainingNameType]];
    training.currentmode = [NSNumber numberWithInt:trainingType == TrainingTypeRepetition ? cViewTypeRepetitionTrainingPin : cViewTypeTrainingPin];
    training.trainingType = trainingType;
    
    long totalLabelCount = 0;
    
    int figureSyncStart = 0;
    int figureSyncCount = [self.datasource figureAvailableCount];
    
    if (trainingType == TrainingTypeRepetition && createOption == CreateTrainingOptionSingleFigure) {
        figureSyncStart = (int) [self.pagingScrollView indexOfSelectedPage];
        figureSyncCount = 1;
        FigureInfo *figure = [_datasource figureAtGlobalIndex:figureSyncStart];
        
        training.name = figure.shortlabel;
        training.nametype = @(TrainingNameTypeSingleFigure);
    }
    
    if(![_managedObjectContext save:&error]){
        //Errorhandling
        DDLogWarn(@"Error while updating CoreData %@", error);
    }

	_currentTraining = training;
	
    //NSDate *syncDate = [NSDate date];
	for (int i = figureSyncStart; i < figureSyncStart + figureSyncCount; i++) {
        FigureInfo *f = [_datasource figureAtGlobalIndex:i];
		Training_Figures *figure = [NSEntityDescription insertNewObjectForEntityForName:@"Training_Figures" inManagedObjectContext:_managedObjectContext];
		figure.figure_id = [NSNumber numberWithFloat:f.idval];
		figure.order = [NSNumber numberWithInt:i];
		figure.completed = [NSNumber numberWithBool:NO];
		figure.training = _currentTraining;
        
        Repetition_Figure *fig;
        
        if (trainingType == TrainingTypeRepetition) {
            fig = [Repetition_Figure findByFigureId:figure.figure_id.longValue context:_managedObjectContext];
            if (fig == nil) {
                fig = [NSEntityDescription insertNewObjectForEntityForName:@"Repetition_Figure" inManagedObjectContext:_managedObjectContext];
                fig.figure_id = figure.figure_id;
                fig.order = figure.order;
                //fig.synced = syncDate;
            }
            fig.last_training = _currentTraining;
            fig.label_count = @(f.labelCount);
            
        }
        if (f.interactive) {
            totalLabelCount += f.labelCount;
        }

		if(![_managedObjectContext save:&error]){
			//Errorhandling
			DDLogWarn(@"Error while updating CoreData %@", error);
		}
		if(i == [self.pagingScrollView indexOfSelectedPage]) {
			_currentFigure = figure;
            _currentRepetitionFigure = fig;
            [_datasource setCurrentSelection:f];
        }
	}
    
    training.repetition_amount_total = @(totalLabelCount);
    
    if(![_managedObjectContext save:&error]){
        //Errorhandling
        DDLogWarn(@"Error while updating CoreData %@", error);
    }
    DDLogInfo(@"training figure count: %ld", (unsigned long)_currentTraining.figures.count);
    [_managedObjectContext processPendingChanges];
    DDLogInfo(@"training figure count: %ld", (unsigned long)_currentTraining.figures.count);

    
    [[DatabaseController Current] trackEventWithCategory:@"Training" withAction:@"started" withLabel:@"Started" withValue:[NSNumber numberWithInt:figureSyncCount]];
    [[DatabaseController Current] trackEventWithCategory:@"Training" withAction:@"starttype" withLabel:NSStringFromTrainingTypeForAnalytics(trainingType) withValue:[NSNumber numberWithInt:figureSyncCount]];
	
    if (trainingType == TrainingTypeRepetition) {
        viewMode = cViewTypeRepetitionTrainingPin;
//        [_datasource loadForTraining:_currentTraining finished:^{
            [self prepareRepetitionTrainingQuestions:createOption];
            _currentFigure = nil;
            [self nextRepetitionTrainingQuestion];
            [DejalActivityView removeView];
//        }];
        return;
    } else {
        viewMode = cViewTypeTrainingPin;
    }
    
    [self configureViewWithViewType:viewMode recallPosition:NO onDone:^{
        NSLog(@"Loading is done? hmmmm");
        [self updateTrainingDataForCurrentPage];
        [self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
        [DejalActivityView removeView];
        NSLog(@"removing dejal activity view.");
    }];
}

- (void)repetitionLogDebug:(NSString *)string {
    if (!self.repetitionDebugTextView) {
        return;
    }
    self.repetitionDebugTextView.text = [@[string, self.repetitionDebugTextView.text] componentsJoinedByString:@"\n"];
//    [self.repetitionDebugTextView flashScrollIndicators];
}

/// Returns a dictionary grouped by type.
- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)repetitionLabelsByType {
    return [_currentTraining repetitionLabelsByType:_managedObjectContext];
}

- (void)repetitionDebugLabels {
    NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *labelsByType = [self repetitionLabelsByType];
    
    
    DDLogDebug(@"Active Labels: %ld, Due: %ld, New: %ld, Learning: %ld, Reviewing: %ld",
               (unsigned long)labelsByType[RepetitionFigureLabelTypeAll].count,
               (unsigned long)labelsByType[RepetitionFigureLabelTypeDue].count,
               (unsigned long)labelsByType[RepetitionFigureLabelTypeNew].count,
               (unsigned long)labelsByType[RepetitionFigureLabelTypeLearning].count,
               (unsigned long)labelsByType[RepetitionFigureLabelTypeReviewing].count);
    [self repetitionLogDebug:[Training stringForRepetitionLabelsByType:labelsByType]];
}

- (void)nextRepetitionTrainingQuestion {
    NSArray<Repetition_FigureLabel *> *learningLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"type == %@ && active == %@ && (due <= %@ || due == nil)", RepetitionFigureLabelTypeLearning, _currentTraining.start, [NSDate date]] inContext:_managedObjectContext order:@[@{@"due": @"ASC"}]];

    NSArray<Repetition_FigureLabel *> *reviewingLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"type == %@ && active == %@ && (due <= %@ || due == nil)", RepetitionFigureLabelTypeReviewing, _currentTraining.start, [NSDate date]] inContext:_managedObjectContext order:@[@{@"due": @"ASC"}]];

    NSArray<Repetition_FigureLabel *> *newLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"type == %@ && active == %@", RepetitionFigureLabelTypeNew, _currentTraining.start, [NSDate date]] inContext:_managedObjectContext order:@[@{@"figure_label_order": @"ASC"}]];
    
    NSArray *labels = [[learningLabels arrayByAddingObjectsFromArray:reviewingLabels] arrayByAddingObjectsFromArray:newLabels];
    
    if (labels.count == 0) {
        DDLogDebug(@"No labels are overdue. Check if there are any other left with active date %@", _currentTraining.start);
        labels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"active == %@ AND (type == %@ OR type == %@)", _currentTraining.start, RepetitionFigureLabelTypeLearning, RepetitionFigureLabelTypeReviewing] inContext:_managedObjectContext order:@[@{@"due": @"ASC"}]];
    }
    
    DDLogVerbose(@"All training figures: \n%@", [[labels bk_map:^id(Repetition_FigureLabel *obj) { return obj.debugString; }] componentsJoinedByString:@"\n"]);
    [self repetitionDebugLabels];
    
    if (labels.count > 0) {
        _currentQuestionLabel = labels[0];
    } else {
        // We are finished.
        DDLogInfo(@"No labels remaining. User has finished training!");
        [self repetitionFinishTraining];
        return;
    }
    // TODO check if it is still the same figure?!
    NSNumber *nextFigureId = _currentQuestionLabel.figure.figure_id;
    
    if (![_currentFigure.figure_id isEqualToNumber:nextFigureId]) {
        // we have to switch figure.
        [self.datasource setCurrentSelectionFigureId:nextFigureId.longValue];
        long pos = [self.datasource getCurrentSelectionGlobalIndex];
        if (pos >= _currentTraining.figures.count) {
            DDLogInfo(@"Position %ld is out of range of figures %ld - using the last figure.", pos, (unsigned long)_currentTraining.figures.count);
            _currentFigure = _currentTraining.figures.lastObject;
        } else {
            _currentFigure = [_currentTraining.figures objectAtIndex:pos];
        }
        DDLogVerbose(@"Next figure id is %ld - global index: %ld", nextFigureId.longValue, pos);
        NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:pos];
        [self.pagingScrollView selectPageAtIndex:pos animated:NO];
        [self loadAnnotationsForViewType:self.viewMode forIndex:index andPage:page reloadData:YES];
        [self updateTrainingDataForCurrentPage];
//        [self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
        [self loadAnnotationsForViewType:viewMode forIndex:pos andPage:page reloadData:YES];
    } else {
        DDLogDebug(@"Next question is the same figure as we currently have in focus.. nothing to do. (%@ / %@)", nextFigureId, _currentFigure.figure_id);
        [self loadAnnotationsForCurrentPage];
    }
    
    [self repetitionUpdateOverlaysShowAnswer:NO];
}

- (void)prepareRepetitionTrainingQuestions:(enum CreateTrainingOption)createTrainingOption {
    NSMutableArray<Repetition_FigureLabel *> *questions = [[NSMutableArray alloc] init];
    FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
    NSDate *syncDate = _currentTraining.start;
    
    DDLogVerbose(@"Preparing spaced repetition training questsions for training starting at %@", syncDate);
    
    // select from Repetition_FigureLabel where last_training = currentTraining and type = 'learning' and (lastchanged + session_step < NOW) order by lastchanged + sessions_step
    NSArray<Repetition_FigureLabel *> *learningLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training == %@ && type == %@ && due < %@", _currentTraining, RepetitionFigureLabelTypeLearning, syncDate] inContext:_managedObjectContext order:@{@"due": @"ASC"} limit:@(RepetitionMaxItems)];
    [questions addObjectsFromArray:learningLabels];
    
    NSArray<Repetition_FigureLabel *> *reviewLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training == %@ && type == %@ && due < %@", _currentTraining, RepetitionFigureLabelTypeReviewing, syncDate] inContext:_managedObjectContext order:@{@"due": @"ASC"} limit:@(RepetitionMaxItems-questions.count)];
    [questions addObjectsFromArray:reviewLabels];

    NSArray<Repetition_FigureLabel *> *newLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training == %@ && type == %@", _currentTraining, RepetitionFigureLabelTypeNew, syncDate] inContext:_managedObjectContext order:@{@"due": @"ASC"} limit:@(RepetitionMaxItems-questions.count)];
    [questions addObjectsFromArray:newLabels];
    
    long start = 0;
    long count = [self.datasource figureCount];
    
    if (createTrainingOption == CreateTrainingOptionSingleFigure) {
        start = _currentTraining.currentindex.longValue;
        count = 1;
    }
    
//    [queue inDatabase:^(FMDatabase *db) {

        for (long i = start ; i < start+count ; i++) {
            FigureInfo *figureInfo = [self.datasource figureAtGlobalIndex:i];
            
            if (!figureInfo.interactive) {
                DDLogDebug(@"Figure is not interactive, skipping sync.");
                continue;
            }
            
            Training_Figures *figure = [Training_Figures findByFigureId:figureInfo.idval context:_managedObjectContext];
            
            Repetition_Figure *fig = [Repetition_Figure findByFigureId:figureInfo.idval context:_managedObjectContext];
            if (fig == nil) {
                DDLogError(@"Encountered missing Figure while preparing training. this hsould not happen, it must already be synced in startNewTraining.");
                fig = [NSEntityDescription insertNewObjectForEntityForName:@"Repetition_Figure" inManagedObjectContext:_managedObjectContext];
                fig.figure_id = @(figureInfo.idval);
                fig.order = figure.order;
                fig.label_count = @(figureInfo.labelCount);
                fig.last_training = _currentTraining;
            } else {
                if (fig.synced) {
                    DDLogDebug(@"figure %ld was already synced %@, skipping. - label count: %ld - expected: %ld", fig.figure_id.longValue, fig.synced, (unsigned long) fig.labels.count, fig.label_count.longValue);
                    if (fig.labels.count == 0) {
                        DDLogError(@"figure was synced, but has no labels?!");
                    } else {
                        continue;
                    }
                }
            }
            fig.last_training = _currentTraining;
            
            [self loadLabelsAndSpotsForFigure:figureInfo doneCallback:^(NSMutableArray *labels, NSMutableDictionary *spots) {
//                dispatch_sync(dispatch_get_main_queue(), ^{
                
                int sortorder = 0;
                for (NSDictionary *label in labels) {
                    NSNumber *labelId = label[@"id"];
                    NSNumber *spotCount = label[@"spot_count"];
                    
                    if (spotCount.integerValue == 0) {
                        DDLogVerbose(@"SpotCount: 0 - Skipping spot.");
                        continue;
                    }
                    DDLogVerbose(@"SpotCount: %@", spotCount);
                    
                    Repetition_FigureLabel *figureLabel = [Repetition_FigureLabel findByLabelId:labelId.integerValue context:_managedObjectContext];
                    
                    if (figureLabel == nil) {
                        figureLabel = [Repetition_FigureLabel createInContext:_managedObjectContext];
                        figureLabel.type = RepetitionFigureLabelTypeNew;
                        figureLabel.figure_label_id = labelId;
                        figureLabel.figure_label_order = [NSNumber numberWithInt:sortorder++];
                    }
                    figureLabel.figure = fig;
                    figureLabel.interval = @1;
                    figureLabel.easefactor = @250;
                    figureLabel.active = nil;
                    figureLabel.lastscheduled = syncDate;
                    
                    QuestionInfo *question = [[QuestionInfo alloc] init];
                    question.figure = figureInfo;
                    question.label = label;
                    
                    if (questions.count < RepetitionMaxItems) {
                        [questions addObject:figureLabel];
                    }
                }
                
                fig.synced = syncDate;
//                });

            }];
            
            DDLogDebug(@"Synced figure %@ - questions: %ld", figureInfo.longlabel, (unsigned long)questions.count);
            if (questions.count >= RepetitionMaxItems) {
                break;
            }
        }
//        NSError *err;
//        if (![_managedObjectContext save:&err]) {
//            DDLogError(@"Error saving managed object context %@", err);
//        }
//    }];
    
    if (questions.count == 0) {
        DDLogDebug(@"No questions found, try to find questions which are not yet overdue.");
        
        NSArray<Repetition_FigureLabel *> *nextLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training == %@ && type == %@", _currentTraining, RepetitionFigureLabelTypeReviewing, syncDate] inContext:_managedObjectContext order:@{@"due": @"ASC"} limit:@(RepetitionMaxItems-questions.count)];
        [questions addObjectsFromArray:nextLabels];

        DDLogDebug(@"Selected next questions.. %ld", (unsigned long)nextLabels.count);
    }
    
    
    for (Repetition_FigureLabel *label in questions) {
        label.active = syncDate;
    }
    
    NSError *err;
    if (![_managedObjectContext save:&err]) {
        DDLogError(@"Error saving managed object context %@", err);
    }
    
    DDLogDebug(@"All our qestions: (%ld) \n%@", (unsigned long)questions.count, [[questions bk_map:^id(Repetition_FigureLabel *obj) {
        return obj.debugString;
    }] componentsJoinedByString:@"\n"]);
    
    _currentQuestionLabel = questions[0];
    [self repetitionTrainingDebug:questions];
    [self repetitionDebugLabels];
}

- (void)continueTraining {
    NSInteger index = [self.datasource getCurrentSelectionGlobalIndex];
    _currentTraining = [[DatabaseController Current] getRunningTraining];
    _currentFigure = [_currentTraining.figures objectAtIndex:index];

    [[DatabaseController Current] trackEventWithCategory:@"Training" withAction:@"resumed" withLabel:@"Resumed" withValue:nil];
    [[DatabaseController Current] trackEventWithCategory:@"Training" withAction:@"resumetype" withLabel:NSStringFromTrainingTypeForAnalytics(_currentTraining.trainingType) withValue:nil];
    
    [self resumeTrainingDuration];

	viewMode = [_currentTraining.currentmode intValue];
	[self configureViewWithViewType:viewMode recallPosition:NO];
	if(self.viewMode == cViewTypeTrainingLabel){
		_trainingController.trainingModeControl.selectedSegmentIndex = 1;
	}
	NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
	[self loadAnnotationsForViewType:self.viewMode forIndex:index andPage:page reloadData:YES];
    if (viewMode == cViewTypeRepetitionTrainingPin) {
        _currentFigure = nil;
        [self nextRepetitionTrainingQuestion];
        [self repetitionUpdateOverlaysShowAnswer:NO];
    } else {
        [self updateTrainingDataForCurrentPage];
        [self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
        [self loadAnnotationsForCurrentPage];
    }
    [DejalActivityView removeView];
//    if (IS_PHONE && [self numberOfLabelsToGuess] < 1) {
//        [self showPageResult];
//    }

}


- (void)endTrainingMode {
	[_trainingPopover dismissPopoverAnimated:YES];
	_trainingController = nil;
	_trainingPopover = nil;
	_trainingMode = NO;
	self.panGestureRecognizer.enabled = YES;
	self.tapGestureRecognizer.enabled = YES;
	self.captionTapGestureRecognizer.enabled = YES;
	self.pagingScrollView.scrollEnabled = YES;
	[self setViewMode:cViewTypePin];
	//TODO: dismiss to result
}

- (void)updateTrainingDataForCurrentPage {
	NSError *error = nil;
	
	if(_currentFigure && _currentFigure.labels.count > 0) {
		for (NSMutableDictionary *label in _labels) {
			for (Training_Figure_Labels *managedLabel in _currentFigure.labels) {
				if([managedLabel.label_id integerValue] == [[label valueForKey:@"id"] integerValue]){
					[label setValue:managedLabel.state forKey:@"trainingState"];
					[label setValue:managedLabel forKey:@"managedObject"];
				}
			}
		}
	}
	else {
		//Store labels in database
        NSLog(@"Storing labels in local database...");
        NSMutableArray *availableLabels = [NSMutableArray array];
		for (NSMutableDictionary *label in _labels) {
			NSString *title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
			NSArray *spots = [_spots objectForKey:[label objectForKey:@"id"]];
			if(![title isEqual:[NSNull null]] && spots.count > 0) {
                NSNumber *state = [NSNumber numberWithInt:cLabelStateNone];
                if ([availableLabels containsObject:title]) {
                    state = [NSNumber numberWithInt:cLabelStateDuplicate];
                } else {
                    [availableLabels addObject:title];
                }
                
                NSNumber *labelId = [label valueForKey:@"id"];
                
				Training_Figure_Labels *figure_label = [NSEntityDescription insertNewObjectForEntityForName:@"Training_Figure_Labels" inManagedObjectContext:_managedObjectContext];
				figure_label.label_id = [label valueForKey:@"id"];
				figure_label.state = state;
				figure_label.figure = _currentFigure;
                
                if (viewMode == cViewTypeRepetitionTrainingPin) {
                    Repetition_FigureLabel *repetitionLabel = [Repetition_FigureLabel findByLabelId:labelId.longValue context:_managedObjectContext];
                    if (!repetitionLabel) {
                        NSAssert(NO, @"This should never be called. TODO Remove this code.");
                        repetitionLabel = [Repetition_FigureLabel createInContext:_managedObjectContext];
                        repetitionLabel.figure = _currentRepetitionFigure;
                        repetitionLabel.type = RepetitionFigureLabelTypeNew;
                        repetitionLabel.session_step = @0;
                        repetitionLabel.easefactor = @250;
                        repetitionLabel.lastscheduled = nil;
                        repetitionLabel.lastanswered = nil;
                        repetitionLabel.interval = @1;
                        repetitionLabel.active = nil;
                        repetitionLabel.figure_label_id = [label valueForKey:@"id"];
                        repetitionLabel.figure_label_order = nil;
                    }
                }
				
				if(![_managedObjectContext save:&error]){
					//Errorhandling
					DDLogWarn(@"Error while updating CoreData %@", error);
				}
				
				[label setValue:state forKey:@"trainingState"];
				[label setValue:figure_label forKey:@"managedObject"];
			}
		}
	}
}

- (NSInteger)numberOfLabelsToGuess {
	return [self parsedLabelsToGuess].count;
}

- (NSArray*)parsedLabels {
	NSMutableArray* parsedLabels = [[NSMutableArray alloc] init];
	for (NSDictionary *label in _labels) {
		NSString *title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
		NSArray *spots = [_spots objectForKey:[label objectForKey:@"id"]];
		if(![title isEqual:[NSNull null]] && spots.count > 0)
			[parsedLabels addObject:label];
	}
	return parsedLabels;
}

// The labels with State = None
- (NSArray*)parsedLabelsToGuess {
	NSMutableArray* parsedLabels = [[NSMutableArray alloc] init];
	for (NSDictionary *label in [self parsedLabels]) {
		if([[label objectForKey:@"trainingState"] integerValue] == cLabelStateNone)
			[parsedLabels addObject:label];
	}
	return parsedLabels;
}

- (BOOL) isFigureInteractive {
    FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:[self.pagingScrollView indexOfSelectedPage]];
    return currentFigure.interactive;
}

- (void)closeCurrentWithState:(NSInteger)state {
    //Update current Question/Label with provided State
	if(_currentTrainingLabel){
        NSError *error = nil;
		[_currentTrainingLabel setValue:[NSNumber numberWithInteger:state] forKey:@"trainingState"];
		Training_Figure_Labels *label = [_currentTrainingLabel objectForKey:@"managedObject"];
		label.state = [NSNumber numberWithInteger:state];
		if(![_managedObjectContext save:&error]){
			//Errorhandling
			DDLogWarn(@"Error while updating CoreData %@", error);
		}
		_currentTrainingLabel = nil;
	}

}

- (void)selectNextQuestionAndCloseCurrentWithState:(NSInteger)state {
    [self repetitionUpdateOverlaysShowAnswer:NO];
    if (_currentTraining.trainingType == TrainingTypeRepetition) {
        return;
    }
	
    FigureInfo* currentFigure = [self.datasource figureAtGlobalIndex:[self.pagingScrollView indexOfSelectedPage]];
    if (currentFigure && !currentFigure.interactive) {
        NSLog(@"Loading next figure.");
        [self nextFigureWithDialog:NO];
        return;
    }
    
    [self closeCurrentWithState:state];
	
	//Check if all Questions/Labels cleared
	NSInteger count = [self numberOfLabelsToGuess];
    if (_spots == nil) {
        // we are not yet initialized.
        return;
    }
	if(count == 0){
        [self loadAnnotationsForCurrentPage];
		[self showPageResult];
		return;
	}
	else if(count == 1){
		_trainingController.nextQuestionEnabled = NO;
	}
	else {
		_trainingController.nextQuestionEnabled = YES;
	}
    _trainingController.solveButtonEnabled = YES;
	
	//Get next Question/Label
	NSMutableDictionary *nextLabel = nil;
	NSArray *labelsToGuess = [self parsedLabelsToGuess];
	while (nextLabel == nil) {
		NSUInteger randomIndex = arc4random() % [labelsToGuess count];
		NSMutableDictionary *temp = [labelsToGuess objectAtIndex:randomIndex];
		nextLabel = temp;
	}
	
	_trainingController.labels = nil;
	_currentTrainingLabel = nextLabel;
	if(self.viewMode == cViewTypeTrainingPin){
        NSString *trainingLabelText = [_currentTrainingLabel objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
        NSLog(@"TrainingLabelText: %@", trainingLabelText);
        trainingLabelText = [trainingLabelText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        _trainingHeaderLabel.text = trainingLabelText;
		NSArray *array = [[NSArray alloc] initWithObjects:_currentTrainingLabel, nil];
		[_trainingController setLabels:array];
	}
	else if(self.viewMode == cViewTypeTrainingLabel){
		[_trainingController setLabels:[self parsedLabels]];
	}
	
	[self loadAnnotationsForCurrentPage];
}

- (BOOL) handleCorrectAnswer{
    [self closeCurrentWithState:cLabelStateSolvedCorrect];
    [self calculateResult];
    if ([self numberOfLabelsToGuess] < 1) {
        Contest100Provider *contest = [Contest100Provider defaultProvider];
        if ([contest isContestActive]) {
            if ([_currentFigure.amount_wrong intValue] == 0 && [_currentFigure.amount_correct intValue] > 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congratulations – 100% correct!", nil) message:NSLocalizedString(@"Take part and win one of 30 Sobotta Apps.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"Participate", nil), nil];
                // Teilnehmen
                alertView.tag = cTrainingAlert100PercentCorrect;
                [alertView show];
                return YES;
            }
        }
    }
    return NO;
}

- (void) pinSelected:(id)sender {
	NAPinAnnotationView *pin = sender;
	
	if(self.viewMode == cViewTypeTrainingPin){
		if(_trainingController.viewMode == cTrainingViewModeTraining){
            NSDictionary *label = [self getLabelById:pin.annotation.labelid];
            int labelState = [[label objectForKey:@"trainingState"] integerValue];
			if(_datasource.cheatMode || pin.annotation.labelid == [[_currentTrainingLabel objectForKey:@"id"] integerValue]){
                if (labelState == cLabelStateResolve) {
                    NAMapView* map = (NAMapView*)pin.superview;
                    [map showCallOut:pin];
                    return;
                }

                if ([self handleCorrectAnswer]) {
                    return;
                }
                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gratulation" message:@"Sie haben diese Abbildung zu 100% trainiert. Möchten Sie mit diesem Ergebnis am Gewinnspiel teilnehmen?" delegate:self cancelButtonTitle:@"Später" otherButtonTitles:@"Teilnehmen", nil];
                
                if (IS_PHONE && [self numberOfLabelsToGuess] < 1) {
                    // [self numberOfLabelsToGuess] < 1
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Correct answer", nil) message:NSLocalizedString(@"You have found the term", nil) delegate:self cancelButtonTitle: NSLocalizedString(@"Next Figure", nil) otherButtonTitles: nil];
                    alertView.tag = cTrainingAlertCorrect;
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Correct answer", nil) message:NSLocalizedString(@"You have found the term", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Next Question", nil) otherButtonTitles: nil];
                    alertView.tag = cTrainingAlertCorrect;
                    [alertView show];
                }
			}
			else {
				if(labelState == cLabelStateNone) {
					NSString *buttonTitle = NSLocalizedString(@"Retry", nil);
					NSInteger tag = cTrainingAlertWrongFirstTry;
					if([_currentTrainingLabel objectForKey:@"secondTry"] != nil){
						buttonTitle = NSLocalizedString(@"Solve", nil);
						tag = cTrainingAlertWrongSecondTry;
					}
					else {
						[_currentTrainingLabel setValue:[NSNumber numberWithBool:YES] forKey:@"secondTry"];
					}
                    if (IS_PHONE) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong answer", nil) message:NSLocalizedString(@"You did not find the term", nil) delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:NSLocalizedString(@"Next Question", nil), NSLocalizedString(@"Next Figure", nil), nil];
                        alertView.tag = tag;
                        [alertView show];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong answer", nil) message:NSLocalizedString(@"You did not find the term", nil) delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:NSLocalizedString(@"Next Question", nil), nil];
                        alertView.tag = tag;
                        [alertView show];
                    }
					[pin setImage:[UIImage imageNamed:cPinAnnotationRed] forState:UIControlStateNormal];
					//[self loadAnnotationsForCurrentPage];
				} else if (labelState == cLabelStateSolvedCorrect || labelState == cLabelStateSolvedWrong || labelState == cLabelStateSkipped) {
                    NAMapView* map = (NAMapView*)pin.superview;
                    [map showCallOut:pin];
                }
			}
		}
		else if(_trainingController.viewMode == cTrainingViewModePageResult) {
			NSDictionary *label = [self getLabelById:pin.annotation.labelid];
			if([[label objectForKey:@"trainingState"] integerValue] != cLabelStateNone) {
				NAMapView* map = (NAMapView*)pin.superview;
				[map showCallOut:pin];
			}
		}
	}
	else {
		if(_trainingController.viewMode != cTrainingViewModeTraining){
			NSDictionary *label = [self getLabelById:pin.annotation.labelid];
			if([[label objectForKey:@"trainingState"] integerValue] != cLabelStateNone) {
				NAMapView* map = (NAMapView*)pin.superview;
				[map showCallOut:pin];
			}
		}
	}
}

- (NSDictionary*)getLabelById:(NSInteger)identifier {
	for (NSDictionary *label in _labels) {
		if([[label objectForKey:@"id"] integerValue] == identifier)
			return label;
	}
	return nil;
}

- (void)nextQuestion:(id)sender {
	_trainingController.solveButtonEnabled = YES;
	[self selectNextQuestionAndCloseCurrentWithState:cLabelStateSolvedWrong];
}
	
- (void)solveQuestion:(id)sender {
    if (IS_PHONE) {
        [self showNextQuestionButton];
    }
	[_currentTrainingLabel setValue:[NSNumber numberWithInt:cLabelStateResolve] forKey:@"trainingState"];
	if(self.viewMode == cViewTypeTrainingPin)
		[self loadAnnotationsForCurrentPage];
	else {
		[_trainingController selectRowWithLabelID:[[_currentTrainingLabel objectForKey:@"id"] integerValue]];
	}
	_trainingController.solveButtonEnabled = NO;
}

- (void)trainingModeChange:(id)sender {
	NSError *error = nil;
	
	TrainingViewController *trainingViewController = sender;
	if(trainingViewController.trainingModeControl.selectedSegmentIndex == 0) { //Pin
		viewMode = cViewTypeTrainingPin;
		[self loadAnnotationsForCurrentPage];
	} else if(trainingViewController.trainingModeControl.selectedSegmentIndex == 1) { //Label
		viewMode = cViewTypeTrainingLabel;
		[self loadAnnotationsForCurrentPage];
	} else {
		NSException* ex = [NSException exceptionWithName:@"Not implemented" reason:@"This training type is not implemented" userInfo:nil];
		@throw ex;
	}
	
	_currentTraining.currentmode = [NSNumber numberWithInt:viewMode];
	if(![_managedObjectContext save:&error]){
		//Errorhandling
        DDLogWarn(@"Error while updating CoreData %@", error);
	}
	
	[self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
}

- (void) nextFigureWithDialog:(BOOL)showDialog {
	NSError *error = nil;
	
	if(showDialog) {
		UIAlertView *alert = nil;
		if(([self.pagingScrollView indexOfSelectedPage]+1) == self.datasource.figureAvailableCount) //last page
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"End training?", nil) message:NSLocalizedString(@"Would you like to end the training?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		else
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Next image?", nil) message:NSLocalizedString(@"Do you want to switch to the next image?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		alert.tag = cTrainingAlertNextFigure;
		[alert show];
	} else {
		//Update the current figure
		_currentFigure.completed = [NSNumber numberWithBool:YES];
        [self calculateResult];
        _currentTraining.amount_completed_figures = @([_currentTraining.amount_completed_figures intValue] + 1);
		if(![_managedObjectContext save:&error]){
			//Errorhandling
			DDLogWarn(@"Error while updating CoreData %@", error);
		}
		_currentFigure = nil;
		
		if(([self.pagingScrollView indexOfSelectedPage]+1) == self.datasource.figureAvailableCount){ //last page
			[self showEndResult];
		}
		else {
			_trainingController.viewMode = cTrainingViewModeTraining;
			
			//load next figure
			NSInteger index = ([self.pagingScrollView indexOfSelectedPage]+1);
			_currentTraining.currentindex = [NSNumber numberWithInteger:index];
			_currentFigure = [_currentTraining.figures objectAtIndex:index];
            FigureInfo *selection = [_datasource figureAtGlobalIndex:index];
            [_datasource setCurrentSelection:selection];
			
			[self.pagingScrollView selectPageAtIndex:index animated:NO];
			NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
			[self loadAnnotationsForViewType:self.viewMode forIndex:index andPage:page reloadData:YES];
			[self updateTrainingDataForCurrentPage];
			[self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
			
			//check if last page
			if(([self.pagingScrollView indexOfSelectedPage]+1) == self.datasource.figureAvailableCount){ //last page
				_trainingController.showEndButton = YES;
			}
			else {
				_trainingController.showEndButton = NO;
			}
		}
	}
}

- (void) endTrainingWithDialog:(BOOL)showDialog {
	NSError *error = nil;
	
	if (showDialog) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"End training?", nil) message:NSLocalizedString(@"Would you like to end the training?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		alert.tag = cTrainingAlertEndTraining;
		[alert show];
	}
	else {
		_currentFigure.completed = [NSNumber numberWithBool:YES];
        [self calculateResult];
        _currentTraining.amount_completed_figures = @([_currentTraining.amount_completed_figures intValue] + 1);
		if(![_managedObjectContext save:&error]){
			//Errorhandling
			DDLogWarn(@"Error while updating CoreData %@", error);
		}
		
		[self showEndResult];
	}
}

- (void) continueTraining:(id)sender{
    _pausedTraining = NO;
    [self.sobNavigationViewController updateNavigationButtonItems:self];
    if (IS_PHONE && [sender isKindOfClass:[TrainingViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
	_trainingController.viewMode = cTrainingViewModeTraining;
	[self selectNextQuestionAndCloseCurrentWithState:cLabelStateNone];
}

- (void) backToList:(id)sender{
	[self endTrainingMode];
    if (IS_PHONE) {
        UIViewController *igvc = (UIViewController *) [((SOBNavigationViewController *)self.navigationController) imageGridViewController:NO];
        [self.navigationController popToViewController:igvc animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) answerSelected:(NSInteger)labelid {
	if(self.viewMode == cViewTypeTrainingLabel){
		if(_datasource.cheatMode || [[_currentTrainingLabel objectForKey:@"id"] integerValue] == labelid){
            if ([self handleCorrectAnswer]) {
                return;
            }

			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Correct answer", nil) message:NSLocalizedString(@"You have found the term", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Next Question", nil) otherButtonTitles: nil];
			alertView.tag = cTrainingAlertCorrect;
			[alertView show];
		}
		else {
			NSString *buttonTitle = NSLocalizedString(@"Retry", nil);
			NSInteger tag = cTrainingAlertWrongFirstTry;
			if([_currentTrainingLabel objectForKey:@"secondTry"] != nil){
				buttonTitle = NSLocalizedString(@"Solve", nil);
				tag = cTrainingAlertWrongSecondTry;
			}
			else {
				[_currentTrainingLabel setValue:[NSNumber numberWithBool:YES] forKey:@"secondTry"];
			}
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong answer", nil) message:NSLocalizedString(@"You did not find the term", nil) delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:NSLocalizedString(@"Next Question", nil), nil];
			alertView.tag = tag;
			[alertView show];
			//[self loadAnnotationsForCurrentPage];
		
		}
	}
}

- (void)calculateResult {
    if (_currentFigure) {
        int correct = 0;
        int wrong = 0;
        CGFloat percentage = 0;
        for (NSMutableDictionary *label in _labels) {
            NSString *title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
            NSArray *spots = [_spots objectForKey:[label objectForKey:@"id"]];
            if(![title isEqual:[NSNull null]] && spots.count > 0) {
                int state = [[label objectForKey:@"trainingState"] integerValue];
                if(state == cLabelStateSolvedCorrect) {
                    correct++;
                } else if (state != cLabelStateDuplicate) {
                    wrong++;
                }
            }
        }
        if((wrong+correct) == 0)
            percentage = 0;
        else
            percentage = (CGFloat)((CGFloat)100./(wrong+correct))*correct;
        
        _currentFigure.amount_correct = [NSNumber numberWithInt:correct];
        _currentFigure.amount_wrong = [NSNumber numberWithInt:wrong];
        _currentFigure.percent_correct = [NSNumber numberWithInt:(int)percentage];
        NSLog(@"Setting percent_correct: %d (labels: %d)", (int)percentage, correct+wrong);
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FigureProxy"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"figure_id = %@", _currentFigure.figure_id];
        NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        FigureProxy *figureProxy = nil;
        if ([ret count] < 1) {
            NSLog(@"Creating new FigureProxy.");
            figureProxy = [NSEntityDescription insertNewObjectForEntityForName:@"FigureProxy" inManagedObjectContext:_managedObjectContext];
            figureProxy.order = [_currentDBFigure objectForKey:@"sortorder"];
            figureProxy.figure_id = _currentFigure.figure_id;
        } else {
            figureProxy = [ret objectAtIndex:0];
            figureProxy.order = [_currentDBFigure objectForKey:@"sortorder"];
        }
        NSLog(@"bestTrainingResult: %@, worstTrainingResult: %@", figureProxy.bestTrainingResult.percent_correct, figureProxy.worstTrainingResult.percent_correct);
        if (!figureProxy.bestTrainingResult || figureProxy.bestTrainingResult.percent_correct.intValue < _currentFigure.percent_correct.intValue) {
            figureProxy.bestTrainingResult = _currentFigure;
            NSLog(@"setting bestTrainingResult for figureProxy.");
        }
        if (_currentFigure.completed) {
            // only set worst training result if the figure was completed.
            if (!figureProxy.worstTrainingResult || figureProxy.worstTrainingResult.percent_correct.intValue > _currentFigure.percent_correct.intValue) {
                figureProxy.worstTrainingResult = _currentFigure;
                NSLog(@"setting worstTrainingResult for figureProxy.");
            }
        }
        figureProxy.latestTrainingResult = _currentFigure;
        [_managedObjectContext save:nil];
    }
}

- (void)showPageResult {
	_trainingController.trainingName = _currentTraining.name;
    _trainingController.solveButtonEnabled = NO;
	
    int leftLabelsCount = [self numberOfLabelsToGuess];
    [self calculateResult];
    if (leftLabelsCount == 0) {
        [[DatabaseController Current] trackEventWithCategory:@"Training" withAction:@"completed" withLabel:@"OneFigure" withValue:_currentFigure.percent_correct];
    }
	
	_trainingController.trainingName = self.datasource.trainingNameLocalized;
	_trainingController.wrongStructures = [NSString stringWithFormat:@"%d %@", [_currentFigure.amount_wrong intValue], NSLocalizedString(@"wrong structures", nil)];
	_trainingController.correctStructures = [NSString stringWithFormat:@"%d %@", [_currentFigure.amount_correct intValue], NSLocalizedString(@"correct structures", nil)];
	_trainingController.percentage = [NSString stringWithFormat:@"%d%%", [_currentFigure.percent_correct intValue]];
	
	_trainingController.viewMode = cTrainingViewModePageResult;
    
    
    
    if (IS_PHONE) {
        //        _trainingController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrainingViewController"];
        NSLog(@"showPageResult - is view loaded? %d -- is loaded %d", self.isViewLoaded, _viewLoaded);
        if (self.isViewLoaded && _viewLoaded) {
            if (self.navigationController.topViewController != _trainingController) {
                [self.navigationController pushViewController:_trainingController animated:YES];
            }
        }
    }

}

- (void)showIntermediateResult {
	CGFloat correct = 0;
	CGFloat wrong = 0;
	CGFloat percentage = 0;
	
	//calculate statistics for current page (only the structures already asked for)
	for (NSMutableDictionary *label in _labels) {
		NSString *title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
		NSArray *spots = [_spots objectForKey:[label objectForKey:@"id"]];
		if(![title isEqual:[NSNull null]] && spots.count > 0) {
			if([[label objectForKey:@"trainingState"] integerValue] == cLabelStateSolvedCorrect)
				correct++;
			else if([[label objectForKey:@"trainingState"] integerValue] == cLabelStateSolvedWrong || [[label objectForKey:@"trainingState"] integerValue] == cLabelStateSkipped)
				wrong++;
		}
	}
	
	//calculate statistics for already completed pages
	NSUInteger completed = 0;
	CGFloat count = _currentTraining.figures.count;
	for (Training_Figures *figure in _currentTraining.figures) {
		if([figure.completed boolValue]){
			completed++;
			
			for (Training_Figure_Labels *label in figure.labels) {
				if([label.state integerValue] == cLabelStateSolvedCorrect)
					correct++;
				else
					wrong++;
			}
		}
	}
	
	if((wrong+correct) == 0)
		percentage = 0;
	else
		percentage = (CGFloat)((CGFloat)100/(wrong+correct))*correct;
	
	_trainingController.trainingName = self.datasource.trainingNameLocalized;
	_trainingController.wrongStructures = [NSString stringWithFormat:@"%.0f %@", wrong, NSLocalizedString(@"wrong structures", nil)];
	_trainingController.correctStructures = [NSString stringWithFormat:@"%.0f %@", correct, NSLocalizedString(@"correct structures", nil)];
	_trainingController.percentage = [NSString stringWithFormat:@"%.0f%%", percentage];
	_trainingController.structuresCount = [NSString stringWithFormat:@"%lu %@ %.0f %@", (unsigned long) (completed+1), NSLocalizedString(@"of", nil), count, NSLocalizedString(@"Images", nil)];
	
	_trainingController.viewMode = cTrainingViewModeIntermediateResult;
    
    if (IS_PHONE) {
        //        _trainingController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrainingViewController"];
        NSLog(@"showPageResult - is view loaded? %d -- is loaded %d", self.isViewLoaded, _viewLoaded);
        if (self.isViewLoaded && _viewLoaded) {
            if ([self.navigationController topViewController] != _trainingController) {
                [self.navigationController pushViewController:_trainingController animated:YES];
            } else {
                NSLog(@"training controller is already on top of the navigation controller.");
            }
        }
    }
}

- (void)showEndResult {
	NSError *error = nil;
	NSUInteger completed = 0;
	CGFloat correct = 0;
	CGFloat wrong = 0;
	CGFloat skipped = 0;
	CGFloat percentage = 0;
	CGFloat answered = 0;
	
	//calculate statistics for current page (only the structures already asked for)
    if (_currentFigure && ![_currentFigure.completed boolValue]) {
        for (NSMutableDictionary *label in _labels) {
            NSString *title = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
            NSArray *spots = [_spots objectForKey:[label objectForKey:@"id"]];
            if(![title isEqual:[NSNull null]] && spots.count > 0) {
                if([[label objectForKey:@"trainingState"] integerValue] == cLabelStateSolvedCorrect)
                    correct++;
                else if([[label objectForKey:@"trainingState"] integerValue] == cLabelStateSolvedWrong || [[label objectForKey:@"trainingState"] integerValue] == cLabelStateSkipped)
                    wrong++;
            }
        }
	}
	
	//calculate statistics for already completed pages
	for (Training_Figures *figure in _currentTraining.figures) {
        if ([figure isEqual:_currentFigure] && ![_currentFigure.completed boolValue]) {
            NSLog(@"Ignoring _currentFigure.");
            continue;
        }
		if([figure.completed boolValue]){
			completed++;
			
			for (Training_Figure_Labels *label in figure.labels) {
				if([label.state integerValue] == cLabelStateSolvedCorrect) {
					correct++;
					answered++;
				}
				else if([label.state integerValue] == cLabelStateSkipped) {
					skipped++;
					wrong++;
				}
				else if([label.state integerValue] == cLabelStateSolvedWrong) {
					wrong++;
					answered++;
				}
				else
					wrong++;
			}
		}
	}
	
	if((wrong+correct) == 0)
		percentage = 0;
	else
		percentage = (CGFloat)((CGFloat)100/(wrong+correct))*correct;
	
	_trainingController.trainingName = self.datasource.trainingNameLocalized;
	_trainingController.wrongStructures = [NSString stringWithFormat:@"%.0f %@", wrong, NSLocalizedString(@"wrong structures", nil)];
	_trainingController.correctStructures = [NSString stringWithFormat:@"%.0f %@", correct, NSLocalizedString(@"correct structures", nil)];
	_trainingController.percentage = [NSString stringWithFormat:@"%.0f%%", ceilf(percentage)];
	_trainingController.structuresCount = [NSString stringWithFormat:@"%lu %@", (unsigned long)completed, NSLocalizedString(@"Images", nil)];
	
	_trainingController.viewMode = cTrainingViewModeEndResult;
	
	//Update the training CoreData Object
	_currentTraining.inprogress = [NSNumber numberWithBool:NO];
	_currentTraining.end = [[NSDate alloc] init];
	_currentTraining.amount_answered = [NSNumber numberWithFloat:answered];
	_currentTraining.amount_correct = [NSNumber numberWithFloat:correct];
	_currentTraining.amount_skipped = [NSNumber numberWithFloat:skipped];
	_currentTraining.amount_wrong = [NSNumber numberWithFloat:wrong];
    int calculatedCompletedFigures = [_currentTraining.amount_completed_figures intValue];
    if (completed != calculatedCompletedFigures) {
        NSLog(@"ERROR completed figures and calculated completed figures are not the same?! %d vs. %lu", calculatedCompletedFigures, (unsigned long)completed);
        _currentTraining.amount_completed_figures = [NSNumber numberWithInt:completed];
    }
    NSLog(@"completed training. answered: %@, correct: %@, skipped: %@, wrong: %@", _currentTraining.amount_answered, _currentTraining.amount_correct, _currentTraining.amount_skipped, _currentTraining.amount_wrong);
	if(![_managedObjectContext save:&error]){
		//Errorhandling
		DDLogWarn(@"Error while updating CoreData %@", error);
	}
	[[self sobNavigationViewController] updateNavigationButtonItems:self];
    if (IS_PHONE) {
        if ([self.navigationController.viewControllers lastObject] != _trainingController) {
            [self.navigationController pushViewController:_trainingController animated:YES];
        } else {
            [((SOBNavigationViewController *)self.navigationController) updateNavigationButtonItems:_trainingController];
        }
    }
}

#pragma mark -
#pragma mark Notes

- (void)labelSelected:(NALabel *)label atPosition:(NSInteger)positon {
	NSError *error = nil;
	
	if(_notesView){
		[self unloadNotesView];
	}

	NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"NotesView" owner:self options:nil];
	_notesView = [subviewArray objectAtIndex:0];
    if (!IS_PHONE) {
        if(positon == cNotePositionRight) {
            _notesView.frame = CGRectMake(self.view.frame.size.width - _notesView.frame.size.width - cNoteViewRightPadding, cNoteViewTopPadding, _notesView.frame.size.width, _notesView.frame.size.height);
        } else {
            _notesView.frame = CGRectMake(cNoteViewLeftPadding, cNoteViewTopPadding, _notesView.frame.size.width, _notesView.frame.size.height);
        }
    }
	_notesView.delegate = self;
	
	//Create new managed object if new note
	if(label.managedNote == nil){
		Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:_managedObjectContext];
		note.label_id = [NSNumber numberWithInteger:label.labelid];
		note.created = [[NSDate alloc] init];
		note.color = @"green";
		
		if(![_managedObjectContext save:&error]){
			//Errorhandling
			DDLogWarn(@"Error while updating CoreData %@", error);
		}
		label.managedNote = note;
		label.hasNote = YES;
		label.noteColor = cNoteColorGreen;
	}
	
	_notesView.label = label;
    if (IS_PHONE) {
        NotesViewController *notesViewController =[[NotesViewController alloc] initWithNotesView:_notesView];
        [self.navigationController pushViewController:notesViewController animated:YES];
        return;
    }
	[self.view addSubview:_notesView];
	[self updateLabelView];
}

- (void)updateLabelView {
	NAMapView* page = (NAMapView*)[self.pagingScrollView pageAtIndex:[self.pagingScrollView indexOfSelectedPage]];
	[page.label setNeedsDisplay];
}

- (void)unloadNotesView {
    if (IS_PHONE) {
        UIViewController *vc = [self.navigationController.viewControllers lastObject];
        if ([vc isKindOfClass:[NotesViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
	if(_notesView){
		[_notesView.textView resignFirstResponder];
		[_notesView removeFromSuperview];
		
		_notesView = nil;
	}
}

- (void)labelDeselected {
	if(_notesView){
		if(_notesView.textView.text.length == 0){
			[self notes:self deleteNote:self];
		}
		else {
			[self unloadNotesView];
		}
	}
	
}

- (void)notes:(id)sender colorSelected:(UIColor *)color {
	NSError *error = nil;
	
	_notesView.label.noteColor = color;
	if([color isEqual:cNoteColorBlue]){
		[_notesView.label.managedNote setValue:@"blue" forKey:@"color"];
	}
	else if ([color isEqual:cNoteColorGreen]) {
		[_notesView.label.managedNote setValue:@"green" forKey:@"color"];
	}
	else if ([color isEqual:cNoteColorPink]) {
		[_notesView.label.managedNote setValue:@"pink" forKey:@"color"];
	}
	else if ([color isEqual:cNoteColorRed]) {
		[_notesView.label.managedNote setValue:@"red" forKey:@"color"];
	}
	else if ([color isEqual:cNoteColorViolet]) {
		[_notesView.label.managedNote setValue:@"violet" forKey:@"color"];
	}
	
	if(![_managedObjectContext save:&error]){
		//Errorhandling
		DDLogWarn(@"Error while updating CoreData %@", error);
	}
	
	[self updateLabelView];
}

- (void)notes:(id)sender deleteNote:(id)e {
	NSError *error = nil;
	[_managedObjectContext deleteObject:_notesView.label.managedNote];
	if(![_managedObjectContext save:&error]){
		//Errorhandling
		DDLogWarn(@"Error while updating CoreData %@", error);
	}
	_notesView.label.managedNote = nil;
	_notesView.label.hasNote = NO;
	_notesView.label.noteColor = nil;
	[self unloadNotesView];
	[self updateLabelView];
}

-(void)notes:(id)sender textViewDidChange:(NSString *)notetext {
	
}

- (void)notes:(id)sender textViewDidEndEditing:(NSString *)notetext {
	NSError *error = nil;
	
	[_notesView.label.managedNote setValue:notetext forKey:@"text"];
	[_notesView.label.managedNote setValue:[[NSDate alloc] init] forKey:@"updated"];
	if(![_managedObjectContext save:&error]){
		//Errorhandling
		DDLogWarn(@"Error while updating CoreData %@", error);
	}
}

- (NSString *)navigationBarTitle {
    if (_trainingMode && viewMode == cViewTypeRepetitionTrainingPin && _currentTraining) {
        NSString *trainingName = [[FigureDatasource defaultDatasource] trainingNameLocalized];
        
        NSUInteger count = [self repetitionLabelsByType][RepetitionFigureLabelTypeAll].count;
        
        NSString *remaining = [NSString stringWithFormat:NSLocalizedString(@"%ld structures remaining", nil),
                               (unsigned long)count];
        
//        // for now just assume we need 20 seconds to remember each label, no matter the type.
//        NSUInteger minutesLeft = (count * 20) / 60;
//        NSString *duration = [NSString stringWithFormat:NSLocalizedString(@"%ld Minutes remaining (%ld Cards)", nil),
//                              (unsigned long)minutesLeft,
//                              (unsigned long)count];
        
        return [(trainingName ? @[trainingName, remaining] : @[remaining]) componentsJoinedByString:@"\n"];
    }
    
    return nil;
}

- (IBAction)repetitionShowAnswerPressed:(UIButton *)sender {
    [self repetitionUpdateOverlaysShowAnswer:YES];
}

- (IBAction)repetitionAnswerPressed:(UIButton *)sender {
    RepetitionLabelRating rating;
    if (sender == self.overlayRepetitionAnswerButton1Repeat) {
        rating = RepetitionLabelRatingRepeat;
    } else if (sender == self.overlayRepetitionAnswerButton2Hard) {
        rating = RepetitionLabelRatingHard;
    } else if (sender == self.overlayRepetitionAnswerButton3Good) {
        rating = RepetitionLabelRatingGood;
    } else if (sender == self.overlayRepetitionAnswerButton4Easy) {
        rating = RepetitionLabelRatingEasy;
    } else {
        DDLogError(@"Unknown sender %@", sender);
        return;
    }
    
    
    Repetition_FigureLabel *l = _currentQuestionLabel;
    [l scheduleForRating:rating];

    [self repetitionUpdateOverlaysShowAnswer:NO];
    
    long learnedLabels = [Repetition_FigureLabel countWhere:[NSPredicate predicateWithFormat:@"type IN %@ AND due > %@ AND figure.last_training = %@", @[RepetitionFigureLabelTypeLearning, RepetitionFigureLabelTypeReviewing], [NSDate date], _currentTraining] inContext:_managedObjectContext];
    DDLogDebug(@"Learned Labels in total: %ld", learnedLabels);
    
    _currentTraining.repetition_amount_learned_total = @(learnedLabels);

    NSError *err;
    if (![_managedObjectContext save:&err]) {
        DDLogError(@"Error while saving managed object ontext. %@", err);
    }
    
    [self nextRepetitionTrainingQuestion];
}

- (void)repetitionInitOverlayViews {
    self.repetitionDebugView.hidden = YES;
    
    self.overlayRepetitionQuestionTitle.text = NSLocalizedString(@"Name this structure", nil);
    [self.overlayRepetitionQuestionButton setTitle:NSLocalizedString(@"Show answer", nil) forState:UIControlStateNormal];
//    self.overlayRepetitionAnswerTitle.text = NSLocalizedString(@"", nil);
    self.overlayRepetitionAnswerBodyLabel.text = NSLocalizedString(@"How good did you memorize this structure?", nil);
    [self.overlayRepetitionAnswerButton1Repeat setTitle:NSLocalizedString(@"Repeat", nil) forState:UIControlStateNormal];
    [self.overlayRepetitionAnswerButton2Hard setTitle:NSLocalizedString(@"Hard", nil) forState:UIControlStateNormal];
    [self.overlayRepetitionAnswerButton3Good setTitle:NSLocalizedString(@"Good", nil) forState:UIControlStateNormal];
    [self.overlayRepetitionAnswerButton4Easy setTitle:NSLocalizedString(@"Easy", nil) forState:UIControlStateNormal];
    
    NSArray<UIButton *> *answerButtons = @[self.overlayRepetitionAnswerButton1Repeat, self.overlayRepetitionAnswerButton2Hard, self.self.overlayRepetitionAnswerButton3Good, self.overlayRepetitionAnswerButton4Easy];
    
    CGFloat maxX = self.overlayRepetitionAnswer.bounds.size.width - 16;
    
    for (UIButton *btn in [answerButtons reverseObjectEnumerator]) {
        [btn sizeToFit];
        CGRect frame = btn.frame;
        frame.origin.x = maxX - frame.size.width;
        btn.frame = frame;
        maxX = frame.origin.x - 16;
    }
    
    [@[self.overlayRepetitionAnswer, self.overlayRepetitionQuestion] bk_each:^(SpacedRepetitionCardOverlay *overlayView) {
        CGRect frame = overlayView.frame;
        CGFloat height = frame.size.height;
        CGFloat bottomMargin = IS_PHONE ? 0 : 24;
        CGFloat y =  self.view.bounds.size.height - bottomMargin - height;
        overlayView.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);
        DDLogVerbose(@"overlay position before: %@ after: %@ // view bounds: %@", NSStringFromCGRect(frame), NSStringFromCGRect(overlayView.frame), NSStringFromCGRect(self.view.bounds));
        overlayView.hidden = YES;
    }];
}

- (NSDictionary *)currentQuestionLabelDictionary {
    NSNumber *labelId = self.currentQuestionLabel.figure_label_id;
    NSDictionary *ret = [_labels bk_match:^BOOL(NSDictionary *obj) {
        return [obj[@"id"] isEqualToNumber:labelId];
    }];
    DDLogVerbose(@"Found label %@ for currentQuestionLabel %@", ret, labelId);
    return ret;
}

- (void)repetitionUpdateOverlaysShowAnswer:(BOOL)showAnswer {
#ifdef DEBUG
        self.repetitionDebugView.hidden = NO;
#endif
    if (viewMode != cViewTypeRepetitionTrainingPin) {
        DDLogVerbose(@"Not in repetition training mode, hiding overlays.");
        self.overlayRepetitionAnswer.hidden = YES;
        self.overlayRepetitionQuestion.hidden = YES;
        return;
    }
    
    NSDictionary *label = [self currentQuestionLabelDictionary];
    if (label) {
        NSString *text = label[@"text"];
        text = [text stringByReplacingOccurrencesOfString:@"[\r\n]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
        self.overlayRepetitionAnswerTitle.text = text;
    }
    
    DDLogVerbose(@"Updating repetition overlay views. %d", showAnswer);
    [self.sobNavigationViewController updateNavigationButtonItems:self];
    if (showAnswer) {
        self.overlayRepetitionQuestion.hidden = YES;
        self.overlayRepetitionAnswer.hidden = NO;
    } else {
        [self repetitionLogDebug:[NSString stringWithFormat:@"Q: %@", _currentQuestionLabel.debugString]];
        self.overlayRepetitionQuestion.hidden = NO;
        self.overlayRepetitionAnswer.hidden = YES;
    }
}

- (void)repetitionTrainingDebug:(NSArray<Repetition_FigureLabel *> *)questions {
    NSArray *new = [questions bk_select:^BOOL(Repetition_FigureLabel *obj) {
        return [obj.type isEqualToString:RepetitionFigureLabelTypeNew];
    }];
    NSArray *learning = [questions bk_select:^BOOL(Repetition_FigureLabel *obj) {
        return [obj.type isEqualToString:RepetitionFigureLabelTypeLearning];
    }];
    NSArray *reviewing = [questions bk_select:^BOOL(Repetition_FigureLabel *obj) {
        return [obj.type isEqualToString:RepetitionFigureLabelTypeReviewing];
    }];
    DDLogDebug(@"Total questions: %ld, new: %ld, learning: %ld, reviewing: %ld", (unsigned long)questions.count, (unsigned long)new.count, (unsigned long)learning.count, (unsigned long)reviewing.count);
}

- (void)repetitionShowStatusOverlay:(BOOL)finished {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"SpacedRepetition" bundle:nil];
    RepetitionTrainingInfoOverlayViewController *ctrl = [s instantiateViewControllerWithIdentifier:@"RepetitionTrainingInfoOverlayViewController"];
    
    NSTimeInterval duration = _currentTraining.laststart ? -[_currentTraining.laststart timeIntervalSinceNow] : 0;
    if (_currentTraining.duration) {
        duration += _currentTraining.duration.doubleValue;
    }
    double minutes = round(duration / 60.);
    
    NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *remainingLabels = [self repetitionLabelsByType];
    

    NSArray<Repetition_FigureLabel *> *doneLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"active == nil && lastscheduled > %@", _currentTraining.start] inContext:_managedObjectContext];

    if (finished) {
        NSString *body = [NSString stringWithFormat:NSLocalizedString(@"Congratulations, you have learned %ld structures in %d minutes.", nil),
                          (unsigned long)doneLabels.count,
                          (int)minutes];
        
        [ctrl bindTitle:NSLocalizedString(@"Finished training for today", nil) subTitle:NSLocalizedString(@"You have learned all remaining structures for today.", nil) body:body doneButtonLabel:NSLocalizedString(@"Done", nil)];
        [ctrl setOnFinish:^(RepetitionTrainingInfoOverlayViewController * _Nonnull sender, BOOL cancel) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self backToList:self];
        }];
    } else {
        NSString *body = [NSString stringWithFormat:NSLocalizedString(@"You have learned %ld structures in %d minutes. There are still %ld structures remaining today.", nil),
                          (unsigned long)doneLabels.count,
                          (int)minutes,
                          (unsigned long)remainingLabels[RepetitionFigureLabelTypeAll].count];
        
        [ctrl bindTitle:NSLocalizedString(@"Pause Training", nil) subTitle:@"" body:body doneButtonLabel:NSLocalizedString(@"Pause", nil)];
        [ctrl setOnFinish:^(RepetitionTrainingInfoOverlayViewController * _Nonnull sender, BOOL cancel) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if (!cancel) {
                [self backToList:self];
            } else {
                _pausedTraining = NO;
                [self.sobNavigationViewController updateNavigationButtonItems:self];
            }
        }];
    }
    
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)repetitionFinishTraining {
    [self pauseTrainingDuration];
    _currentTraining.inprogress = [NSNumber numberWithBool:NO];
    _currentTraining.end = [[NSDate alloc] init];
    [_managedObjectContext save:nil];

    [self repetitionShowStatusOverlay:YES];
}

@end
