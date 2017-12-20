//
// NAAnnotation.m
// NAMapKit
//
// Created by Neil Ang on 21/07/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import "NAAnnotation.h"


@implementation NAAnnotation

@synthesize point                     = _point;
@synthesize offset					  = _offset;
@synthesize title                     = _title;
@synthesize subtitle                  = _subtitle;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;
@synthesize hidden					  = _hidden;
@synthesize color					  = _color;
@synthesize labelid					  = _labelid;
@synthesize spotid					  = _spotid;


+ (id)annotationWithPoint:(CGPoint)point {
	return [[[self class] alloc] initWithPoint:point];
}

+ (id)annotationWithPoint:(CGPoint)point andColor:(NSString*)color {
	return [[[self class] alloc] initWithPoint:point andColor:color];
}

- (id)initWithPoint:(CGPoint)point {
	self = [super init];
	
	if (nil != self) {
		self.point = point;
		self.offset = CGPointMake(0, 0);
	}
	
	return self;
}

- (id)initWithPoint:(CGPoint)point andColor:(NSString *)color {
	self = [self initWithPoint:point];
	
	if (nil != self) {
		self.color = color;
	}
	
	return self;
}

- (void)setPoint:(CGPoint)point {
    _point = point;
}

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
}

- (void)dealloc {
	
}

@end
