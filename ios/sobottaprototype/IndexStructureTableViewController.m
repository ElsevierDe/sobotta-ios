//
//  IndexStructureTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/3/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "IndexStructureTableViewController.h"
#import "HomescreenViewController.h"
#import "ImageGridViewController.h"
#import "MainSplitViewController.h"

@interface IndexStructureTableViewController ()

@end

@implementation IndexStructureTableViewController

#define BATCHREADS_AFTER 30
#define BATCHREADS_BEFORE 50

#define ASYNC_LOAD

void logMachTime_withIdentifier_f(uint64_t machTime, NSString *identifier) {
    static double timeScaleSeconds = 0.0;
    if (timeScaleSeconds == 0.0) {
        mach_timebase_info_data_t timebaseInfo;
        if (mach_timebase_info(&timebaseInfo) == KERN_SUCCESS) {    // returns scale factor for ns
            double timeScaleMicroSeconds = ((double) timebaseInfo.numer / (double) timebaseInfo.denom) / 1000;
            timeScaleSeconds = timeScaleMicroSeconds / 1000000;
        }
    }
    
    NSLog(@"%@: %g seconds", identifier, timeScaleSeconds*machTime);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _labelGroups = nil;
    _databaseController = [DatabaseController Current];
    _loadqueue = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadLabelGroups];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    _labelGroups = nil;
    _loadqueue = [NSMutableArray array];
    [self loadLabelGroups];
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - loading data

- (void) loadLabelGroups {
    FMDatabaseQueue *queue = [_databaseController contentDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = @"SELECT id, grouplabel, count FROM labelindex WHERE langcol = ? ORDER BY sortorder";
        FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[_databaseController.langcolname]];
        NSMutableArray *labelGroups = [NSMutableArray arrayWithCapacity:27];
        while ([rs next]) {
            LabelGroup *g = [[LabelGroup alloc] init];
            g.idval = [rs longForColumnIndex:0];
            g.label = [rs stringForColumnIndex:1];
            g.count = [rs intForColumnIndex:2];
            [labelGroups addObject:g];
        }
        _labelGroups = labelGroups;
    }];
}

- (void) loadLabelsForGroup:(LabelGroup *)lg forIndexPath:(NSIndexPath *)idx {
    FMDatabaseQueue *queue = [_databaseController contentDatabaseQueue];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:BATCHREADS_AFTER+BATCHREADS_BEFORE];

    
    [queue inDatabase:^(FMDatabase *db) {
        uint64_t startTime, stopTime1, stopTime2;
        startTime = mach_absolute_time();
        int startindex = MAX(0, idx.row - BATCHREADS_AFTER);
        NSLog(@"Loading labels for %@ starting at %d starting at %d", lg.label, idx.row, startindex);
        NSString *query = [NSString stringWithFormat:@"SELECT id, text FROM labelunique WHERE labelgroup_id = ? ORDER BY text LIMIT %d OFFSET %d", (BATCHREADS_AFTER + BATCHREADS_BEFORE),  startindex];
        FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[[NSNumber numberWithInt:lg.idval]]];
        stopTime1 = mach_absolute_time();
        NSMutableDictionary *labels = lg.labels;
        if (!labels) {
            labels = lg.labels = [NSMutableDictionary dictionaryWithCapacity:lg.count];
        }
        int i = startindex;
        while ([rs next]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:idx.section]];
            [labels setObject:[rs stringForColumnIndex:1] forKey:[NSNumber numberWithInt:i]];
            i++;
        }
        stopTime2 = mach_absolute_time();
        logMachTime_withIdentifier_f(stopTime1 - startTime, @"duration for query");
        logMachTime_withIdentifier_f(stopTime2 - stopTime1, @"duration for walking through result set.");
    }];
#ifdef ASYNC_LOAD
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        for (NSIndexPath *tmpIndexPath in indexPaths) {
            UITableViewCell *tmp = [self.tableView cellForRowAtIndexPath:tmpIndexPath];
            if (tmp) {
                NSString *labelstr = [lg.labels objectForKey:[NSNumber numberWithInt:tmpIndexPath.row]];
//                NSLog(@"setting cellForRowAtIndex: %d / %d to %@", tmpIndexPath.section, tmpIndexPath.row, labelstr);
                tmp.textLabel.text = labelstr;
            }
        }
//        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    });
#endif
    
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    LabelGroup *g = [_labelGroups objectAtIndex:section];
    return g.label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_labelGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    LabelGroup *g = [_labelGroups objectAtIndex:section];
    return g.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    LabelGroup *lg = [_labelGroups objectAtIndex:indexPath.section];
    NSString *labelstr = nil;
    if (lg.labels) {
        labelstr = [lg.labels objectForKey:[NSNumber numberWithInt:indexPath.row]];
    }
//    NSString *labelstr = [lg.labels objectAtIndex:indexPath.row];
    if (!labelstr) {
        BOOL inloadqueue = NO;
#ifdef ASYNC_LOAD
        for (NSIndexPath *tmp in _loadqueue) {
            if (tmp.section == indexPath.section) {
                if (tmp.row - BATCHREADS_BEFORE <= indexPath.row && tmp.row + BATCHREADS_AFTER >= indexPath.row) {
                    inloadqueue = YES;
                    break;
                }
            }
        }
#endif
        if (!inloadqueue) {
            [_loadqueue addObject:indexPath];
            
#ifndef ASYNC_LOAD
            [self loadLabelsForGroup:lg forIndexPath:indexPath];
            
            labelstr = [lg.labels objectForKey:[NSNumber numberWithInt:indexPath.row]];
#endif

#ifdef ASYNC_LOAD
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                     (unsigned long)NULL), ^(void) {
                [self loadLabelsForGroup:lg forIndexPath:indexPath];
            });
#endif
        }
//        labelstr = [lg.labels objectForKey:[NSNumber numberWithInt:indexPath.row]];
        cell.textLabel.text = @" ";
    } else {
        cell.textLabel.text = labelstr;
    }
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.minimumFontSize = 14;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[_labelGroups count]];
    for (LabelGroup *g in _labelGroups) {
        [ret addObject:g.label];
//        return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R"];
    }
    return ret;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LabelGroup *lg = [_labelGroups objectAtIndex:indexPath.section];
    NSString *labelstr = nil;
    if (lg.labels) {
        labelstr = [lg.labels objectForKey:[NSNumber numberWithInt:indexPath.row]];
    }
    if (labelstr) {
        FigureDatasource *ds = [FigureDatasource defaultDatasource];
        [ds loadForGlobalSearchText:labelstr];
        
        if (IS_PHONE) {
            HomescreenViewController *homescreen = [self.navigationController.viewControllers objectAtIndex:0];
            [homescreen openImageGridNoPopNavController:YES];
            return;
        }
        
        UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
        HomescreenViewController *homescreen = [navController.viewControllers objectAtIndex:0];
        [homescreen openImageGrid];
        [((MainSplitViewController *)self.splitViewController) dismissLeftPopoverAnimated:YES];
        
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end


@implementation LabelGroup

- (id)init {
    self = [super init];
    if (self) {
        _labels = nil;
    }
    return self;
}

@end