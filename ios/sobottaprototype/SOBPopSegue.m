//
//  SOBPopSegue.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SOBPopSegue.h"

@implementation SOBPopSegue

- (void)perform {
    UINavigationController *navigationController = [[self sourceViewController] navigationController];
    
    
    [UIView transitionWithView:navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [navigationController popViewControllerAnimated:NO];
//        [navigationController pushViewController:[self destinationViewController] animated:NO];
    } completion:^(BOOL finished) {
        
    }];

}

@end
