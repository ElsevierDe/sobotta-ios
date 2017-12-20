//
//  GridSizeChooserNavigationController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "GridSizeChooserNavigationController.h"

@interface GridSizeChooserNavigationController ()

@end

@implementation GridSizeChooserNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (void)setNavViewController:(SOBNavigationViewController *)navViewController {
    [[self.viewControllers objectAtIndex:0] setNavViewController:navViewController];
}

@end
