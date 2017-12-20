//
//  VerticalAlignedLabel.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface VerticalAlignedLabel : UILabel {

}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;


@end
