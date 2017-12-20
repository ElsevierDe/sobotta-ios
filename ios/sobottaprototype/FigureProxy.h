//
//  FigureProxy.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/19/13.
//  Copyright (c) 2013 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Training_Figures;

@interface FigureProxy : NSManagedObject

@property (nonatomic, retain) NSNumber * figure_id;
@property (nonatomic, retain) NSNumber *chapter_id;
@property (nonatomic, retain) NSNumber *level1_id;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * syncedate;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSNumber * totalfilesizebyte;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) Training_Figures *bestTrainingResult;
@property (nonatomic, retain) Training_Figures *latestTrainingResult;
@property (nonatomic, retain) Training_Figures *worstTrainingResult;

@end
