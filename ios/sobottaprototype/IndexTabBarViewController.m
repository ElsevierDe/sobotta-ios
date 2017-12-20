//
//  IndexTabBarViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/3/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "IndexTabBarViewController.h"

@interface IndexTabBarViewController ()

@end

@implementation IndexTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self.viewControllers objectAtIndex:0] setTitle: NSLocalizedString(@"Figures Index", nil)];
    [[self.viewControllers objectAtIndex:1] setTitle: NSLocalizedString(@"A-Z", nil)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}



@end
