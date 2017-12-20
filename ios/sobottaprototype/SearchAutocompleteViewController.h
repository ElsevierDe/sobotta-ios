//
//  SearchAutocompleteViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/22/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseController.h"
#import "FigureDatasource.h"

@class ImageGridViewController;

@interface SearchAutocompleteViewController : UITableViewController<UITableViewDelegate> {
    NSString *_searchQuery;
    
    NSMutableArray *results;
    FigureDatasource* _figureDatasource;
}


@property (weak, nonatomic) ImageGridViewController *imageGrid;
@property (nonatomic) int chapterId;

- (void) filterResultsUsingString: (NSString*)searchText;

@end
