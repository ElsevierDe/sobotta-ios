//
//  TrainingResultsCell.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingResultsCell : UITableViewCell {
    UIImage* _bgImage;
}


@property (weak, nonatomic) IBOutlet UIView *cellWrapper;

@property (weak, nonatomic) IBOutlet UILabel *lblFigureCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestionCorrectLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblTrainingName;
@property (weak, nonatomic) IBOutlet UILabel *lblTrainingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblFigureCount;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestionCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCorrectPercent;

@end
