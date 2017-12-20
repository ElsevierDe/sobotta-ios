//
//  Repetition_Figure+CoreDataClass.m
//  sobottaprototype
//
//  Created by Herbert Poul on 26/09/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "Repetition_Figure+CoreDataClass.h"
#import "Repetition_FigureLabel+CoreDataClass.h"

@implementation Repetition_Figure

+ (Repetition_Figure *)findByFigureId:(long)figureId context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [Repetition_Figure fetchRequest];
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
