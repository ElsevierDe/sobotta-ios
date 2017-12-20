//
//  ContestView.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/17/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contest100Provider.h"

@interface ContestView : UIView {
    Contest100Provider *_contest;
}

- (id) initForView:(UIView *)view;

@end
