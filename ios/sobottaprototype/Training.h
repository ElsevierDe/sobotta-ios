//
//  Training.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//#define SPACED_REPETITION_MAX_ITEMS 50
//#define RepetitionMaxItems 50
#define RepetitionMaxItems 10


@class Bookmarklist, Training_Figures, Repetition_Figure, Repetition_FigureLabel;

NS_ENUM(NSInteger, TrainingType) {
    TrainingTypeSequence = 0,
    TrainingTypeRepetition = 1,
};

NSString  * _Nonnull NSStringFromTrainingType(enum TrainingType trainingType);
NSString * _Nonnull NSStringFromTrainingTypeForAnalytics(enum TrainingType trainingType);

@interface Training : NSManagedObject

@property (nonatomic, retain) NSNumber * _Nullable amount_answered;
@property (nonatomic, retain) NSNumber * _Nullable amount_correct;
@property (nonatomic, retain) NSNumber * _Nullable amount_skipped;
@property (nonatomic, retain) NSNumber * _Nullable amount_wrong;
@property (nonatomic, retain) NSNumber * _Nullable repetition_amount_total;
@property (nonatomic, retain) NSNumber * _Nullable repetition_amount_learned_total;
@property (nonatomic, retain) NSNumber * currentindex;
@property (nonatomic, retain) NSNumber * currentmode;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSNumber * inprogress;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nametype;
@property (nonatomic, retain) NSString * searchterm;
@property (nonatomic, retain) NSDate * start;
/// Used for spaced repetition to know when it was last resumed.
@property (nullable, nonatomic, copy) NSDate *laststart;
@property (nonatomic, retain) NSNumber * amount_completed_figures;
@property (nonatomic, retain) Bookmarklist *bookmarklist;
@property (nonatomic, retain) NSOrderedSet *figures;
@property (nonatomic, retain) NSNumber * training_type;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSSet<Repetition_Figure *> * _Nullable repetition_figures;

@property enum TrainingType trainingType;


+ (NSString *)stringForRepetitionLabelsByType:(NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)labelsByType;
- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)repetitionLabelsByType:(NSManagedObjectContext *)context;
- (NSDictionary<NSString *, NSArray<Repetition_FigureLabel *> *> *)repetitionLabelsByTypeIncludeAll:(NSManagedObjectContext *)context;
- (NSInteger)unsyncedLabelCount:(NSManagedObjectContext *)context;

@end

@interface Training (CoreDataGeneratedAccessors)

- (void)insertObject:(Training_Figures *)value inFiguresAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFiguresAtIndex:(NSUInteger)idx;
- (void)insertFigures:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFiguresAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFiguresAtIndex:(NSUInteger)idx withObject:(Training_Figures *)value;
- (void)replaceFiguresAtIndexes:(NSIndexSet *)indexes withFigures:(NSArray *)values;
- (void)addFiguresObject:(Training_Figures *)value;
- (void)removeFiguresObject:(Training_Figures *)value;
- (void)addFigures:(NSOrderedSet *)values;
- (void)removeFigures:(NSOrderedSet *)values;
@end
