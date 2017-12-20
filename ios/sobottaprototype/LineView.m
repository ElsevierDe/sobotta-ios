//
//  LineView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "LineView.h"
#import "HomescreenViewController.h"
#import "HumanOverlay.h"

@implementation LineView

- (id)initWithFrame:(CGRect)frame andViewController:(HomescreenViewController*)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.annotations = [NSMutableArray array];
        self.controller = controller;
        self.backgroundColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0];
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    float value = 0.45f;
    CGFloat lineColor[4] = {value, value, value, 1.0f};
    CGFloat whiteLineColor[4] = {1.f, 1.f, 1.f, .8f};
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColor(c, lineColor);
    CGContextSetLineWidth(c, 1);

    
    for (SimpleAnnotation *a in _annotations) {
        if (a.hidden) {
            continue;
        }
        CGPoint tmp = a.target;
        CGPoint new = [self convertPoint:tmp fromView:self.controller.imageView];
        
        CGPoint origin = a.image.frame.origin;
        origin.x += a.hook.x;
        origin.y += a.hook.y;
//        origin = [self convertPoint:origin fromView:a.image.superview];
        
        DDLogVerbose(@"origin for %@: %@ -- converted: %@", a.image.label.text, NSStringFromCGPoint(a.image.frame.origin), NSStringFromCGPoint(origin));
//        origin = [self convertPoint:origin fromView:self.controller.scrollWrapper];
        float firstx = origin.x+(a.isRight?-50:50);
        
        BOOL hide = NO;
        if (a.isRight && firstx < new.x) {
            hide = YES;
        } else if (!a.isRight && firstx > new.x) {
            hide = YES;
        }
        
//        if (new.y > self.frame.size.height || new.y < 0 || origin.y > self.frame.size.height || origin.y < 0) {
//            hide = YES;
//        }
        /*
        if (hide) {
            if (!a.hidden) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [a.image setAlpha:0];
                [UIView commitAnimations];
            }
        } else {
            if (a.hidden) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [a.image setAlpha:1];
                [UIView commitAnimations];
            }
        }
        a.hidden = hide;
         */
        
        if (!hide) {
            CGContextBeginPath(c);
            CGContextSetStrokeColor(c, whiteLineColor);
            CGContextMoveToPoint(c, origin.x, origin.y+1);
            CGContextAddLineToPoint(c, firstx, origin.y+1);
            CGContextAddLineToPoint(c, new.x, new.y+1);
            CGContextStrokePath(c);

            CGContextBeginPath(c);
            CGContextSetStrokeColor(c, lineColor);
            CGContextMoveToPoint(c, origin.x, origin.y);
            CGContextAddLineToPoint(c, firstx, origin.y);
            CGContextAddLineToPoint(c, new.x, new.y);
            CGContextStrokePath(c);

        
        
        }
    }
//    //CGContextMoveToPoint(c, 5.0f, 5.0f);
//    CGPoint tmp = CGPointMake(1024, 323);
//    CGPoint new = [self convertPoint:tmp fromView:self.controller.imageView];
//    NSLog(@"converted %f %f to %f %f", tmp.x, tmp.y, new.x, new.y);
//    CGContextAddLineToPoint(c, new.x, new.y);

    
    
    CGContextStrokePath(c);
    

}


@end
