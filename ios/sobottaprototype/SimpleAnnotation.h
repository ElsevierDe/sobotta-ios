//
//  SimpleAnnotation.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HumanOverlay;

@interface SimpleAnnotation : NSObject

/**
 * target point in the image we draw a line to.
 */
@property (nonatomic) CGPoint target;
/**
 * location of the image annotation
 */
@property (nonatomic) CGPoint point;
@property (strong, nonatomic) HumanOverlay *image;
@property (nonatomic) BOOL isRight;

// relative position where the line should lead to.
@property (readonly) CGPoint hook;
@property (nonatomic) BOOL hidden;

@property (nonatomic) CGPoint zoomTo;
@property (nonatomic) float minScale;
@property (nonatomic) float maxScale;
@property (nonatomic) int chapterId;


- (SimpleAnnotation *)initWithTarget:(CGPoint)target at:(CGPoint)point image:(HumanOverlay *)image onRight:(BOOL) isRight;

@end
