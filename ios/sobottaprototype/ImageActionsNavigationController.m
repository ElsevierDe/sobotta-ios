//
//  ImageActionsNavigationController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageActionsNavigationController.h"

@interface ImageActionsNavigationController ()

@end

@implementation ImageActionsNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"adding child view controller. %@", viewController);
    [viewController.navigationItem setHidesBackButton:YES animated:NO];
}
 */

@end
