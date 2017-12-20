//
//  CaptionView.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 13.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "CaptionView.h"

@implementation CaptionView{
	UIBezierPath *maskPath;
	CAShapeLayer *maskLayer;
	CAGradientLayer *gradient;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
//	[self updatePath];
	
//    self.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:107.0/255.0 blue:161.0/255.0 alpha:1.0];
    self.layer.cornerRadius = 5;
	
//	gradient = [CAGradientLayer layer];
//	gradient.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 1500);
//	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:4.0/255.0 green:107.0/255.0 blue:161.0/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:1.0/255.0 green:69.0/255.0 blue:127.0/255.0 alpha:1.0] CGColor], nil];
//	[self.layer insertSublayer:gradient atIndex:0];
	
}

//-(void)layoutSubviews {
//    [super layoutSubviews];
//    NSLog(@"Layout Subviews %f", self.bounds.size.height);
//    UIView *subview = [self.subviews objectAtIndex:1];
//    subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y, subview.frame.size.width, MAX(self.bounds.size.height - subview.frame.origin.x - 40, 0));
//}

-(void)updatePath {
	maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, 1500)
									 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
										   cornerRadii:CGSizeMake(cCaptionRoundedCornerWidth, cCaptionRoundedCornerHeight)];
	
	// Create the shape layer and set its path
	maskLayer = [CAShapeLayer layer];
	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	
	// Set the newly created shape layer as the mask for the image view's layer
	self.layer.mask = maskLayer;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

@end
