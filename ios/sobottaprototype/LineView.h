//
//  LineView.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleAnnotation.h"
#import "HomescreenViewController.h"

@interface LineView : UIView {
}

- (id)initWithFrame:(CGRect)frame andViewController:(HomescreenViewController*)controller;

@property (weak, nonatomic) HomescreenViewController* controller;
@property (nonatomic, retain) NSMutableArray *annotations;

@end
