//
//  Repetition_Figure+CoreDataClass.h
//  sobottaprototype
//
//  Created by Herbert Poul on 26/09/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Training.h"

@class Repetition_FigureLabel;

NS_ASSUME_NONNULL_BEGIN

@interface Repetition_Figure : NSManagedObject

+ (nullable Repetition_Figure*)findByFigureId:(long)figureId context:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Repetition_Figure+CoreDataProperties.h"
