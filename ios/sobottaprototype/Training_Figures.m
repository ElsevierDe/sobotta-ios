//
//  Training_Figures.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Training_Figures.h"
#import "Training.h"
#import "Training_Figure_Labels.h"


@implementation Training_Figures

@dynamic completed;
@dynamic figure_id;
@dynamic order;
@dynamic amount_correct;
@dynamic amount_wrong;
@dynamic percent_correct;
@dynamic labels;
@dynamic training;

+ (NSFetchRequest<Training_Figures *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"Training_Figures"];
}


+ (Training_Figures *)findByFigureId:(long)figureId context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [Training_Figures fetchRequest];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"figure_id = %ld", figureId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // handle error
        NSLog(@"Error fetching objects %@", error);
    }
    return fetchedObjects.count > 0 ? fetchedObjects[0] : nil;
}


@end
