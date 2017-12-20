//
//  HomescreenScrollView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "HomescreenScrollView.h"

#define ZOOM_VIEW_TAG 100


@implementation HomescreenScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
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
