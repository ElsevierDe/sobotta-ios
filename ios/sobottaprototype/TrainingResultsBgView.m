//
//  TrainingResultsBgView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 13/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "TrainingResultsBgView.h"

@interface TrainingResultsBgView ()

@property struct CGSize lastSize;
@property UIImage *bgImage;

@end

@implementation TrainingResultsBgView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _lastSize = CGSizeZero;
        NSLog(@"init with coder");
        //        [UIColor alloc] initWithPatternImage:
        //        _bgImage = [[UIImage imageNamed:@"trainingresults-row-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        if (IS_PHONE) {
            _bgImage = [[UIImage imageNamed:@"trainingresults-row-iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        } else {
            _bgImage = [[UIImage imageNamed:@"trainingresults-row-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    struct CGSize newSize = self.frame.size;
    
    if (CGSizeEqualToSize(_lastSize, newSize)) {
        DDLogVerbose(@"Size did not change. nothing to do.");
        return;
    }
    DDLogVerbose(@"Needs bg image redraw %@", NSStringFromCGSize(newSize));
    
    _lastSize = newSize;
    
    UIGraphicsBeginImageContext( newSize );
    [_bgImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    UIView view= UIView alloc] initWithFrame:CGRectMake(50, 100, 200, 100)];
    self.backgroundColor = [[UIColor alloc] initWithPatternImage:newImage];
//    [self setNeedsDisplay];
}


@end
