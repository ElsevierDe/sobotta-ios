//
//  HomescreenSplitViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "HomescreenSplitViewController.h"

#import "MasterViewController.h"
#import "HomescreenViewController.h"

@interface HomescreenSplitViewController ()

@end

@implementation HomescreenSplitViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"HomescreenSplitViewController: init with coder.");
        NSLog(@"first: %@, last: %@", [self.viewControllers objectAtIndex:0], [self.viewControllers lastObject]);
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"HomescreenSplitViewController: view did load.");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationController *vc = [self.viewControllers objectAtIndex:0];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        MasterViewController *mvc = [vc.viewControllers lastObject];
        mvc.homescreen = [self.viewControllers lastObject];
    }
    
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



- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
//    NSLog(@"Hiding master view controller.");
//    HomescreenViewController* hvc = [self.viewControllers lastObject];
//    NSMutableArray *items = [hvc.toolbar.items mutableCopy];
//    [items insertObject:barButtonItem atIndex:0];
//    hvc.toolbar.items = items;
}

@end
