//
//  HumanOverlay.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/15/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "HumanOverlay.h"

#import <QuartzCore/QuartzCore.h>

#import "HomescreenViewController.h"

@implementation HumanOverlay
@synthesize imageView;
@synthesize label;

#define kZoomedInScale UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.42 : 1

-(id)initWithImage:(UIImage *)image andLabel:(NSString *)labelText {
    if ((self = [super init])){
        UIView *subview = [[[NSBundle mainBundle] loadNibNamed:@"HumanOverlay" owner:self options:nil] objectAtIndex:0];
//        NSLog(@"subview size: %f %f", subview.frame.size.width, subview.frame.size.height);
        self.frame = subview.frame;
        [self addSubview:subview];
        
        self.imageView.image = image;
        self.label.text = labelText;
        self.label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"human-label-bgimage"]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];//[UIFont boldSystemFontOfSize:10];
        }
        
//        NSLog(@"Okay, loaded it.. setting border? - our size: %f %f", self.frame.size.width, self.frame.size.height);
        self.borderColor = [UIColor colorWithRed:137/255. green:138/255. blue:140/255. alpha:1];
        CGColorRef cgcolor = self.borderColor.CGColor;
        self.layer.borderColor = [[SOThemeManager sharedTheme] cellBorderColor].CGColor ;
        self.layer.borderWidth = 1.;
        self.layer.cornerRadius = [[SOThemeManager sharedTheme] cellBorderRadius];
        
        self.imageView.layer.borderColor = cgcolor;
        self.imageView.layer.borderWidth = 1.;
        self.layer.masksToBounds = YES;
        [self layoutSubviews];
    }
    return self;
}


- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (IBAction)onTap:(id)sender {
    NSLog(@"onTap");
    if (self.annotation.zoomTo.x && self.annotation.zoomTo.y) {
        CGRect tmp = [self zoomRectForScrollView:self.controller.scrollView withScale:kZoomedInScale withCenter:self.annotation.zoomTo];
        [self.controller.scrollView zoomToRect:tmp animated:YES];
    } else if (self.annotation.chapterId) {
        [self.controller openCategoriesGallery:self.annotation.chapterId currentViewController:self.controller];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    //UITouch *touch = [event.allTouches anyObject];
    //touchStart = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    UITouch *touch = [event.allTouches anyObject];
    CGPoint now = [touch locationInView:_controller.scrollView];
    //_annotation.point.x = touchStart.x - now.x;
    //_annotation.point.y = touchStart.x - now.x;
    //self.frame = CGRectMake(now.x-100, now.y-100, self.frame.size.width, self.frame.size.height);
    [self convertPoint:now toView:self.superview];
    _annotation.point = CGPointMake(_annotation.point.x, now.y-100);
    //[self.superview setNeedsDisplay];
    [_controller repositionAnnotations];
    [_controller.view setNeedsDisplay];
    NSLog(@"y: %f", now.y);
     */
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.layer.borderColor = _borderColor.CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawing border?");
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 1);
    CGContextSetRGBStrokeColor(contextRef, 255.0, 255.0, 255.0, 1.0);
    CGContextStrokeRect(contextRef, rect);
}
 */



@end
