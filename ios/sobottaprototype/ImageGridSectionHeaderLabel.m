//
//  ImageGridSectionHeaderLabel.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridSectionHeaderLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageGridSectionHeaderLabel

#pragma mark - Designated Initializer

- (id)initWithString:(NSString *)string
{
    if ((self = [super initWithFrame:CGRectZero])) {
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont boldSystemFontOfSize:16.f];
        self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
        self.shadowOffset = CGSizeMake(0.f, 1.f);
        self.textAlignment = UITextAlignmentLeft;
        self.text = string;
        self.backgroundColor = [UIColor colorWithRed:55/255. green:106/255. blue:137/255. alpha:1];
        
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-1.f, self.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [self.layer addSublayer:bottomBorder];
    }
    
    return self;
}

#pragma mark - Drawing
/*
- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.f, 12.f, 0.f, 0.f);
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
*/
@end
