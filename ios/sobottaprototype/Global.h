//
//  Global.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 30.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject
+(CGRect)bounds;
+(CGRect)boundsByOrientation:(CGRect)bounds;
+(BOOL)InterfaceOrientationIsLandscape;
@end

