//
//  ImageGridHeaderActionViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridHeaderActionViewController.h"
#import "Bookmark.h"
#import "Bookmarklist.h"
#import "ImageGridHeaderView.h"
#import "ImageViewController.h"
#import "ImageGridViewController.h"
#import "SOBNavigationViewController.h"
#import "FakeBookmarklist.h"

@interface ImageGridHeaderActionViewController ()

@end

@implementation ImageGridHeaderActionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [_figureDatasource sectionTitleAtIndex:_sectionIdx];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
//    [self.startTrainingButton setTitle:NSLocalizedString(@"Start Training", nil) forState:UIControlStateNormal];
//    [self.addToBookmarksButton setTitle:NSLocalizedString(@"Add to Bookmarks", nil) forState:UIControlStateNormal];
//    [self.removeFromBookmarksButton setTitle:NSLocalizedString(@"Remove Bookmarks", nil) forState:UIControlStateNormal];
    
    _cellStartTraining.textLabel.text =NSLocalizedString(@"Start Training", nil);
    _cellAddToBookmarks.textLabel.text =NSLocalizedString(@"Add to Bookmarks", nil);
    _cellRemoveFromBookmarks.textLabel.text =NSLocalizedString(@"Remove Bookmarks", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_figureDatasource.bookmarkList || [_figureDatasource.bookmarkList isKindOfClass:[FakeBookmarklist class]]) {
//        self.removeFromBookmarksButton.hidden = YES;
        _cellRemoveFromBookmarks.hidden = YES;
    }
}

- (void)viewDidUnload
{
//    [self setStartTrainingButton:nil];
//    [self setAddToBookmarksButton:nil];
//    [self setRemoveFromBookmarksButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startTraining:(id)sender {
    [self.imageGridHeaderView dismissPopovers];

    [self.imageGridHeaderView.imageGridViewController startTrainingForSectionIdx:_sectionIdx];
}


- (IBAction)addToBookmarklist:(id)sender {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *vc = [main instantiateInitialViewController];
    BookmarksTableViewController *bookmarks = (BookmarksTableViewController*)vc.topViewController;
    bookmarks.bookmarksDelegate = self;

    [self.navigationController pushViewController:bookmarks animated:YES];

}

- (IBAction)removeFromBookmarklist:(id)sender {
    [_imageGridHeaderView dismissPopovers];
    
    [_figureDatasource removeFiguresOfSectionIdx:_sectionIdx fromBookmarkList:_figureDatasource.bookmarkList];
    
    [_figureDatasource reloadData];
}



- (CGSize)contentSizeForViewInPopover {
    if (!_figureDatasource.bookmarkList) {
        return CGSizeMake(320, 90);
    } else {
        return CGSizeMake(320, 140);
    }
}

- (void)openFiguresForBookmarkList:(Bookmarklist *)bookmarkList {
    [self addFiguresIntoBookmarkList:bookmarkList];
    [self.imageGridHeaderView dismissPopovers];

}
- (void)addFiguresIntoBookmarkList:(Bookmarklist *)bookmarkList {
    [_figureDatasource addFiguresOfSectionIdx:_sectionIdx intoBookmarkList:bookmarkList];
}

#pragma mark - UITableViewController

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == _cellStartTraining) {
        [self startTraining:nil];
    } else if (cell == _cellAddToBookmarks) {
        [self addToBookmarklist:nil];
    } else if (cell == _cellRemoveFromBookmarks) {
        [self removeFromBookmarklist:nil];
    }
}

@end
