//
//  HumanOverlay.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/15/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleAnnotation.h"

@class HomescreenViewController;

@interface HumanOverlay : UIView {
    CGPoint touchStart;
}


-(id)initWithImage:(UIImage *)image andLabel:(NSString *)labelText;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIColor *borderColor;
@property (weak, nonatomic) SimpleAnnotation *annotation;
@property (weak, nonatomic) HomescreenViewController *controller;

@end
