//
//  AutocompleteViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureDatasource.h"
#import "SearchBarWithActivity.h"

@interface AutocompleteViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    FigureDatasource *_figureDatasource;
    NSString *_searchQuery;
    NSMutableArray* results;
    BOOL _searched;
}


@property (weak, nonatomic) IBOutlet SearchBarWithActivity *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
