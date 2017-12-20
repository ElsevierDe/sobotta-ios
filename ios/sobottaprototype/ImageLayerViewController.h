//
//  ImageLayerViewController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 16.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAMapView.h"
#import "ImageViewController.h"


@interface ImageLayerViewController : UITableViewController {
	@private
	ImageViewController* viewController;
}



- (IBAction)displayCaptionChange:(id)sender;
- (IBAction)viewModeChange:(id)sender;
- (IBAction)displayStructuresChange:(id)sender;
- (IBAction)displayArteryChange:(id)sender;
- (IBAction)displayVeinChange:(id)sender;
- (IBAction)displayNerveChange:(id)sender;
- (IBAction)displayMuscleChange:(id)sender;
- (IBAction)displayOtherChange:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *captionSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *viewModeControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *structureControl;
@property (strong, nonatomic) IBOutlet UISwitch *otherSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *arterySwitch;
@property (strong, nonatomic) IBOutlet UISwitch *veinSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *nerveSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *muscleSwitch;


@property (weak, nonatomic) IBOutlet UILabel *lblLegend;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outlineSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *structureSegmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *lblArteries;
@property (weak, nonatomic) IBOutlet UILabel *lblVeins;
@property (weak, nonatomic) IBOutlet UILabel *lblNerves;
@property (weak, nonatomic) IBOutlet UILabel *lblMuscle;
@property (weak, nonatomic) IBOutlet UILabel *lblOthers;



- (void) setParentImageViewController:(UIViewController*) controller;

@end
