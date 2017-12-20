//
//  MasterViewNavigationController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MasterViewNavigationController.h"
#import "SOBButtonImage.h"

@interface MasterViewNavigationController ()

@end

@implementation MasterViewNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.delegate = self;
//    self.view.backgroundColor = [UIColor yellowColor];
//    self.view.backgroundColor = [UIColor colorWithRed:6./256. green:113./256. blue:171./256. alpha:1];
    self.view.backgroundColor = [UIColor greenColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}


//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    
//    if ([self.viewControllers count] > 1) {
//        NSString* title = [[self.viewControllers objectAtIndex:[self.viewControllers count]-2] title];
//        if (!title) {
//            title = @"Back";
//        }
//        NSMutableArray *leftButtons = [NSMutableArray array];
//        
//        
//        SOBButtonImage *btn = [[SOBButtonImage alloc] initButtonOfType:BARBACKBUTTON withImage:nil andText:title];
//        [btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [leftButtons addObject:[[UIBarButtonItem alloc] initWithCustomView:btn]];
//        viewController.navigationItem.leftBarButtonItems = leftButtons;
//    }
//
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
//
//- (void) backPressed: (id) sender {
//    [self popViewControllerAnimated:YES];
//}

@end
