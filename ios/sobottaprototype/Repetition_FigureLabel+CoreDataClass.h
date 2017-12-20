//
//  Repetition_FigureLabel+CoreDataClass.h
//  
//
//  Created by Herbert Poul on 23/09/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Repetition_Figure+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

#define RepetitionFigureLabelTypeNew @"new"
#define RepetitionFigureLabelTypeLearning @"learning"
#define RepetitionFigureLabelTypeReviewing @"reviewing"
#define RepetitionFigureLabelTypeAll @"all" /// never written into DB
#define RepetitionFigureLabelTypeDue @"due" /// never written into DB



typedef NS_ENUM(NSInteger, RepetitionLabelRating) {
    RepetitionLabelRatingRepeat,
    RepetitionLabelRatingHard,
    RepetitionLabelRatingGood,
    RepetitionLabelRatingEasy
};

typedef NS_ENUM(NSInteger, RepetitionSessionStep) {
    RepetitionSessionStepNone = 0,
    RepetitionSessionStepNow = 60,
    RepetitionSessionStepLater = 600,
};

typedef NS_ENUM(NSUInteger, RepetitionInterval) {
    RepetitionIntervalTomorrow = 1*24*3600,
    RepetitionIntervalDaysLater = 4*24*3600,
    RepetitionIntervalRescheduleHarder = 100001,
    RepetitionIntervalRescheduleSame = 100002,
    RepetitionIntervalRescheduleEasier = 100003,
};


@interface Repetition_FigureLabel : NSManagedObject

@property (readonly) RepetitionSessionStep sessionStep;

+ (Repetition_FigureLabel *)findByLabelId:(long)labelId context:(NSManagedObjectContext *)context;

- (void)scheduleLearning:(RepetitionSessionStep)sessionStep;
- (void)scheduleReviewing:(RepetitionInterval)interval;

- (void)scheduleForRating:(RepetitionLabelRating)rating;


- (NSString *)debugString;

@end

NS_ASSUME_NONNULL_END

#import "Repetition_FigureLabel+CoreDataProperties.h"
