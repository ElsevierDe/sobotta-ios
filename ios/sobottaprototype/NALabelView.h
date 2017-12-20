//
//  NALabelView.h
//  MedicalPrototype
//
//  Created by Stephan Kitzler-Walli on 13.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NALabel.h"

@class NAMapView;

@protocol NALabelViewDelegate <NSObject>

- (void)labelSelected:(NALabel *)label atPosition:(NSInteger)positon;
- (void)labelDeselected;

@end

//typedef enum {fixed, scaled} RenderMode;

@interface NALabelView : UIView {
@private
	NSMutableArray *_labels;
	CGSize   _textSize;
	CGFloat  _fontSize;
	CGFloat  _xfactor;
	CGFloat  _yfactor;
	CGPoint  _offset;
}

- (id)initWithLabel:(NALabel *)label onView:(UIView *)mapView;
- (void) addLabel:(NALabel *)label;
- (CGSize)calculateMaxTextWidth:(NSString *)title forFont:(UIFont*)font;
- (void)updatePositions;
- (BOOL)checkTouch:(UITouch*)touch;

@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, assign) CGSize   textSize;
@property (nonatomic, assign) CGFloat  fontSize;
@property (nonatomic, assign) CGFloat  xfactor;
@property (nonatomic, assign) CGFloat  yfactor;
//@property (nonatomic, assign) RenderMode renderMode;
@property (nonatomic, weak) id <NALabelViewDelegate> delegate;
@end


