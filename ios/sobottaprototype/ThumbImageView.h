//
//  ThumbImageView.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 29.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThumbImageViewDelegate;


@interface ThumbImageView : UIImageView {
    __unsafe_unretained id <ThumbImageViewDelegate> delegate;
    NSUInteger imageIndex;
    
    /* ThumbImageViews have a "home," which is their location in the containing scroll view. Keeping this distinct */
    /* from their frame makes it easier to handle dragging and reordering them. We can change their relative       */
    /* positions by changing their homes, without having to worry about whether they have currently been dragged   */
    /* somewhere else. Also, we don't lose track of where they belong while they are being moved.                  */
    CGRect home;
    
    BOOL dragging;
    CGPoint touchLocation; // Location of touch in own coordinates (stays constant during dragging).
}

@property (nonatomic, assign) id <ThumbImageViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger imageIndex;
@property (nonatomic, assign) CGRect home;
@property (nonatomic, assign) CGPoint touchLocation;


- (void)goHome;  // animates return to home location
- (void)moveByOffset:(CGPoint)offset; // change frame lo

@end



@protocol ThumbImageViewDelegate <NSObject>

@optional
- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv;
- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv;
- (void)thumbImageViewMoved:(ThumbImageView *)tiv;
- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv;

@end