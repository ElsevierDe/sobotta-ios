//
//  SOBSimpleSegue.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SOBSimpleSegue.h"

@implementation SOBSimpleSegue

- (void)perform {
    NSLog(@"SOBSimpleSegue - perform");
    UINavigationController *navigationController = [[self sourceViewController] navigationController];
    /*
    [UIView animateWithDuration:1. animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionCrossDissolve forView:navigationController.view cache:NO];
        [navigationController pushViewController:[self destinationViewController] animated:NO];
         }];
     */
//    [[self destinationViewController] view];
    [UIView transitionWithView:navigationController.view duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [navigationController pushViewController:[self destinationViewController] animated:NO];
    } completion:^(BOOL finished) {
        
    }];
}

@end
