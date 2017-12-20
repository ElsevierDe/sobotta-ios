//
//  Repetition_Figure+CoreDataProperties.m
//  sobottaprototype
//
//  Created by Herbert Poul on 01/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "Repetition_Figure+CoreDataProperties.h"

@implementation Repetition_Figure (CoreDataProperties)

+ (NSFetchRequest<Repetition_Figure *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Repetition_Figure"];
}

@dynamic figure_id;
@dynamic label_count;
@dynamic order;
@dynamic synced;
@dynamic labels;
@dynamic last_training;

@end
