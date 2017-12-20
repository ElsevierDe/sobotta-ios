//
//  GridSizeChooserViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "GridSizeChooserViewController.h"
#import "ImageGridViewController.h"

@interface GridSizeChooserViewController ()

@end

@implementation GridSizeChooserViewController
@synthesize gridSize;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    ImageGridViewController *tmp = [self.navViewController imageGridViewController:NO];
    gridSize.selectedSegmentIndex = tmp.currentGridSize;
    self.title = NSLocalizedString(@"Layout", @"Layout of grid view.");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void)viewDidUnload
{
    [self setGridSize:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 54);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)changedGridSize:(id)sender {
    [[DatabaseController Current] trackEventWithCategory:@"gridsize" withAction:@"changed" withLabel:[NSString stringWithFormat:@"to %ld", gridSize.selectedSegmentIndex] withValue:0];
    ImageGridViewController *tmp = [self.navViewController imageGridViewController:NO];
    tmp.currentGridSize = gridSize.selectedSegmentIndex;
}

@end
