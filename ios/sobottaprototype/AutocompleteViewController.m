//
//  AutocompleteViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "AutocompleteViewController.h"
#import "ImageGridViewController.h"
#import "MainSplitViewController.h"
#import "SOBNavigationViewController.h"
#import "Contest100Provider.h"
#import "InAppMessageController.h"

@interface AutocompleteViewController ()

@end

@implementation AutocompleteViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _searched = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];

	// Do any additional setup after loading the view.
//    ImageGridViewController* igvc = [[((MainSplitViewController *)self.splitViewController) sobNavigationViewController] imageGridViewController:NO];
    _figureDatasource = [FigureDatasource defaultDatasource];
    Language *lang = [DatabaseController Current].currentLanguage;
    
    if (_figureDatasource.chapterId) {
//        NSString *chapterName = [[DatabaseController Current] chapterNameById:_figureDatasource.chapterId];
        _searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search in selected chapters (%@)", nil), lang.structureLangLabel];
    } else {
        _searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search in all chapters (%@)", nil), lang.structureLangLabel];
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
}

- (void) languageChanged:(NSNotification*) notification {
    [self filterResultsUsingString:_searchQuery];
}

- (void)viewDidAppear:(BOOL)animated {
    [_searchBar becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 640);
}

#pragma mark UITableViewDataSource methods


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int count = 0;
    if (results) {
        count = [results count];
    }
    if (_searched && count < 1) {
        // show a no results view.
        count = 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ((!results || [results count] < 1) && _searched) {
        if (_figureDatasource.chapterId) {
            NSString *chapterName = [[DatabaseController Current] chapterNameById:_figureDatasource.chapterId];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"No Results in \"%@\"", nil), chapterName];
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Results", nil);
        }
    }
    if (indexPath.row < [results count]) {
        cell.textLabel.text = [results objectAtIndex:indexPath.row];
    } else {
        NSLog(@"ERROR - cellForRowAtIndexPath: index path is bigger than result count.");
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= results.count) {
        NSLog(@"ERROR - didSelectRowAtIndexPath: index path is bigger than result count.");
        return;
    }
    NSString *label = [results objectAtIndex:indexPath.row];
    _searchBar.text = label;
    [self updateSearchText:label];
    if (IS_PHONE) {
        ImageGridViewController *igvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageGridViewController"];
        [self.navigationController pushViewController:igvc animated:YES];
    } else {
        [((MainSplitViewController *)self.splitViewController) dismissLeftPopoverAnimated:YES];
    }
}

- (void) filterResultsUsingString: (NSString*)searchText {
    _searchQuery = searchText;
    NSString *currentSearch = [_searchQuery copy];
    DatabaseController *dbController = [DatabaseController Current];
    FMDatabaseQueue *queue = [dbController contentDatabaseQueue];
    
    if (searchText.length < 2) {
        _searched = NO;
        results = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }
    [_searchBar startActivity];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSMutableArray *tmpresults = [NSMutableArray array];
        [queue inDatabase:^(FMDatabase *db) {
            if (![currentSearch isEqualToString:_searchQuery]) {
                NSLog(@"user already entered another search. ignore results.");
                return;
            }

            NSString *query = nil;
            // always search global!
            if (_figureDatasource.chapterId) {
                query = [NSString stringWithFormat:@"SELECT DISTINCT text_%@_normalized FROM label INNER JOIN figure ON figure.id = label.figure_id INNER JOIN outline ON outline.chapter_id = figure.chapter_id WHERE text_%@_normalized LIKE ? AND outline.level1_id = ? ORDER BY text_%@_normalized LIMIT 40", dbController.langcolname, dbController.langcolname, dbController.langcolname];
            } else {
                query = [NSString stringWithFormat:@"SELECT DISTINCT text_%@_normalized FROM label WHERE text_%@_normalized LIKE ? ORDER BY text_%@_normalized LIMIT 40", dbController.langcolname, dbController.langcolname, dbController.langcolname];
            }
            NSString *search = [NSString stringWithFormat:@"%%%@%%", _searchQuery];
            FMResultSet *res = [db executeQuery:query
                           withArgumentsInArray:(_figureDatasource.chapterId ?
                                                 @[search, [NSNumber numberWithInt:_figureDatasource.chapterId]] : @[search])];
            while([res next]) {
                [tmpresults addObject:[res stringForColumnIndex:0]];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchBar finishActivity];
            if (![currentSearch isEqualToString:_searchQuery]) {
                NSLog(@"user already entered another search. ignore results.");
                return;
            }

            _searched = YES;
            results = tmpresults;
            [self.tableView reloadData];
        });
    });
}



#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchText:searchText];
}

- (void)updateSearchText:(NSString*)searchText {
    if ([searchText length] < 2) {
        searchText = @"";
    }
    if ([[searchText lowercaseString] isEqualToString:@"xxcontest"]) {
        Contest100Provider *contest = [Contest100Provider defaultProvider];
        [contest forceEnableContest];
        [[[UIAlertView alloc] initWithTitle:@"Enabled contest." message:@"Enabled contest." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (IS_PHONE) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else if ([[searchText lowercaseString] isEqualToString:@"xxiam"]) {
        if (IS_PHONE) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [((MainSplitViewController *)self.splitViewController) dismissLeftPopoverAnimated:YES];
            SOBNavigationViewController *sobNavController = [[self.splitViewController viewControllers] objectAtIndex:1];
            [sobNavController popToRootViewControllerAnimated:YES];
        }
        [[InAppMessageController instance] showNewTestMessages:self.view];
    }
    BOOL changed = YES;
    if (_figureDatasource.searchText == nil) {
        if ([searchText length] < 1) {
            changed = NO;
        }
    } else if ([_figureDatasource.searchText isEqualToString:searchText]) {
        changed = NO;
    }
    if (changed) {
        [self filterResultsUsingString:searchText];
        [_searchBar startActivity];
        [self performSelector:@selector(updateFigureDatasourceSearchText:) withObject:searchText afterDelay:0.5];
    }
}

- (void) updateFigureDatasourceSearchText:(NSString *)searchText {
    [_searchBar finishActivity];
    if (searchText == _searchQuery) {
        NSLog(@"updating datasource search text: %@", searchText);
        _figureDatasource.searchText = searchText;
    } else {
        NSLog(@"NOT updating datasource (%@ vs. %@)", searchText, _searchQuery);
    }
}

@end
