//
//  MyNotesRootViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNotesRootViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *leftView;

@property (weak, nonatomic) IBOutlet UIView *rightView;


@property (strong, nonatomic) UIViewController* leftController;
@property (strong, nonatomic) UIViewController* rightController;

@end
