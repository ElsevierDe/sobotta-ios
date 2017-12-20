//
//  UIViewController+Transitions.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Transitions)

- (void)expandView:(UIView *)sourceView toModalViewController:(UIViewController *)modalViewController;

- (void)dismissModalViewControllerToView:(UIView *)view;

@end
