//
//  Repetition_FigureLabel+CoreDataClass.m
//  
//
//  Created by Herbert Poul on 23/09/16.
//
//

#import "Repetition_FigureLabel+CoreDataClass.h"

@interface Repetition_FigureLabel ()

@property (readonly) double scheduleRandom;

@end

@implementation Repetition_FigureLabel

+ (Repetition_FigureLabel *)findByLabelId:(long)labelId context:(NSManagedObjectContext *)context {
    return [Repetition_FigureLabel find:@{@"figure_label_id": @(labelId)} inContext:context];
}

- (RepetitionSessionStep)sessionStep {
    return self.session_step.integerValue;
}

- (double)scheduleRandom {
    static double upper = 1.01;
    static double lower = 0.9;
    static double arc4random_max = 0x100000000;
    
    // random factor around 1
    double random = ((double)arc4random() / arc4random_max) * (upper-lower) + lower;
    DDLogVerbose(@"random factor: %f", random);
    return random;
}

- (void)scheduleLearning:(RepetitionSessionStep)sessionStep {
    self.type = RepetitionFigureLabelTypeLearning;
    self.interval = @(0);
    self.session_step = @(sessionStep);
    self.lastscheduled = [NSDate date];
}

- (int)value:(int)value between:(int)a and:(int)b {
    int lowerBound = MIN(a, b);
    int upperBound = MAX(a, b);
    return MIN(upperBound, MAX(lowerBound, value));
}

- (void)updateEaseFactor:(int)change {
    int ease = self.easefactor.intValue;
    self.easefactor = @([self value:ease+change between:130 and:250]);
}

- (void)scheduleReviewing:(RepetitionInterval)interval {
    self.type = RepetitionFigureLabelTypeReviewing;
    self.session_step = @(RepetitionSessionStepNone);
    
    BOOL reschedule = YES;
    
    switch (interval) {
        case RepetitionIntervalTomorrow:
        case RepetitionIntervalDaysLater:
            self.interval = @(interval);
            reschedule = NO;
            break;
        case RepetitionIntervalRescheduleEasier:
            [self updateEaseFactor:15];
            break;
        case RepetitionIntervalRescheduleSame:
            break;
        case RepetitionIntervalRescheduleHarder:
            [self updateEaseFactor:-15];
            break;
    }
    
    if (reschedule) {
        self.interval = @(self.interval.doubleValue * ( (double)self.easefactor.intValue / 100. ) * self.scheduleRandom);
        if (self.interval.doubleValue < 1.) {
            DDLogWarn(@"Interval is less than 1, should usually not happen.");
            self.interval = @1;
        } else if (self.interval.doubleValue > 365.) {
            DDLogInfo(@"Interval is longer than 1 year, keeping it at that.");
            self.interval = @365;
        }
    }
    
    self.lastscheduled = [NSDate date];
    // once it is rescheduled into 'reviewing' it is no longer active for the current training.
    self.active = nil;
}

- (void)scheduleForRating:(RepetitionLabelRating)rating {
    NSString *before = self.debugString;
    
    Repetition_FigureLabel *l = self;
    if ([l.type isEqualToString:RepetitionFigureLabelTypeNew]) {
        switch (rating) {
            case RepetitionLabelRatingRepeat:
            case RepetitionLabelRatingHard:
                [l scheduleLearning:RepetitionSessionStepNow];
                break;
            case RepetitionLabelRatingGood:
                [l scheduleLearning:RepetitionSessionStepLater];
                break;
            case RepetitionLabelRatingEasy:
                [l scheduleReviewing:RepetitionIntervalDaysLater];
                break;
        }
    } else if ([l.type isEqualToString:RepetitionFigureLabelTypeLearning]) {
        switch (rating) {
            case RepetitionLabelRatingRepeat:
            case RepetitionLabelRatingHard:
                [l scheduleLearning:RepetitionSessionStepNow];
                break;
            case RepetitionLabelRatingGood:
                switch (l.sessionStep) {
                    case RepetitionSessionStepNone:
                        // Error?!
                        break;
                    case RepetitionSessionStepNow:
                        [l scheduleLearning:RepetitionSessionStepLater];
                        break;
                    case RepetitionSessionStepLater:
                        [l scheduleReviewing:RepetitionIntervalTomorrow];
                        break;
                }
                break;
            case RepetitionLabelRatingEasy:
                [l scheduleReviewing:RepetitionIntervalDaysLater];
                break;
        }
    } else if ([l.type isEqualToString:RepetitionFigureLabelTypeReviewing]) {
        switch (rating) {
            case RepetitionLabelRatingRepeat:
                [l scheduleLearning:RepetitionSessionStepNow];
                break;
            case RepetitionLabelRatingHard:
                [l scheduleReviewing:RepetitionIntervalRescheduleHarder];
                break;
            case RepetitionLabelRatingGood:
                [l scheduleReviewing:RepetitionIntervalRescheduleSame];
                break;
            case RepetitionLabelRatingEasy:
                [l scheduleReviewing:RepetitionIntervalRescheduleEasier];
                break;
        }
    }
    
    NSDate *due;
    
    if ([l.type isEqualToString:RepetitionFigureLabelTypeLearning]) {
        l.due = due = [NSDate dateWithTimeIntervalSinceNow:(l.session_step.intValue * (double)self.scheduleRandom)];
    } else if ([l.type isEqualToString:RepetitionFigureLabelTypeReviewing]) {
        l.due = due = [NSDate dateWithTimeIntervalSinceNow:l.interval.doubleValue * self.scheduleRandom * 60 * 60 * 24];
    }
    
    NSDictionary<NSNumber *, NSString *> *ratingToString = @{
                                                             @(RepetitionLabelRatingRepeat): @"Repeat",
                                                             @(RepetitionLabelRatingHard): @"Hard",
                                                             @(RepetitionLabelRatingGood): @"Good",
                                                             @(RepetitionLabelRatingEasy): @"Easy",
                                                             };
    
    DDLogDebug(@"Rescheduled (rating: %@): %@ (was before: %@)", ratingToString[@(rating)], l.debugString, before);
}

- (NSString *)debugString {
    return [NSString stringWithFormat:@"id:%ld,fid:%ld,t:%@,ease:%@,step:%@,i:%@ due:%@ active:%@", self.figure_label_id.longValue, self.figure.figure_id.longValue, self.type, self.easefactor, self.session_step, self.interval, self.due, self.active];
}

@end
