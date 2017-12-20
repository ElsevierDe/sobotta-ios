//
//  ImageActionsViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOBNavigationViewController.h"
#import "CrazyButton.h"


@interface ImageActionsViewController : UITableViewController<BookmarksDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *cellAddToBookmarks;
//@property (weak, nonatomic) IBOutlet UITableViewCell *cellPrint;
@property (weak, nonatomic) SOBNavigationViewController *sobParentController;

@end
