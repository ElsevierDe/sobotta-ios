//
//  ImageGridHeaderActionNavigationController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridHeaderActionNavigationController.h"
#import "BookmarksTableViewController.h"

@interface ImageGridHeaderActionNavigationController ()

@end

@implementation ImageGridHeaderActionNavigationController

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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationItem setHidesBackButton:YES animated:NO];
    
    if ([viewController isKindOfClass:[BookmarksTableViewController class]]) {
        ((BookmarksTableViewController *)viewController).allowBookmarkListEditing = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


@end
