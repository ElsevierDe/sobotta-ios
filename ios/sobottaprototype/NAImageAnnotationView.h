//
//  NAImageAnnotationView.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAPinAnnotationView.h"

@interface NAImageAnnotationView : NAPinAnnotationView {
    CGSize imageSize;
    CGPoint centerPoint;
}


- (id)initWithAnnotation:(NAAnnotation *)annotation andImage:(UIImage *)image onView:(NAMapView *)mapView animated:(BOOL)animate;

@end
