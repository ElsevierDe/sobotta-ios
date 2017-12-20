//
//  ImageActionsSegue.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageActionsSegue.h"

#import "ImageActionsViewController.h"


@implementation ImageActionsSegue


- (void)perform
{
    // add your own animation code here
    NSLog(@"perform custom segue.");
    
//    UIPopoverController* popover = [[self sourceViewController] parentViewController];
    
    ImageActionsViewController *tmp = self.sourceViewController;
    
//    [tmp.sobParentController.actionsPopover setContentViewController:self.destinationViewController animated:NO];
//    [UIView transitionFromView:[self.sourceViewController view] toView:[self.destinationViewController view] duration:0.65f options:UIViewAnimationOptionTransitionCrossDissolve completion:
//     ^(BOOL finished) {
//         tmp.sobParentController.actionsPopover.contentViewController = self.destinationViewController;
//     }];
    
//    [tmp.sobParentController.actionsPopover setContentViewController:self.destinationViewController animated:YES];
    
    UIPopoverController *popover = tmp.sobParentController.actionsPopover;
//    [popover dismissPopoverAnimated:YES];
    
//    [tmp.sobParentController showActionsPopover:self.destinationViewController];
    
//    [popover setPopoverContentSize:CGSizeMake(300, 200) animated:YES];
    
    popover.contentViewController = self.destinationViewController;
    popover.popoverContentSize = [self.destinationViewController contentSizeForViewInPopover];
    
//    [[self sourceViewController] presentViewController:[self destinationViewController] animated:YES completion:nil];
                                                        //]:[self destinationViewController] animated:NO];
}

@end
