//
//  TrainingResultsTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TrainingResultsTableViewController : UITableViewController<NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_controller;
    
    NSDateFormatter *_dateFormatter;
}

@end
