//
//  MyNotesCategoriesTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNotesCategoriesTableViewController : UITableViewController {
    NSManagedObjectContext *_managedObjectContext;
    
    NSArray *_data;
//    int _level;
}

@property (strong, nonatomic) NSIndexPath* categoryIndexPath;
@property (strong, nonatomic) NSArray *labelids;
@property (strong, nonatomic) NSString *currentLabel;

@end
