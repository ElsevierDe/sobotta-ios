//
//  ImageActionsViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageActionsViewController.h"
#import "ImageViewController.h"
#import "Bookmark.h"

@interface ImageActionsViewController ()

@end

@implementation ImageActionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.contentSizeForViewInPopover = CGSizeMake(320, 100);
//    [_addToBookmarksButton setTitle:NSLocalizedString(@"Add to Bookmarks", nil) forState:UIControlStateNormal];
//    [_printButton setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
    _cellAddToBookmarks.textLabel.text = NSLocalizedString(@"Add to Bookmarks", nil);
    //_cellPrint.textLabel.text = NSLocalizedString(@"Print", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
}


- (IBAction)startPrinting:(id)sender {
    [self.sobParentController dismissPopovers:nil];
    [[self.sobParentController imageViewController] startPrinting:self.sobParentController.actionsButton];
}

- (void)viewDidUnload
{
//    [self setAddToBookmarksButton:nil];
//    [self setPrintButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (IBAction)addToBookmarks:(id)sender {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *vc = [main instantiateInitialViewController];
    BookmarksTableViewController *bookmarks = (BookmarksTableViewController*)vc.topViewController;
    bookmarks.bookmarksDelegate = self;
    
    [self.navigationController pushViewController:bookmarks animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue ...");
}

- (void)openFiguresForBookmarkList:(Bookmarklist *)bookmarkList {
    ImageViewController *ivc = [_sobParentController imageViewController];
    FigureInfo *figure = [ivc.datasource getCurrentSelection];
    
    [ivc.datasource addFigure:figure toBookmarklist:bookmarkList];
    
    [_sobParentController dismissPopovers:nil];

}

#pragma mark - UITableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == _cellAddToBookmarks) {
        [self addToBookmarks:nil];
    } /*else if (cell == _cellPrint) {
        [self startPrinting:nil];
    }*/
}

@end
