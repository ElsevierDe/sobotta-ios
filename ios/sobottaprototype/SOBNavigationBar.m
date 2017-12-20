//
//  SOBNavigationBar.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SOBNavigationBar.h"
#import "SOBButtonImage.h"

@implementation SOBNavigationBar


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
