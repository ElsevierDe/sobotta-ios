//
//  ImageGridHeaderActionViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureDatasource.h"
#import "BookmarksTableViewController.h"
#import "CrazyButton.h"


@class ImageGridHeaderView;
@interface ImageGridHeaderActionViewController : UITableViewController<BookmarksDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *cellStartTraining;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAddToBookmarks;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellRemoveFromBookmarks;

@property (nonatomic) FigureDatasource *figureDatasource;
@property (nonatomic) NSUInteger sectionIdx;
@property (weak, nonatomic) ImageGridHeaderView * imageGridHeaderView;

@end
