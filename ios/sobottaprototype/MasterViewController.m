//
//  MasterViewController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MasterViewController.h"

//#import "DetailViewController.h"
#import "HomescreenViewController.h"
#import "AppDelegate.h"
#import "MainSplitViewController.h"
#import "SOBButtonImage.h"
#import "SOBNavigationViewController.h"
#import "GAI.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController


- (void)awakeFromNib
{
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//	    self.clearsSelectionOnViewWillAppear = NO;
//	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
//	}
    dbController = [DatabaseController Current];
    [super awakeFromNib];
    self.title = NSLocalizedString(@"Chapters", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(figureDatasourceDataChangedEvent:) name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    _fullVersionController = [FullVersionController instance];
    NSLog(@"MasterViewController.viewDidLoad (%d)", _chapterId);
    _searchBar.delegate = self;
    Language *lang = [DatabaseController Current].currentLanguage;
    NSLog(@"setting stuff.");
    _figureDatasource = [FigureDatasource defaultDatasource];
    if (_chapter) {
        self.sections = _figureDatasource.sections;
        _searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search in selected chapters (%@)", nil), lang.structureLangLabel];
//        _searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search in %@", nil), _chapter.name];
    } else {
//        _searchBar.placeholder = NSLocalizedString(@"Search in Sobotta Atlas", nil);
        _searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search in all chapters (%@)", nil), lang.structureLangLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Index", nil) style:UIBarButtonItemStylePlain target:self action:@selector(openIndex:)];
    }
    for(UIView *subView in _searchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
//            UITextField *searchField = (UITextField *)subView;
//            searchField.font = [UIFont systemFontOfSize:10];
//            NSLog(@"subview: %@", subView);
            [subView setValue:[NSNumber numberWithBool:YES] forKeyPath:@"_placeholderLabel.adjustsFontSizeToFitWidth"];
            [subView setValue:[NSNumber numberWithInt:5] forKeyPath:@"_placeholderLabel.minimumFontSize"];
            
        }
    }
//    [_searchBar setValue:[NSNumber numberWithBool:YES] forKeyPath:@"_placeholderLabel.adjustsFontSizeToFitWidth"];

    
//    SOBButtonImage *backbtn = [[SOBButtonImage alloc] initButtonOfType:BARBACKBUTTON withImage:nil andText:@"Back"];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backbtn];
    
    if (_homescreen) {
        //self.navigationItem.leftBarButtonItems = @[];
    } else {
        //self.navigationItem.leftItemsSupplementBackButton = YES;
        //UIBarButtonItem* home = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(homeClicked:)];
        //self.navigationItem.leftBarButtonItems = @[home, self.editButtonItem];
        // TODO LH switch main chapter "false && "
        if ( _chapterId) {
            //self.navigationItem.leftBarButtonItems = nil;
//            self.navigationItem.leftBarButtonItems = @[self.navigationItem.backBarButtonItem];
        } else {
            NSLog(@"No back button.");
            //self.navigationItem.leftBarButtonItems = @[home];
            //self.navigationItem.leftBarButtonItems = @[];
        }
        SOBNavigationViewController *sobNavigationViewController = [self.splitViewController.viewControllers lastObject];
        self.detailViewController = [sobNavigationViewController imageGridViewController:NO];

//        self.detailViewController = (ImageGridViewController *)[ topViewController];
    }
    
    if (_chapter) {
        self.title = _chapter.name;
    } else {
        self.title = NSLocalizedString(@"Chapters", nil);
    }

	//UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	//self.navigationItem.rightBarButtonItem = addButton;
}

- (void) figureDatasourceDataChangedEvent: (NSNotification *) notification {
    if (_chapter) {
        self.sections = _figureDatasource.sections;
        [self.tableView reloadData];
    }
}

- (void) openIndex:(id) sender {
    [self performSegueWithIdentifier:@"showIndex" sender:nil];
}

- (void) languageChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void) setHomescreen:(HomescreenViewController *)homescreen {
    _homescreen = homescreen;
//    if (_homescreen) {
//        self.navigationItem.leftBarButtonItems = @[];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_homescreen) {
        SOBNavigationViewController *sobNav = [self.splitViewController.viewControllers lastObject];
        _homescreen = [sobNav.viewControllers objectAtIndex:0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [dbController trackView:_chapter ? [NSString stringWithFormat:@"Navigation/%@", _chapter.nameEnen] : @"Navigation"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    if (!_chapterId) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//	} else {
//	    return YES;
//	}
}

- (void)homeClicked:(id) sender {
    MainSplitViewController *splitViewController = (MainSplitViewController *)self.splitViewController;
    if (splitViewController.leftPopupController) {
        [splitViewController.leftPopupController dismissPopoverAnimated:NO];
    }
    HomescreenViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Homescreen"];
    //    controller
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIViewController *tmpRootController = appDelegate.window.rootViewController;
    [appDelegate.window setRootViewController:controller];
    [appDelegate.window setRootViewController:tmpRootController];
    
    /*
    [UIView beginAnimations:@"suck" context:nil];
    [UIView setAnimationTransition:116 forView:controller.view cache:YES];
    [UIView setAnimationDuration:1];
    [appDelegate.window setRootViewController:tmpRootController];
    [UIView commitAnimations];
     */
    //controller.modalTransitionStyle = 116;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [appDelegate.window.rootViewController presentViewController:controller animated:YES completion:^{
        [tmpRootController dismissViewControllerAnimated:NO completion:nil];
        appDelegate.window.rootViewController = controller;
    }];
    
    
    //[tmpRootController expandView:tmpRootController.view toModalViewController:controller];
    
    /*
    [UIView transitionFromView:tmpRootController.view toView:controller.view duration:2.5 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut | 116) completion:^(BOOL finished){
        if (finished) {
            [appDelegate.window setRootViewController:controller];
            NSLog(@"finished.");
        } else {
            NSLog(@"Unfinished.");
        }
    }];*/

}

