//
//  Repetition_FigureLabel+CoreDataProperties.h
//  sobottaprototype
//
//  Created by Herbert Poul on 02/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "Repetition_FigureLabel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Repetition_FigureLabel (CoreDataProperties)

+ (NSFetchRequest<Repetition_FigureLabel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *active;
@property (nullable, nonatomic, copy) NSNumber *easefactor;
@property (nullable, nonatomic, copy) NSNumber *figure_label_id;
@property (nullable, nonatomic, copy) NSNumber *figure_label_order;
@property (nullable, nonatomic, copy) NSNumber *interval;
@property (nullable, nonatomic, copy) NSDate *lastanswered;
@property (nullable, nonatomic, copy) NSDate *lastscheduled;
@property (nullable, nonatomic, copy) NSNumber *session_step;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSDate *due;
@property (nullable, nonatomic, retain) Repetition_Figure *figure;

@end

NS_ASSUME_NONNULL_END
