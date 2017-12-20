//
//  RepetitionTrainingInfoOverlayViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 07/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "RepetitionTrainingInfoOverlayViewController.h"

@interface RepetitionTrainingInfoOverlayViewController ()

@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *bodyText;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *dialogWrapperView;

@property (copy, nonatomic) void(^bindViewCallback)();

@end

@implementation RepetitionTrainingInfoOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.dialogWrapperView.layer.cornerRadius = 2;
    self.dialogWrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.dialogWrapperView.layer.shadowRadius = 8;
    self.dialogWrapperView.layer.shadowOpacity = 0.5;

    [[SOThemeManager sharedTheme] applyButtonTheme:self.doneButton];
    
    self.bindViewCallback();
    self.bindViewCallback = nil;
}

- (void)bindTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle body:(NSString *)body doneButtonLabel:(NSString *)doneButtonLabel {
    __weak RepetitionTrainingInfoOverlayViewController *weakSelf = self;
    self.bindViewCallback = ^void() {
        weakSelf.mainTitle.text = mainTitle;
        weakSelf.subTitle.text = subTitle;
        weakSelf.bodyText.text = body;
        [weakSelf.doneButton setTitle:doneButtonLabel forState:UIControlStateNormal];
    };
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
- (IBAction)pressedOutside:(UITapGestureRecognizer *)sender {
    self.onFinish(self, YES);
}

- (IBAction)donePressed:(UIButton *)sender {
    self.onFinish(self, NO);
}

@end
