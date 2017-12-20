//
//  Training_Figures.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Training, Training_Figure_Labels;

@interface Training_Figures : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * figure_id;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * amount_correct;
@property (nonatomic, retain) NSNumber * amount_wrong;
@property (nonatomic, retain) NSNumber * percent_correct;
@property (nonatomic, retain) NSOrderedSet *labels;
@property (nonatomic, retain) Training *training;
@end

@interface Training_Figures (CoreDataGeneratedAccessors)

+ (Training_Figures *)findByFigureId:(long)figureId context:(NSManagedObjectContext *)context;

- (void)insertObject:(Training_Figure_Labels *)value inLabelsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLabelsAtIndex:(NSUInteger)idx;
- (void)insertLabels:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLabelsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLabelsAtIndex:(NSUInteger)idx withObject:(Training_Figure_Labels *)value;
- (void)replaceLabelsAtIndexes:(NSIndexSet *)indexes withLabels:(NSArray *)values;
- (void)addLabelsObject:(Training_Figure_Labels *)value;
- (void)removeLabelsObject:(Training_Figure_Labels *)value;
- (void)addLabels:(NSOrderedSet *)values;
- (void)removeLabels:(NSOrderedSet *)values;
@end
