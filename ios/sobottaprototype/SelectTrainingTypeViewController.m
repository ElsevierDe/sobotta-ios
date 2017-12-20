//
//  SelectTrainingTypeViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/09/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "SelectTrainingTypeViewController.h"

#import "Theme.h"

@interface SelectTrainingTypeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dialogTitle;
@property (weak, nonatomic) IBOutlet UILabel *dialogSubtitle;

@property (weak, nonatomic) IBOutlet UIView *dialogWrapperView;

@property (weak, nonatomic) IBOutlet UILabel *sequenceTitle;
@property (weak, nonatomic) IBOutlet UILabel *sequenceDescription;
@property (weak, nonatomic) IBOutlet UIButton *sequenceButton;

@property (weak, nonatomic) IBOutlet UILabel *repetitionTitle;
@property (weak, nonatomic) IBOutlet UILabel *repetitionDescription;
@property (weak, nonatomic) IBOutlet UIButton *repetitionButton;


@end

@implementation SelectTrainingTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dialogWrapperView.layer.cornerRadius = 2;
    self.dialogWrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.dialogWrapperView.layer.shadowRadius = 8;
    self.dialogWrapperView.layer.shadowOpacity = 0.5;
    
    _dialogTitle.text = NSLocalizedString(@"Start new training", nil);
    _dialogSubtitle.text = NSLocalizedString(@"Please choose the type of training you want to start:", nil);
    _sequenceTitle.text = NSLocalizedString(@"selecttrainingtype.sequence.title", nil);
    _sequenceDescription.text = NSLocalizedString(@"selecttrainingtype.sequence.description", nil);
    [_sequenceButton setTitle:NSLocalizedString(@"selecttrainingtype.start", nil) forState:UIControlStateNormal];
    _repetitionTitle.text = NSLocalizedString(@"selecttrainingtype.repetition.title", nil);
    _repetitionDescription.text = NSLocalizedString(@"selecttrainingtype.repetition.description", nil);
    [_repetitionButton setTitle:NSLocalizedString(@"selecttrainingtype.start", nil) forState:UIControlStateNormal];
    
    [[SOThemeManager sharedTheme] applyButtonTheme:self.sequenceButton];
    [[SOThemeManager sharedTheme] applyButtonTheme:self.repetitionButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)pressedSquentialButton:(UIButton *)sender {
    self.onFinish(self, false, TrainingTypeSequence);
}

- (IBAction)pressedSpacedRepetitionButton:(id)sender {
    self.onFinish(self, false, TrainingTypeRepetition);
}

- (IBAction)pressedOutside:(UITapGestureRecognizer *)sender {
    self.onFinish(self, true, 0);
}

@end
