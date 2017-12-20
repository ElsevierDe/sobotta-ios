//
//  MyNotesBackgroundLinesView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/25/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MyNotesBackgroundLinesView.h"

@implementation MyNotesBackgroundLinesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [SOThemeManager 
//        self.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:19];
        self.font = [UIFont systemFontOfSize:19];
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	
    //Get the current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Set the line color and width
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:196/255.f green:228/255.f blue:240/255.f alpha:1.f].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    //Start a new Path
    CGContextBeginPath(context);
	
    //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
    NSUInteger numberOfLines = (self.bounds.size.height) / self.font.lineHeight + 1;
	
    //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
    CGFloat baselineOffset = -1.5f;
	
    //iterate over numberOfLines and draw each line
    for (int x = 0; x < numberOfLines; x++) {
        //0.5f offset lines up line with pixel boundary
        CGContextMoveToPoint(context, self.bounds.origin.x, self.font.lineHeight*x + 0.5f + baselineOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.font.lineHeight*x + 0.5f + baselineOffset);
    }
	
    //Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
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
