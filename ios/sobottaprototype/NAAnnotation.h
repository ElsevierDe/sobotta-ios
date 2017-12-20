//
// NAAnnotation.h
// NAMapKit
//
// Created by Neil Ang on 21/07/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NAAnnotation : NSObject {
	CGPoint   _point;
	CGPoint   _offset;
	NSString *_title;
	NSString *_subtitle;
	UIButton *_rightCalloutAccessoryView;
	NSString *_color;
	BOOL      _hidden;
	NSInteger _labelid;
	NSInteger _spotid;
}

// points as we are not showing coords!
@property (nonatomic, assign) CGPoint   point;
@property (nonatomic, assign) CGPoint	offset;
@property (nonatomic, copy) NSString   *title;
@property (nonatomic, copy) NSString   *subtitle;
@property (nonatomic, retain) UIButton *rightCalloutAccessoryView;
@property (nonatomic, copy) NSString   *color;
@property (nonatomic, assign) BOOL	    hidden;
@property (nonatomic, assign) NSInteger labelid;
@property (nonatomic, assign) NSInteger spotid;

+ (id)annotationWithPoint:(CGPoint)point andColor:(NSString*)color;
+ (id)annotationWithPoint:(CGPoint)point;
- (id)initWithPoint:(CGPoint)point;
- (id)initWithPoint:(CGPoint)point andColor:(NSString*)color;

@end
