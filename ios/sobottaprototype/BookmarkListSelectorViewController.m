//
//  BookmarkListSelectorViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "BookmarkListSelectorViewController.h"

@interface BookmarkListSelectorViewController ()

@end

@implementation BookmarkListSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.contentSizeForViewInPopover = CGSizeMake(300, 400);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