- (void)setChapterId:(int)chapterId {
    _chapterId = chapterId;
    _chapter = (Section*) [[dbController chapterMapping] objectForKey:[NSNumber numberWithInt:chapterId]];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sections) {
        return [_sections count];
//        return [_chapter.children count];
    }
	return [[dbController chapterMapping] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_PHONE) {
        if (_chapter) {
            HomescreenViewController *homescreen = (HomescreenViewController*)[self.navigationController.viewControllers objectAtIndex:0];
            homescreen.jumpToSectionPosition = [indexPath indexAtPosition:1];
            [homescreen openCategoriesGallery:_chapterId requestItem:RequestedItemJumpToSection currentViewController:self];
        } else {
            MasterViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
            int chapterId = indexPath.row+1;
            mvc.chapterId = chapterId;
            [_figureDatasource loadForChapterId:chapterId];
            [self.navigationController pushViewController:mvc animated:YES];
        }
        return;
    }
    
    if (_chapter) {
        
        [self.detailViewController jumpToSectionAtPosition:[indexPath indexAtPosition:1]];
        return;
    }
    
    UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
    ImageGridViewController *tmp = (ImageGridViewController *)[[navController viewControllers] lastObject];
    if ([tmp isKindOfClass:[ImageGridViewController class]]) {
        [tmp loadForChapterId:[indexPath indexAtPosition:1]+1];
        [tmp loadMasterView:YES];
        return;
    } else if ([tmp isKindOfClass:[HomescreenViewController class]]) {
        [((HomescreenViewController *)tmp) openCategoriesGallery:(int)[indexPath indexAtPosition:1]+1 requestItem:RequestedItemShowChapter currentViewController:tmp];
        return;
    } else if (_homescreen) {
        [_homescreen openCategoriesGallery:(int)[indexPath indexAtPosition:1]+1 requestItem:RequestedItemShowChapter currentViewController:tmp];
        return;
    } else {
        HomescreenViewController *vc = [navController.viewControllers objectAtIndex:0];
        [navController popToRootViewControllerAnimated:NO];
        [vc openCategoriesGallery:(int)[indexPath indexAtPosition:1]+1 requestItem:RequestedItemShowChapter currentViewController:tmp];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"MasterViewController.prepareForSegue:%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //[[segue destinationViewController] setDetailItem:indexPath];
        [[segue destinationViewController] loadForChapterId:[indexPath indexAtPosition:1]+1];
    }
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (_sections) {
//        Section *section = [_chapter.sortedChildren objectAtIndex:[indexPath indexAtPosition:1]];
        //SectionInfo *sectionInfo = [_sections objectAtIndex:[indexPath indexAtPosition:1]];
        if (!_detailViewController) {
            NSLog(@"detail view controller is nil?!");
        }
        SectionInfo *sectionInfo = [_figureDatasource sectionAtIndex:[indexPath indexAtPosition:1]];
        NSString *sectionName = nil;
        if (sectionInfo) {
            NSDictionary *mapping = [dbController chapterMapping];
            Section *section = [mapping objectForKey:sectionInfo.chapterId];
            Section *s = [section.children objectForKey:sectionInfo.sectionId];
            cell.textLabel.enabled = [_fullVersionController allowShowSection:sectionInfo];
            sectionName = s.name;
        }
        cell.textLabel.text = sectionName;
        //cell.textLabel.text = sectionInfo.name;
    } else {
        NSString *chapterName = [dbController chapterNameById:[indexPath indexAtPosition:1]+1];
        int chapterNumber = [indexPath indexAtPosition:1]+1;
        cell.textLabel.text = [NSString stringWithFormat:@"%d %@", chapterNumber, chapterName];
    }
}

- (void)setSections:(NSArray *)sections {
    _sections = sections;
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}


#pragma mark UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (!_chapter) {
        if (IS_PHONE) {
            [_figureDatasource loadForChapterId:0];
            [self performSegueWithIdentifier:@"openSearch" sender:self];
            return NO;
        }
        if (!_detailViewController) {
            [_homescreen openCategoriesGallery:0 requestItem:RequestedItemSearchWithinMasterview currentViewController:nil];
            return NO;
        }
        [[FigureDatasource defaultDatasource] loadForChapterId:0];
    }
    [self performSegueWithIdentifier:@"openSearch" sender:self];
    return NO;
}

@end
