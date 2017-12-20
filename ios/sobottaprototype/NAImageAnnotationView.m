//
//  NAImageAnnotationView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "NAImageAnnotationView.h"

#define IMAGE_SCALE 1

@implementation NAImageAnnotationView

- (id)initWithAnnotation:(NAAnnotation *)annotation andImage:(UIImage *)image onView:(NAMapView *)mapView animated:(BOOL)animate {
	CGRect frame = CGRectMake(0, 0, 0, 0); // TODO: remove this
    
	if ((self = [super initWithFrame:frame])) {
		self.annotation = annotation;
        imageSize = CGSizeMake(image.size.width / IMAGE_SCALE, image.size.height / IMAGE_SCALE);
        NSLog(@"Setting image Size to %f,%f", imageSize.width, imageSize.height);
        centerPoint = CGPointMake(imageSize.width/2, imageSize.height/2);
		self.frame      = [self frameForPoint:self.annotation.point];
        
        
		[self setImage:image forState:UIControlStateNormal];
        
		[self addTarget:mapView action:@selector(showCallOut:) forControlEvents:UIControlEventTouchDown];
        
		// if no title is set, the pin can't be tapped
		if (!self.annotation.title) {
			[self setImage:image forState:UIControlStateDisabled];
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
    
	return self;
}


- (CGRect)frameForPoint:(CGPoint)point {
	// Calculate the offset for the pin point
	float x = point.x;// - centerPoint.x;
	float y = point.y;// - centerPoint.y;
    NSLog(@"frameForPoint .. %f,%f /// width: %f height:%f", x, y, imageSize.width, imageSize.height);
    
	return CGRectMake(round(x), round(y), imageSize.width, imageSize.height);
}

@end
