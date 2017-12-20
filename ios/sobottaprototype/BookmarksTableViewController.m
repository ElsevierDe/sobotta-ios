//
//  BookmarksTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/16/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "SOBButtonImage.h"
#import "SOBNavigationViewController.h"
#import "FakeBookmarklist.h"

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController
@synthesize toolbar;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _showSmartBookmarklists = NO;
        _allowBookmarkListEditing = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmarklist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deleted == %@", [NSNumber numberWithBool:NO]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    _controller = [[NSFetchedResultsController alloc]
                  initWithFetchRequest:fetchRequest
                  managedObjectContext:_managedObjectContext
                  sectionNameKeyPath:nil
                  cacheName:nil];
    _controller.delegate = self;
    
    NSError *error = nil;
    [_controller performFetch:&error];
    
    // check if there is already a bookmark list.. and if not, create a default one ..
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_controller sections] objectAtIndex:0];
    if (sectionInfo) {
        if ([sectionInfo numberOfObjects] == 0) {
            Bookmarklist *list = (Bookmarklist *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmarklist"inManagedObjectContext:app.managedObjectContext ];
            list.name = NSLocalizedString(@"My Training List", @"default name for first bookmark list.");
            list.updated = [NSDate date];
            [app.managedObjectContext save:&error];
            [_controller performFetch:&error];

        }
    }

    
    self.title = NSLocalizedString(@"Bookmark Lists", nil);
    
    //self.editButtonItem;
    
    
    if (_allowBookmarkListEditing) {
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        UIBarButtonItem* newButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(newPressed:)];
        [self.navigationItem setLeftBarButtonItems:@[newButton] animated:animated];
    } else {
        if (IS_PHONE) {
            [(SOBNavigationViewController *)self.navigationController updateNavigationButtonItems:self];
        } else {
            [self.navigationItem setLeftBarButtonItems:@[] animated:animated];
        }
    }
}


- (void)newPressed:(id) sender {
    [self performSegueWithIdentifier:@"newBookmarkList" sender:nil];
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"newBookmarkList"]) {
        if (sender) {
            BookmarkListEditViewController *c = [segue destinationViewController];
            c.bookmarkList = sender;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_controller sections] count] + (_showSmartBookmarklists ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1) {
        return 1;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_controller sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];

    
    return cell;
}

- (UITableViewCell *) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    // Configure the cell...
    
    if (indexPath.section == 0) {
        Bookmarklist *obj = [_controller objectAtIndexPath:indexPath];
        //cell.hidden = [obj.deleted boolValue];
        cell.textLabel.text = obj.name;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Trained below 60%", nil);
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Your Bookmarklists", nil);
    } else {
        return NSLocalizedString(@"Automatic Bookmarklists", nil);
    }
}

- (void)setShowSmartBookmarklists:(BOOL)showSmartBookmarklists {
    if (_showSmartBookmarklists != showSmartBookmarklists) {
        _showSmartBookmarklists = showSmartBookmarklists;
        [self.tableView reloadData];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
 */

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        Bookmarklist *list = [_controller objectAtIndexPath:indexPath];
        list.deleted = [NSNumber numberWithBool:YES];
//        [_managedObjectContext deleteObject:list];
        [_managedObjectContext save:nil];
        
        
        // no idea why i have to do this by hand here, instead that the controller notifies me automatically.
        [_controller performFetch:nil];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];

        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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
    if (indexPath.section == 0) {
        NSLog(@"didSelectRowAtIndexPath");
        Bookmarklist *list = [_controller objectAtIndexPath:indexPath];
        if (self.isEditing) {
            [self performSegueWithIdentifier:@"newBookmarkList" sender:list];
            return;
        }
        if (_bookmarksDelegate) {
            [_bookmarksDelegate openFiguresForBookmarkList:list];
        }
    } else {
        if (self.isEditing) {
            return;
        }
        if (_bookmarksDelegate) {
            FakeBookmarklist *list = [[FakeBookmarklist alloc] init];
            list.type = FakeBookmarklistTypeBelow60Percent;
            [_bookmarksDelegate openFiguresForBookmarkList:list];
        }
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
    NSLog(@"controllerWillChangeContent");
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSLog(@"didChangeSection");
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"didChangeObject");
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"fetched results deleted.");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Fetched results update.");
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}



- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 320);
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 320);
}

@end
