//
//  CrazyButton.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "CrazyButton.h"
#import <QuartzCore/QuartzCore.h>


@implementation CrazyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
    }
    return self;
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
