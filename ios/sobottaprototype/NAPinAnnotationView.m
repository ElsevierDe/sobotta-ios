//
// NAPinAnnotationView.m
// NAMapKit
//
// Created by Neil Ang on 21/07/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import "NAPinAnnotationView.h"
#import "NAMapView.h"
#import "NACallOutView.h"
#import <QuartzCore/QuartzCore.h>

#define PIN_WIDTH           43.0
#define PIN_HEIGHT          42.0
#define PIN_POINT_X         19.0
#define PIN_POINT_Y         35.0
#define CALLOUT_OFFSET_X    7.0
#define CALLOUT_OFFSET_Y    5.0

@implementation NAPinAnnotationView

@synthesize annotation = _annotation;

- (id)initWithAnnotation:(NAAnnotation *)annotation onView:(NAMapView *)mapView animated:(BOOL)animate {
	CGRect frame = CGRectZero;
	
	if ((self = [super initWithFrame:frame])) {
		[self commonInit:annotation onView:mapView animated:animate];
		[self addTarget:mapView action:@selector(showCallOut:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return self;
}

- (id)initWithAnnotation:(NAAnnotation *)annotation onView:(NAMapView *)mapView animated:(BOOL)animate andDelegate:(id)target {
	CGRect frame = CGRectZero;
	
	if ((self = [super initWithFrame:frame])) {
		[self commonInit:annotation onView:mapView animated:animate];
		[self addTarget:target action:@selector(pinSelected:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return self;
}

- (void)commonInit:(NAAnnotation *)annotation onView:(NAMapView *)mapView animated:(BOOL)animate {
	self.annotation = annotation;
	self.frame      = [self frameForPoint:self.annotation.point];
	self.layer.zPosition = self.annotation.point.y;
	
	[self setImage:[UIImage imageNamed:annotation.color] forState:UIControlStateNormal];
	
	
	
	// if no title is set, the pin can't be tapped
	if (!self.annotation.title) {
		[self setImage:[UIImage imageNamed:annotation.color] forState:UIControlStateDisabled];
		self.enabled = self.annotation.title ? YES : NO;
	}
	
	[mapView addSubview:self];
	
	if (animate) {
		CABasicAnimation *pindrop = [CABasicAnimation animationWithKeyPath:@"position.y"];
		pindrop.duration       = 0.5f;
		pindrop.fromValue      = [NSNumber numberWithFloat:self.center.y - mapView.frame.size.height];
		pindrop.toValue        = [NSNumber numberWithFloat:self.center.y];
		pindrop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		[self.layer addAnimation:pindrop forKey:@"pindrop"];
	}
}

- (CGRect)frameForPoint:(CGPoint)point {
	// Calculate the offset for the pin point
	float x = point.x - PIN_POINT_X + self.annotation.offset.x;
	float y = point.y - PIN_POINT_Y + self.annotation.offset.y;
	
	return CGRectMake(round(x), round(y), PIN_WIDTH, PIN_HEIGHT);
}

/*
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
 if ([keyPath isEqual:@"contentSize"]) {
 
 }
 }
 */

- (void)dealloc {
	
}

@end
