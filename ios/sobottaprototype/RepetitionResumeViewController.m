//
//  RepetitionResumeViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 18/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "RepetitionResumeViewController.h"

#import <BonMot/BonMot.h>

#import "DatabaseController.h"
#import "FigureDatasource.h"
#import "Repetition_FigureLabel+CoreDataClass.h"

@interface RepetitionResumeViewController ()

@property DatabaseController *databaseController;

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bodyHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundColorView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *progressBarWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarWrapperHeightConstraint;
@property CGFloat progressBarWrapperHeightOriginalConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *progressBarLabel;

@end

@implementation RepetitionResumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _databaseController = [DatabaseController Current];
    
    self.view.layer.cornerRadius = 2;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 8;
    self.view.layer.shadowOpacity = 0.5;

    self.backgroundColorView.layer.cornerRadius = 2;
    self.backgroundImageView.layer.cornerRadius = 2;
    
    _progressBarWrapperHeightOriginalConstant = _progressBarWrapperHeightConstraint.constant;
    
    [self bind];
}

- (void)viewWillAppear:(BOOL)animated {
    [self bind];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resumeButtonPressed:(id)sender {
    _onResumeClicked();
}

- (void)viewWillLayoutSubviews {
    DDLogVerbose(@"Will layout subviews. %@", self.bodyHeightConstraint);
    //[self bindEmpty];
    CGSize size = [self.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    DDLogVerbose(@"size: %@", NSStringFromCGSize(size));
    self.preferredContentSize = size;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"Did layout subviews. %@", self.bodyHeightConstraint);
}

- (void)bind {
    Training *training = [_databaseController getRunningTraining];
    if (!training) {
        training = [_databaseController getLastRepetitionLearningTraining];
    }
    if (training) {
        [self bindTraining:training];
    } else {
        [self bindEmpty];
    }

    CGSize size = [self.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    DDLogVerbose(@"size: %@", NSStringFromCGSize(size));
}

- (void)bindEmpty {
    self.titleView.text = NSLocalizedString(@"Begin your training", nil);
    BONChain *image = [BONChain new].image([UIImage imageNamed:@"ic_training_play"]).baselineOffset(-3.0);
    BONChain *space = BONChain.new.string(@"  ");
    BONChain *chain = BONChain.new;
    
    NSString *label = NSLocalizedString(@"Choose a figure and press the PLAY button.", nil);
    NSArray<NSString *> *labelComponents = [label componentsSeparatedByString:@"PLAY"];

    [chain appendLink:BONChain.new.string(labelComponents[0])];
    [chain appendLink:image separatorTextable:space];
    [chain appendLink:BONChain.new.string(labelComponents[1]) separatorTextable:space];
    self.name.attributedText = chain.attributedString;
    self.playButton.hidden = YES;
    
    [self.view layoutIfNeeded];
    self.body.hidden = YES;
    self.bodyHeightConstraint.active = YES;
    self.progressBarWrapper.hidden = YES;
    self.progressBarWrapperHeightConstraint.constant = 0;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)bindTraining:(Training *)training {
    if (training.inprogress.boolValue) {
        self.titleView.text = NSLocalizedString(@"Your current training", nil);
    } else {
        self.titleView.text = NSLocalizedString(@"Your next training", nil);
    }
    self.name.text = [FigureDatasource trainingNameLocalizedForTraining:training];
    
    NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *labelsByType;
    NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *allLabelsByType = [training repetitionLabelsByTypeIncludeAll:training.managedObjectContext];
    if (training.inprogress.boolValue) {
        labelsByType = [training repetitionLabelsByType:training.managedObjectContext];
    } else {
        labelsByType = allLabelsByType;
    }
    self.playButton.hidden = NO;
    
    NSInteger unsyncedLabelCount = [training unsyncedLabelCount:training.managedObjectContext];
    NSInteger totalLabels = allLabelsByType[RepetitionFigureLabelTypeAll].count + unsyncedLabelCount;
    
    DDLogVerbose(@"totalCount: %ld / All: %@ / Active: %@", (long)totalLabels, [Training stringForRepetitionLabelsByType:[training repetitionLabelsByTypeIncludeAll:training.managedObjectContext]], [Training stringForRepetitionLabelsByType:[training repetitionLabelsByType:training.managedObjectContext]]);
    
    NSUInteger newForNextTraining = labelsByType[RepetitionFigureLabelTypeNew].count;
    NSUInteger totalNew = unsyncedLabelCount + newForNextTraining;
    NSUInteger repeatLabels = labelsByType[RepetitionFigureLabelTypeLearning].count + labelsByType[RepetitionFigureLabelTypeReviewing].count;
    NSUInteger repeatLabelsForNextTraining = repeatLabels;


    if (!training.inprogress.boolValue) {
        // Only consider labels which are due.
        repeatLabels = labelsByType[RepetitionFigureLabelTypeLearning].count + labelsByType[RepetitionFigureLabelTypeDue].count;
        repeatLabelsForNextTraining = repeatLabels;
        if (repeatLabelsForNextTraining > RepetitionMaxItems) {
            repeatLabelsForNextTraining = RepetitionMaxItems;
        }
        newForNextTraining = MIN(totalNew, RepetitionMaxItems - repeatLabelsForNextTraining);
        DDLogDebug(@"No training in progress right now, so take a guess. (total new: %ld, newForNextTraining: %ld, max: %ld, repeatLabels: %ld)", (long) totalNew, (long)newForNextTraining, (long)RepetitionMaxItems, (long)repeatLabels);
    }
    
    NSUInteger remaining = totalNew + repeatLabels;
    NSUInteger learned = totalLabels - remaining;
    CGFloat percent = 100. / totalLabels * learned;
    
    DDLogVerbose(@"Learned %f%% / remaining: %ld / learned: %ld", percent, (long)remaining, (long)learned);
    
    if (totalLabels < 1) {
        DDLogError(@"No labels for training? binding empty - this is very weird.");
        [self bindEmpty];
        return;
    }
    
    self.body.text = [NSString stringWithFormat:NSLocalizedString(@"%ld new, %ld to repeat", nil), (unsigned long)newForNextTraining, (unsigned long)repeatLabelsForNextTraining];
    
    [self.view layoutIfNeeded];
    self.body.hidden = NO;
    self.bodyHeightConstraint.active = NO;
    if (!IS_PHONE) {
        self.progressBarWrapper.hidden = NO;
        self.progressBarWrapperHeightConstraint.constant = self.progressBarWrapperHeightOriginalConstant;
        self.progressBarWidthConstraint.constant = self.progressBarWrapper.bounds.size.width / 100. * percent;
        self.progressBarLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d%% learned", nil), (int) round(percent)];
        if (percent > 50) {
            self.progressBarLabel.textAlignment = NSTextAlignmentLeft;
            self.progressBarLabel.textColor = [UIColor whiteColor];
        } else {
            self.progressBarLabel.textAlignment = NSTextAlignmentRight;
            self.progressBarLabel.textColor = [UIColor blackColor];
        }
    }
    [self.view layoutIfNeeded];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
