//
//  ImageGridCellImageViewOverlay.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridCellImageViewOverlay.h"

@implementation ImageGridCellImageViewOverlay



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

- (void)setSpots:(NSArray *)spots {
    _spots = spots;
    [self setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    // Drawing lines with a white stroke color
    CGContextSetRGBStrokeColor(ctx, 1.0, .0, .0, 1.0);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(ctx, 2.0);
    
//    CGContextMoveToPoint(ctx, 10.0, 30.0);
//    CGContextAddLineToPoint(ctx, 310.0, 30.0);
    
    
    float factor = self.frame.size.width / 1000.;
    float radius = 5;
    
    for (NSValue * val in _spots) {
        CGPoint p = val.CGPointValue;
        //                    CGContextMoveToPoint(context, 10.0, 30.0);
        //                    CGContextAddLineToPoint(context, 310.0, 30.0);
        float x= p.x*factor;
        float y = p.y*factor;
        CGContextMoveToPoint(ctx, x+radius, y);
        CGContextAddArc(ctx, x, y, radius, 0, 2*M_PI, 1);
//        NSLog(@"draw at %f,%f", x,y);
        
        //                        NSLog(@"drawing image.");
    }

    
    
    
    CGContextStrokePath(ctx);

}

@end
