//
//  Global.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 30.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Global.h"

@implementation Global

+(CGRect)bounds {
    return [self getScreenBoundsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(BOOL)InterfaceOrientationIsLandscape {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)){
		return YES;
	}
	return NO;
}

+(CGRect)boundsByOrientation:(CGRect)bounds {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)){
		bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
	}
	return bounds;
}

+(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation {
	
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
	
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        fullScreenRect = CGRectMake(fullScreenRect.origin.x, fullScreenRect.origin.y, fullScreenRect.size.height, fullScreenRect.size.width);
    }
	
    return fullScreenRect;
}

@end
