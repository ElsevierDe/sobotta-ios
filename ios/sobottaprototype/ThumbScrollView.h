//
//  ThumbScrollView.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 30.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbImageView.h"
#import "DatabaseController.h"

@protocol ThumbScrollViewDelegate;

@interface ThumbScrollView : UIScrollView<UIScrollViewDelegate> {
	//__unsafe_unretained id <ThumbScrollViewDelegate> delegate;
	NSArray *imageNames;
	id<ThumbImageViewDelegate> delegateTarget;
	
	NSMutableSet *recycledPages;
	NSMutableSet *visiblePages;
}

//@property (nonatomic, assign) id <ThumbScrollViewDelegate> delegate;

- (id)initWithImageNames:(NSArray*)names onTarget:(id<ThumbImageViewDelegate>)target;
- (void)tileImages;
- (void)updateOrientation;
- (void)setCurrentImage:(NSInteger)index andCenter:(BOOL)center;

@end