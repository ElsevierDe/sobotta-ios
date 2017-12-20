//
//  Repetition_Figure+CoreDataProperties.h
//  sobottaprototype
//
//  Created by Herbert Poul on 01/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "Repetition_Figure+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Repetition_Figure (CoreDataProperties)

+ (NSFetchRequest<Repetition_Figure *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *figure_id;
@property (nullable, nonatomic, copy) NSNumber *label_count;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSDate *synced;
@property (nullable, nonatomic, retain) NSSet<Repetition_FigureLabel *> *labels;
@property (nullable, nonatomic, retain) Training *last_training;

@end

@interface Repetition_Figure (CoreDataGeneratedAccessors)

- (void)addLabelsObject:(Repetition_FigureLabel *)value;
- (void)removeLabelsObject:(Repetition_FigureLabel *)value;
- (void)addLabels:(NSSet<Repetition_FigureLabel *> *)values;
- (void)removeLabels:(NSSet<Repetition_FigureLabel *> *)values;

@end

NS_ASSUME_NONNULL_END
