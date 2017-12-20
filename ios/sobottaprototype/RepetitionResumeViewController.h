//
//  RepetitionResumeViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 18/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepetitionResumeViewController : UIViewController

@property (nonatomic, copy) void (^onResumeClicked)();

@end
