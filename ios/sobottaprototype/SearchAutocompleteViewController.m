//
//  SearchAutocompleteViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/22/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SearchAutocompleteViewController.h"
#import "MainSplitViewController.h"
#import "SOBNavigationViewController.h"
#import "ImageGridViewController.h"

@interface SearchAutocompleteViewController ()

@end

@implementation SearchAutocompleteViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = NSLocalizedString(@"Search Results", nil);
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 280.0);
    [self filterResultsUsingString:@""];
    
    ImageGridViewController* igvc = [[((MainSplitViewController *)self.splitViewController) sobNavigationViewController] imageGridViewController:NO];
    _figureDatasource = igvc.figureDatasource;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (results) {
        return [results count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [results objectAtIndex:indexPath.row];


    
    return cell;
}

- (void) filterResultsUsingString: (NSString*)searchText {
    _searchQuery = searchText;
    DatabaseController *dbController = [DatabaseController Current];
    FMDatabaseQueue *queue = [dbController contentDatabaseQueue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [queue inDatabase:^(FMDatabase *db) {
            results = [NSMutableArray array];
            
            NSString *query = nil;
            if (_chapterId) {
                query = [NSString stringWithFormat:@"SELECT DISTINCT text_%@ FROM label INNER JOIN figure ON figure.id = label.figure_id INNER JOIN outline ON outline.chapter_id = figure.chapter_id WHERE text_%@ LIKE ? AND outline.level1_id = ? ORDER BY text_%@ LIMIT 40", dbController.langcolname, dbController.langcolname, dbController.langcolname];
            } else {
                query = [NSString stringWithFormat:@"SELECT DISTINCT text_%@ FROM label WHERE text_%@ LIKE ? ORDER BY text_%@ LIMIT 40", dbController.langcolname, dbController.langcolname, dbController.langcolname];
            }
            NSString *search = [NSString stringWithFormat:@"%%%@%%", _searchQuery];
            FMResultSet *res = [db executeQuery:query
                           withArgumentsInArray:(_chapterId ?
                                @[search, [NSNumber numberWithInt:_chapterId]] : @[search])];
            while([res next]) {
                [results addObject:[res stringForColumnIndex:0]];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    int pos = [indexPath indexAtPosition:1];
    
}

@end
