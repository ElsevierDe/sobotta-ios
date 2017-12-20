//
//  RepetitionTrainingInfoOverlayViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 07/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepetitionTrainingInfoOverlayViewController : UIViewController

- (void)bindTitle:(nonnull NSString *)mainTitle subTitle:(nonnull NSString *)subTitle body:(nonnull NSString *)body doneButtonLabel:(nonnull NSString *)doneButtonLabel;

/// called when the user clicks 'done'.
@property (nonatomic, copy, nonnull) void (^onFinish)(RepetitionTrainingInfoOverlayViewController * _Nonnull sender, BOOL cancel);


@end
