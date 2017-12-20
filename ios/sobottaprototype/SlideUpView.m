//
//  SlideUpView.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 13.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SlideUpView.h"

@implementation SlideUpView {
	CAGradientLayer *gradient;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		gradient = [CAGradientLayer layer];
		gradient.frame = self.bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:246./256 green:129./256 blue:33./256 alpha:0.97] CGColor], (id)[[UIColor colorWithRed:220./256 green:115./256 blue:29./256 alpha:0.97] CGColor]];
        
		[self.layer insertSublayer:gradient atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
	gradient.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
