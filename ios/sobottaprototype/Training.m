//
//  Training.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Training.h"
#import "Bookmarklist.h"
#import "Training_Figures.h"
#import "Repetition_FigureLabel+CoreDataClass.h"


NSString  * _Nonnull NSStringFromTrainingType(enum TrainingType trainingType) {
    switch(trainingType) {
        case TrainingTypeRepetition: return @"TrainingTypeRepetition";
        case TrainingTypeSequence: return @"TrainingTypeSequence";
    }
}

NSString * _Nonnull NSStringFromTrainingTypeForAnalytics(enum TrainingType trainingType) {
    switch(trainingType) {
        case TrainingTypeRepetition: return @"Repetition";
        case TrainingTypeSequence: return @"Sequence";
    }
}


@implementation Training

@dynamic amount_answered;
@dynamic amount_correct;
@dynamic amount_skipped;
@dynamic amount_wrong;
@dynamic repetition_amount_total;
@dynamic repetition_amount_learned_total;
@dynamic currentindex;
@dynamic currentmode;
@dynamic end;
@dynamic inprogress;
@dynamic name;
@dynamic nametype;
@dynamic searchterm;
@dynamic start;
@dynamic amount_completed_figures;
@dynamic bookmarklist;
@dynamic figures;
@dynamic training_type;
@dynamic laststart;
@dynamic duration;
@dynamic repetition_figures;

- (enum TrainingType)trainingType {
    if (!self.training_type) {
        return TrainingTypeSequence;
    }
    return self.training_type.integerValue;
}

- (void)setTrainingType:(enum TrainingType)trainingType {
    self.training_type = [NSNumber numberWithInteger:trainingType];
}

+ (NSString *)stringForRepetitionLabelsByType:(NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)labelsByType {
    return [NSString stringWithFormat:@"Active Labels: %ld, (due,n,l,r) %ld,%ld,%ld,%ld",
     (unsigned long)labelsByType[RepetitionFigureLabelTypeAll].count,
     (unsigned long)labelsByType[RepetitionFigureLabelTypeDue].count,
     (unsigned long)labelsByType[RepetitionFigureLabelTypeNew].count,
     (unsigned long)labelsByType[RepetitionFigureLabelTypeLearning].count,
     (unsigned long)labelsByType[RepetitionFigureLabelTypeReviewing].count];
}

- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)repetitionLabelsByTypeIncludeAll:(NSManagedObjectContext *)context {
    NSArray<Repetition_FigureLabel *> *repetitionLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training == %@", self] inContext:context];
    
    NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *labelsByType = [self groupRepetitionLabelsByType:repetitionLabels];

    
    return labelsByType;
}

- (NSInteger)unsyncedLabelCount:(NSManagedObjectContext *)context {
    NSArray<Repetition_Figure *> *figures = [Repetition_Figure where:[NSPredicate predicateWithFormat:@"last_training == %@ AND synced == nil", self] inContext:context];
    NSInteger new = [figures bk_reduceInteger:0 withBlock:^NSInteger(NSInteger result, Repetition_Figure *fig) {
        return result + fig.label_count.integerValue;
    }];
    DDLogInfo(@"Remaining new labels: %ld", (long) new);
    return new;
}

/// Returns a dictionary grouped by type.
- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)repetitionLabelsByType:(NSManagedObjectContext *)context {
    NSArray<Repetition_FigureLabel *> *repetitionLabels = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"active == %@", self.start] inContext:context];
    return [self groupRepetitionLabelsByType:repetitionLabels];
}

- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)groupRepetitionLabelsByType:(NSArray<Repetition_FigureLabel *> *)repetitionLabels {
    
    NSDate *now = [NSDate date];
    
    NSMutableArray<Repetition_FigureLabel *> *due = [NSMutableArray array],
    *new = [NSMutableArray array],
    *learning = [NSMutableArray array],
    *reviewing = [NSMutableArray array];
    NSDictionary<NSString *, NSMutableArray<Repetition_FigureLabel *> *> *labelByType = \
    @{
      RepetitionFigureLabelTypeAll: repetitionLabels,
      RepetitionFigureLabelTypeDue: due,
      RepetitionFigureLabelTypeNew: new,
      RepetitionFigureLabelTypeLearning: learning,
      RepetitionFigureLabelTypeReviewing: reviewing
      };
    
    for (Repetition_FigureLabel *label in repetitionLabels) {
        if (label.due && [label.due compare:now] != NSOrderedDescending) {
            [due addObject:label];
        }
        [labelByType[label.type] addObject:label];
    }
    
    return labelByType;
}


@end
