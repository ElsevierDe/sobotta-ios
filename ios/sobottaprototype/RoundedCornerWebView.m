//
//  RoundedCornerWebView.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 13.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "RoundedCornerWebView.h"

@implementation RoundedCornerWebView {
	UIBezierPath *maskPath;
	CAShapeLayer *maskLayer;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
//	[self updatePath];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

-(void)layoutSubviews {
//	[self updatePath];
}

-(void)updatePath {
	maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
									 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
										   cornerRadii:CGSizeMake(cCaptionRoundedCornerWidth, cCaptionRoundedCornerHeight)];
	
	// Create the shape layer and set its path
	maskLayer = [CAShapeLayer layer];
	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	
	// Set the newly created shape layer as the mask for the image view's layer
	self.layer.mask = maskLayer;
}

@end
