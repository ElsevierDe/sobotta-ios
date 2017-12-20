//
//  ContestView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/17/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ContestView.h"

@implementation ContestView


- (id) initForView:(UIView *)view {
    self = [super initWithFrame:view.bounds];
    if (self) {
        _contest = [Contest100Provider defaultProvider];
        UIView *bgView = self;
        bgView.opaque = NO;
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        
        UIView *subview = [[[NSBundle mainBundle] loadNibNamed:(IS_PHONE ? @"ContestView-iphone" : @"ContestView") owner:self options:nil] objectAtIndex:0];
        
//        UIImage *image = [UIImage imageNamed:@"contest-bgimage"];
        UIImage *image = [_contest dialogImage];
        if (!image || ![image CGImage]) {
            NSLog(@"Invalid image?!");
            return nil;
        }
//        [UIImage imageWithContentsOfFile:<#(NSString *)#>]
        subview.frame = CGRectMake(
                                   self.frame.size.width / 2 - image.size.width / 2,
                                   self.frame.size.height / 2 - image.size.height / 2,
                                   image.size.width,
                                   image.size.height);
        NSLog(@"frame: %f,%f,%f,%f --- self frame: %@", subview.frame.origin.x, subview.frame.origin.y, subview.frame.size.width, subview.frame.size.height, NSStringFromCGRect(view.frame));
        
        subview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        subview.backgroundColor = [UIColor colorWithPatternImage:image];
        
        [self addSubview:subview];
    }
    return self;
}

- (void) dismiss {
    [self removeFromSuperview];
}
- (IBAction)pressedMaybeLater:(id)sender {
    [self dismiss];
}
- (IBAction)pressedParticipate:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_contest infoUrl]]];
    [self dismiss];
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
