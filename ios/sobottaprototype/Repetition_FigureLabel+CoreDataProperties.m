//
//  Repetition_FigureLabel+CoreDataProperties.m
//  sobottaprototype
//
//  Created by Herbert Poul on 02/10/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "Repetition_FigureLabel+CoreDataProperties.h"

@implementation Repetition_FigureLabel (CoreDataProperties)

+ (NSFetchRequest<Repetition_FigureLabel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Repetition_FigureLabel"];
}

@dynamic active;
@dynamic easefactor;
@dynamic figure_label_id;
@dynamic figure_label_order;
@dynamic interval;
@dynamic lastanswered;
@dynamic lastscheduled;
@dynamic session_step;
@dynamic type;
@dynamic due;
@dynamic figure;

@end
