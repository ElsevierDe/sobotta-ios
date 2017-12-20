//
//  SpacedRepetitionCardOverlay.m
//  sobottaprototype
//
//  Created by Herbert Poul on 03/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "SpacedRepetitionCardOverlay.h"

@implementation SpacedRepetitionCardOverlay

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 0.5;
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

@end
