//
//  MyNotesCategoriesTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MyNotesCategoriesTableViewController.h"

#import "AppDelegate.h"
#import "DatabaseController.h"
#import "MyNotesNoteViewController.h"
#import "MyNotesRootViewController.h"

@interface MyNotesCategoriesTableViewController ()

@end

@implementation MyNotesCategoriesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _data = [NSMutableArray array];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)loadData {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
	_managedObjectContext = app.managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"label_id"]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [_managedObjectContext executeFetchRequest:request error:&error];
    if (objects) {
        if (!_labelids) {
            NSMutableArray* labelids = [NSMutableArray array];
            for (id object in objects) {
                NSLog(@"label_id: %@", [object objectForKey:@"label_id"]);
                [labelids addObject:[object objectForKey:@"label_id"]];
            }
            _labelids = labelids;
        }
        NSString *tmp = nil;
        if ([_labelids count] > 0) {
            tmp = [@"" stringByPaddingToLength:[_labelids count]*2-1 withString:@"?," startingAtIndex:0];
            tmp = [NSString stringWithFormat:@" l.id IN (%@) ", tmp];
        } else {
            tmp = @" 1 = 2 ";
        }
    
        DatabaseController *db = [DatabaseController Current];
        NSString *sql = nil;
        if (!_categoryIndexPath) {
            sql = [NSString stringWithFormat:@"select distinct o1.chapter_id,o1.name_%@ from outline o1 inner join outline o2 ON o1.chapter_id = o2.level1_id inner join figure f on f.chapter_id = o2.chapter_id inner join label l on l.figure_id = f.id where %@", db.langcolname, tmp];
        } else if ([_categoryIndexPath length] == 1) {
            sql = [NSString stringWithFormat:@"select distinct o1.chapter_id,o1.name_%@ from outline o1 inner join outline o2 ON o1.chapter_id = o2.level2_id inner join figure f on f.chapter_id = o2.chapter_id inner join label l on l.figure_id = f.id where %@ AND o2.level  = 3 AND o2.level1_id = %d", db.langcolname, tmp, [_categoryIndexPath indexAtPosition:0]];
        } else if ([_categoryIndexPath length] == 2) {
            sql = [NSString stringWithFormat:@"select distinct f.id, f.shortlabel_%@ || ' ' || f.longlabel_%@ from figure f inner join outline o on o.chapter_id = f.chapter_id inner join label l on l.figure_id = f.id where %@ AND o.level2_id = %d", db.langcolname, db.langcolname, tmp, [_categoryIndexPath indexAtPosition:1]];
        }
        FMDatabaseQueue *fmqueue = [db contentDatabaseQueue];
        NSLog(@"running sql: %@ with data: %@", sql, _labelids);
        [fmqueue inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:sql withArgumentsInArray:_labelids];
            NSMutableArray *newdata = [NSMutableArray array];
            while ([result next]) {
                NSLog(@"newdata: %@", [result stringForColumnIndex:1]);
                [newdata addObject:@{ @"id": [result objectForColumnIndex:0], @"label": [result stringForColumnIndex:1] }];
            }
            _data = newdata;
        }];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"My Notes", nil);
    if (_currentLabel) {
        self.title = _currentLabel;
    }

    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)languageChanged: (NSNotification *)notification {
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[_data objectAtIndex:indexPath.row] objectForKey:@"label"];
    
    return cell;
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
    NSIndexPath* categoryIndexPath = nil;
    
    NSNumber *categoryId = [[_data objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSString *label = [[_data objectAtIndex:indexPath.row] objectForKey:@"label"];
    if (!_categoryIndexPath) {
        categoryIndexPath = [NSIndexPath indexPathWithIndex:[categoryId intValue]];
    } else if ([_categoryIndexPath length] == 1) {
        NSUInteger arr[] = {[_categoryIndexPath indexAtPosition:0], [categoryId intValue]};
        categoryIndexPath = [NSIndexPath indexPathWithIndexes:arr length:2];
    } else if ([_categoryIndexPath length] == 2) {
        MyNotesNoteViewController *note = [self.storyboard instantiateViewControllerWithIdentifier:@"MyNotesNoteView"];
        note.figureLabel = label;
        note.figureId = categoryId;
        note.labelids = _labelids;
        NSLog(@"parentView: %@", [self.navigationController parentViewController]);
        if (IS_PHONE) {
            [self.navigationController pushViewController:note animated:YES];
        } else {
            MyNotesRootViewController *rvc = (MyNotesRootViewController *)[self.navigationController parentViewController];
            rvc.rightController = note;
        }
        return;
    }

    MyNotesCategoriesTableViewController *nextLevel = [self.storyboard instantiateViewControllerWithIdentifier:@"MyNotesCategories"];
    nextLevel.categoryIndexPath = categoryIndexPath;
    nextLevel.labelids = _labelids;
    nextLevel.currentLabel = label;
    [self.navigationController pushViewController:nextLevel animated:YES];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
