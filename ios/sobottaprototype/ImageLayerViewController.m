//
//  ImageLayerViewController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 16.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageLayerViewController.h"

@interface ImageLayerViewController ()

@end

@implementation ImageLayerViewController {
}

@synthesize captionSwitch;
@synthesize viewModeControl;
@synthesize structureControl;
@synthesize otherSwitch;
@synthesize arterySwitch;
@synthesize veinSwitch;
@synthesize nerveSwitch;
@synthesize muscleSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.viewModeControl.apportionsSegmentWidthsByContent = YES;
    
    _lblLegend.text = NSLocalizedString(@"Legend", nil);
    
    _structureSegmentedControl.isAccessibilityElement = YES;
    _structureSegmentedControl.accessibilityIdentifier = @"Structure Selector";
    [_structureSegmentedControl setTitle:NSLocalizedString(@"Important", @"Structure selector") forSegmentAtIndex:0];
    [_structureSegmentedControl setTitle:NSLocalizedString(@"All", @"Structure selector") forSegmentAtIndex:1];
    
    _outlineSegmentedControl.isAccessibilityElement = YES;
    _outlineSegmentedControl.accessibilityIdentifier = @"Outline Selector";
    [_outlineSegmentedControl setTitle:NSLocalizedString(@"Pins", @"Outline selector") forSegmentAtIndex:0];
    [_outlineSegmentedControl setTitle:NSLocalizedString(@"Labels", @"Outline selector") forSegmentAtIndex:1];
    [_outlineSegmentedControl setTitle:NSLocalizedString(@"Image", @"Outline selector") forSegmentAtIndex:2];
    
    _lblArteries.text = NSLocalizedString(@"Arteries", @"Structure selector");
    _lblVeins.text = NSLocalizedString(@"Veins", @"Structure selector");
    _lblNerves.text = NSLocalizedString(@"Nerves", @"Structure selector");
    _lblMuscle.text = NSLocalizedString(@"Muscles", @"Structure selector");
    _lblOthers.text = NSLocalizedString(@"Others", @"Structure selector");
//    self.contentSizeForViewInPopover = CGSizeMake(320, 450);
    if (viewController) {
        [self setParentImageViewController:viewController];
    }
}

- (void)viewDidUnload
{
	[self setOtherSwitch:nil];
	[self setCaptionSwitch:nil];
	[self setViewModeControl:nil];
	[self setStructureControl:nil];
	[self setArterySwitch:nil];
	[self setVeinSwitch:nil];
	[self setNerveSwitch:nil];
	[self setMuscleSwitch:nil];
    [self setLblLegend:nil];
    [self setOutlineSegmentedControl:nil];
    [self setStructureSegmentedControl:nil];
    [self setLblArteries:nil];
    [self setLblVeins:nil];
    [self setLblNerves:nil];
    [self setLblMuscle:nil];
    [self setLblOthers:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setParentImageViewController:(UIViewController *)controller {
	KWLogDebug(@"[%@] Parent ViewController Set", self.class);
	viewController = (ImageViewController*)controller;
	
	// Get current settings of parent view and apply to Controls
	
	self.captionSwitch.on = viewController.displayCaption;
	self.viewModeControl.selectedSegmentIndex = viewController.viewMode;
	self.structureControl.selectedSegmentIndex = viewController.allStructures ? 1 : 0;
	self.arterySwitch.on = viewController.displayArtery;
	self.veinSwitch.on = viewController.displayVein;
	self.nerveSwitch.on = viewController.displayNerve;
	self.muscleSwitch.on = viewController.displayMuscle;
	self.otherSwitch.on = viewController.displayOther;
    [self updateViewModeButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 550);
}

#pragma mark Settings

- (IBAction)displayCaptionChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"caption" withAction:self.captionSwitch.on ? @"Show" : @"Hide" withLabel:@"Caption from popover" withValue:0];
	viewController.displayCaption = self.captionSwitch.on;
}

- (IBAction)viewModeChange:(id)sender {
	viewController.viewMode = self.viewModeControl.selectedSegmentIndex;
    [self updateViewModeButtons];
}

- (void) updateViewModeButtons {
	if(self.viewModeControl.selectedSegmentIndex == 2 || !viewController.isFigureInteractive) {
		[self configureSwitched:NO];
		self.structureControl.enabled = NO;
	}
	else {
		[self configureSwitched:YES];
		self.structureControl.enabled = YES;
	}
    if (!viewController.isFigureInteractive) {
        self.outlineSegmentedControl.enabled = NO;
    } else {
        self.outlineSegmentedControl.enabled = YES;
    }
}

- (void)configureSwitched:(BOOL)enabled {
	self.otherSwitch.enabled = enabled;
	self.arterySwitch.enabled = enabled;
	self.veinSwitch.enabled = enabled;
	self.nerveSwitch.enabled = enabled;
	self.muscleSwitch.enabled = enabled;
}

- (IBAction)displayStructuresChange:(id)sender {
	UISegmentedControl *ctrl = sender;
	if(ctrl.selectedSegmentIndex == 0){
		[self configureSwitched:NO];
		viewController.allStructures = NO;
        [[DatabaseController Current] trackEventWithCategory:@"structuredisplay" withAction:@"changed" withLabel:@"important" withValue:nil];
	}
	else {
		[self configureSwitched:YES];
		viewController.allStructures = YES;
        [[DatabaseController Current] trackEventWithCategory:@"structuredisplay" withAction:@"changed" withLabel:@"all" withValue:nil];
	}
	[self.tableView reloadData];
}

- (IBAction)displayArteryChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"structuretype" withAction:self.arterySwitch.on ? @"On" : @"Off" withLabel:@"artery" withValue:0];
	viewController.displayArtery = self.arterySwitch.on;
}

- (IBAction)displayVeinChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"structuretype" withAction:self.veinSwitch.on ? @"On" : @"Off" withLabel:@"vein" withValue:0];
	viewController.displayVein = self.veinSwitch.on;
}

- (IBAction)displayNerveChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"structuretype" withAction:self.nerveSwitch.on ? @"On" : @"Off" withLabel:@"nerve" withValue:0];
	viewController.displayNerve = self.nerveSwitch.on;
}

- (IBAction)displayMuscleChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"structuretype" withAction:self.muscleSwitch.on ? @"On" : @"Off" withLabel:@"muscle" withValue:0];
	viewController.displayMuscle = self.muscleSwitch.on;
}

- (IBAction)displayOtherChange:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"structuretype" withAction:self.otherSwitch.on ? @"On" : @"Off" withLabel:@"other" withValue:0];
	KWLogDebug(@"[%@] displayOther changed",self.class);
	viewController.displayOther = self.otherSwitch.on;
}

#pragma mark Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (IS_PHONE) {
        return 3;
    }
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section+1)
    {
        case 0:
            return NSLocalizedString(@"General", @"Layer section");
        case 1:
            return NSLocalizedString(@"Outline", @"Layer section");
        case 2:
            return NSLocalizedString(@"Structures", @"Layer section");
        case 3:
            return NSLocalizedString(@"Select Structures", @"Layer section");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section < 2) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        //    cell.backgroundColor = [UIColor clearColor];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
    }
    return cell;
}

@end