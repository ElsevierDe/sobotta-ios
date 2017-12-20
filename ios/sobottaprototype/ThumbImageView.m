//
//  ThumbImageView.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 29.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ThumbImageView.h"

float distanceBetweenPoints(CGPoint a, CGPoint b);

@implementation ThumbImageView
@synthesize delegate;
@synthesize imageIndex;
@synthesize home;
@synthesize touchLocation;

- (id)init {
	self = [super init];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
    }
    return self;
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];
    if ([delegate respondsToSelector:@selector(thumbImageViewStartedTracking:)])
        [delegate thumbImageViewStartedTracking:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // we want to establish a minimum distance that the touch has to move before it counts as dragging,
    // so that the slight movement involved in a tap doesn't cause the frame to move.
    
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    
    // if we're already dragging, move our frame
    if (dragging) {
        float deltaX = newTouchLocation.x - touchLocation.x;
        float deltaY = newTouchLocation.y - touchLocation.y;
        [self moveByOffset:CGPointMake(deltaX, deltaY)];
    }
    
    // if we're not dragging yet, check if we've moved far enough from the initial point to start
    else if (distanceBetweenPoints(touchLocation, newTouchLocation) > DRAG_THRESHOLD) {
        touchLocation = newTouchLocation;
        dragging = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        [self goHome];
        dragging = NO;
    } else if ([[touches anyObject] tapCount] == 1) {
        if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
            [delegate thumbImageViewWasTapped:self];
    }
    
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)])
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self goHome];
    dragging = NO;
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)])
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)goHome {
    // distance is in pixels
    float distanceFromHome = distanceBetweenPoints([self frame].origin, [self home].origin);
    // duration is in seconds, so each additional pixel adds only 1/1000th of a second.
    float animationDuration = 0.1 + distanceFromHome * 0.001;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self setFrame:[self home]];
    [UIView commitAnimations];
}

- (void)moveByOffset:(CGPoint)offset {
    CGRect frame = [self frame];
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    [self setFrame:frame];
    if ([delegate respondsToSelector:@selector(thumbImageViewMoved:)])
        [delegate thumbImageViewMoved:self];
}
 */

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] tapCount] == 1) {
        if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
            [delegate thumbImageViewWasTapped:self];
    }
}

@end

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}
