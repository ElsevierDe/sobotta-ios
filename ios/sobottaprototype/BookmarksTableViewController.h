//
//  BookmarksTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/16/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Bookmarklist.h"
#import "BookmarkListEditViewController.h"
#import "SOBButtonImage.h"


@protocol BookmarksDelegate <NSObject>

- (void) openFiguresForBookmarkList:(Bookmarklist *)bookmarkList;

@end

@interface BookmarksTableViewController : UITableViewController<NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_controller;
    

}

- (UITableViewCell *) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic) BOOL allowBookmarkListEditing;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) id<BookmarksDelegate> bookmarksDelegate;
@property (nonatomic) BOOL showSmartBookmarklists;

@end
