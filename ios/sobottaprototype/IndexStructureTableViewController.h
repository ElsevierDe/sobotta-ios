//
//  IndexStructureTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/3/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DatabaseController.h"
#import "FigureDatasource.h"

@interface IndexStructureTableViewController : UITableViewController {
    DatabaseController *_databaseController;
    NSArray *_labelGroups;
    NSMutableArray *_loadqueue;
}

@end

@interface LabelGroup : NSObject {
}

@property (nonatomic) long idval;
@property (nonatomic, strong) NSString *label;
@property (nonatomic) int count;
@property (nonatomic, strong) NSMutableDictionary *labels;

@end
