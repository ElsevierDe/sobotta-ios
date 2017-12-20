//
//  MasterViewController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseController.h"
#import "ImageGridViewController.h"
#import "UIViewController+Transitions.h"
#import "FullVersionController.h"

@class DetailViewController;
@class HomescreenViewController;

@interface MasterViewController : UITableViewController<UISearchBarDelegate> {
    DatabaseController *dbController;
    Section *_chapter;
    FigureDatasource *_figureDatasource;
    FullVersionController *_fullVersionController;
}

/* only set when launched from homescreen */
@property (weak, nonatomic) HomescreenViewController *homescreen;
@property (strong, nonatomic) ImageGridViewController *detailViewController;
@property (nonatomic) int chapterId;
@property (strong, nonatomic) NSArray *sections;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end
