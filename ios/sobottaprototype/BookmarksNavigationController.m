//
//  BookmarksNavigationControllerViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "BookmarksNavigationController.h"

@interface BookmarksNavigationController ()

@end

@implementation BookmarksNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
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
//
//- (CGSize)contentSizeForViewInPopover {
//    return CGSizeMake(320, 320);
//}


@end
