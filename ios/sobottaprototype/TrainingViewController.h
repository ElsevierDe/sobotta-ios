//
//  TrainingViewController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 16.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Training.h"
#import "FigureDatasource.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@protocol TrainingDelegate <NSObject>

- (void) nextQuestion:(id)sender;
- (void) solveQuestion:(id)sender;
- (void) trainingModeChange:(id)sender;
- (void) nextFigureWithDialog:(BOOL)showDialog;
- (void) endTrainingWithDialog:(BOOL)showDialog;
- (void) continueTraining:(id)sender;
- (void) backToList:(id)sender;
- (void) answerSelected:(NSInteger)labelid;
- (Training *) currentTraining;
- (FigureDatasource*) currentFigureDatasource;

@end

@interface TrainingViewController : UITableViewController <FBSDKSharingDelegate>

@property (strong, nonatomic) UISegmentedControl *trainingModeControl;

@property (weak, nonatomic) UIPopoverController *parentPopoverController;
@property (strong, nonatomic) NSArray *labels;
@property (weak, nonatomic) id<TrainingDelegate> delegate;

@property (assign, nonatomic) NSInteger viewMode;
@property (assign, nonatomic) BOOL solveButtonEnabled;
@property (assign, nonatomic) BOOL nextQuestionEnabled;
@property (assign, nonatomic) BOOL showEndButton;

@property (strong, nonatomic) NSString *correctStructures;
@property (strong, nonatomic) NSString *wrongStructures;
@property (strong, nonatomic) NSString *percentage;
@property (strong, nonatomic) NSString *structuresCount;
@property (strong, nonatomic) NSString *trainingName;

- (IBAction)trainingModeAction:(id)sender;

- (void)updateTableHeight;
- (void)selectRowWithLabelID:(NSInteger)labelid;
- (void)deselectAllRows;

@end

