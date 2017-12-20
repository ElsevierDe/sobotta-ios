//
//  TrainingResultsCell.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "TrainingResultsCell.h"

@interface TrainingResultsCell ()

@property struct CGSize lastSize;

@end

@implementation TrainingResultsCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        _lastSize = CGSizeZero;
//        NSLog(@"init with coder");
////        [UIColor alloc] initWithPatternImage:
////        _bgImage = [[UIImage imageNamed:@"trainingresults-row-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//        if (IS_PHONE) {
//            _bgImage = [[UIImage imageNamed:@"trainingresults-row-iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//        } else {
//            _bgImage = [[UIImage imageNamed:@"trainingresults-row-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.cellWrapper.backgroundColor = [UIColor clearColor];
//    self.cellWrapper.backgroundColor = [[UIColor alloc] initWithPatternImage:_bgImage];
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    struct CGSize newSize = _cellWrapper.frame.size;
//    
//    if (CGSizeEqualToSize(_lastSize, newSize)) {
//        DDLogVerbose(@"Size did not change. nothing to do.");
//        return;
//    }
//    DDLogVerbose(@"Needs bg image redraw %@", NSStringFromCGSize(newSize));
//    
//    _lastSize = newSize;
//    
//    UIGraphicsBeginImageContext( newSize );
//    [_bgImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
////    UIView view= UIView alloc] initWithFrame:CGRectMake(50, 100, 200, 100)];
//    _cellWrapper.backgroundColor = [[UIColor alloc] initWithPatternImage:newImage];
//    [self setNeedsDisplay];
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
