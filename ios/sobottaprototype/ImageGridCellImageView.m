//
//  ImageGridCellImageView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridCellImageView.h"

@implementation ImageGridCellImageView



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"draw rect.");
}
 

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSLog(@"draw Layer ...");
    
        // Drawing lines with a white stroke color
        CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(ctx, 2.0);
    
        CGContextMoveToPoint(ctx, 10.0, 30.0);
        CGContextAddLineToPoint(ctx, 310.0, 30.0);
    
    
    
        CGContextStrokePath(ctx);

}


@end
