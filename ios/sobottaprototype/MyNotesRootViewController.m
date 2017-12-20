//
//  MyNotesRootViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MyNotesRootViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface MyNotesRootViewController ()

@end

@implementation MyNotesRootViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = NSLocalizedString(@"My Notes", nil);
    _leftView.layer.borderColor = [UIColor colorWithRed:183/255. green:185/255. blue:189/255. alpha:1.].CGColor;
    _leftView.layer.borderWidth = 1.;
//    _leftView.layer.shadowRadius = 10.;
//    _leftView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
//    _leftView.layer.shadowColor = [UIColor greenColor].CGColor;
//    _leftView.layer.shadowOpacity = 1.0;
    _leftView.layer.cornerRadius = 10.;
    _leftView.clipsToBounds = YES;
    
    
    _rightView.backgroundColor = [UIColor whiteColor];
    _rightView.layer.borderColor = _leftView.layer.borderColor;
    _rightView.layer.borderWidth = _leftView.layer.borderWidth;
    _rightView.layer.cornerRadius = 5.;
    _rightView.clipsToBounds = YES;
    _rightView.hidden = YES;


    UIViewController *uvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyNotesNavigator"];
    self.leftController = uvc;

    [self updateLeftView];
    [self updateRightView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateLeftView {
    if (_leftController) {
        _leftController.view.frame = _leftView.bounds;
        [_leftView addSubview:_leftController.view];
    }
}
- (void) updateRightView {
    if (_rightController) {
        _rightView.hidden = NO;
        _rightController.view.frame = _rightView.bounds;
        _rightController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _rightView.autoresizesSubviews = YES;
//        _rightController.view.hidden = YES;
        UIView *lastView = [_rightView.subviews lastObject];
//        [_rightView addSubview:_rightController.view];
//        [UIView animateWithDuration:0.2f animations:^{
//            _rightController.view.alpha = 1;
//        } completion:^(BOOL finished) {
//            
//        }];
        /*
        [UIView transitionFromView:lastView toView:_rightController.view duration:0.5 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
            
        }];
         */

        [UIView transitionWithView:_rightView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCurlDown
                        animations:^{
                            [_rightView addSubview:_rightController.view];
        } completion:^(BOOL finished) {
            if (lastView) {
                [lastView removeFromSuperview];
            }
        }];
    }
}

- (void)setLeftController:(UIViewController *)leftController {
    _leftController = leftController;
    
    // handle view controller hierarchy
    [self addChildViewController:_leftController];
    [_leftController didMoveToParentViewController:self];
    
    if ([self isViewLoaded]) {
        [self updateLeftView];
    }

}


- (void)setRightController:(UIViewController *)rightController {
    _rightController = rightController;
    
    // handle view controller hierarchy
    [self addChildViewController:_rightController];
    [_rightController didMoveToParentViewController:self];
    
    if ([self isViewLoaded]) {
        [self updateRightView];
    }
    
}



- (void)viewDidUnload {
    [self setLeftView:nil];
    [self setRightView:nil];
    [super viewDidUnload];
}
@end
