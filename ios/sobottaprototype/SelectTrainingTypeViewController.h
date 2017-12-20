//
//  SelectTrainingTypeViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/09/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Training.h"

@interface SelectTrainingTypeViewController : UIViewController

/// called either when the user cancelled the dialog, or selected a training type.
@property (nonatomic, copy, nonnull) void (^onFinish)(SelectTrainingTypeViewController * _Nonnull sender, BOOL cancel, enum TrainingType trainingType);

@end
