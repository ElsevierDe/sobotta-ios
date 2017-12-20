//
//  MoreNavigationController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MoreNavigationController.h"

@interface MoreNavigationController ()

@end

@implementation MoreNavigationController

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 640);
}

@end
