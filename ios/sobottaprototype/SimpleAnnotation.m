//
//  SimpleAnnotation.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SimpleAnnotation.h"
#import "HumanOverlay.h"
//#import <QuartzCore/QuartzCore.h>

@implementation SimpleAnnotation

- (SimpleAnnotation *)initWithTarget:(CGPoint)target at:(CGPoint)point image:(HumanOverlay *)image onRight:(BOOL) isRight {
    self = [super init];
    if (self) {
        self.target = target;
        self.image = image;
        self.isRight = isRight;
        self.hidden = NO;
        self.point = point;
        
        [self.image setAlpha:0];
        _hidden = YES;
    }
    return self;
}

- (CGPoint)hook {
    CGSize size = _image.imageView.frame.size;
    return CGPointMake(_isRight ? 0 : size.width, size.height / 2.);
}

- (void)setHidden:(BOOL)hidden {
    if (_hidden != hidden) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [self.image setAlpha:hidden ? 0 : 1];
        [UIView commitAnimations];
        _hidden = hidden;
    }
}

@end
