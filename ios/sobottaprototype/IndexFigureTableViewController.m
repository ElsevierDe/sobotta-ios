//
//  IndexFigureTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/8/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "IndexFigureTableViewController.h"
#import "ImageViewController.h"
#import "MainSplitViewController.h"
#import "HomescreenViewController.h"

@interface IndexFigureTableViewController ()

@end

@implementation IndexFigureTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _databaseController = [DatabaseController Current];
        _fullVersionController = [FullVersionController instance];
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];

    
    [self loadChapterOverview];


}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    _chapterGroups = nil;
    [self loadChapterOverview];
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark - loading data

- (void) loadChapterOverview {
    FMDatabaseQueue *queue = [_databaseController contentDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:@"select o.chapter_id, o.name_%@, count(distinct f.id) from outline o INNER JOIN outline o2 ON o2.level1_id = o.chapter_id INNER JOIN figure f ON f.chapter_id = o2.chapter_id where o.level = 1 group by o.chapter_id order by o.chapter_id", _databaseController.langcolname];
        FMResultSet *rs = [db executeQuery:query];
        NSMutableArray *chapterGroups = [NSMutableArray arrayWithCapacity:12];
        while ([rs next]) {
            ChapterGroup *g = [[ChapterGroup alloc] init];
            g.idval = [rs longForColumnIndex:0];
            g.name = [NSString stringWithFormat:@"%d %@", [rs intForColumnIndex:0], [rs stringForColumnIndex:1]];
            g.count = [rs intForColumnIndex:2];
            [chapterGroups addObject:g];
        }
        _chapterGroups = chapterGroups;
    }];
}

- (void) loadFiguresForChapter:(ChapterGroup *) group {
    NSLog(@"Loading figures for %ld %@", group.idval, group.name);
    FMDatabaseQueue *queue = [_databaseController contentDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *langcol = [_databaseController langcolname];
        NSString *query = [NSString stringWithFormat:@"select f.id, f.shortlabel_%@, f.longlabel_%@, f.available from figure f INNER JOIN outline o ON o.chapter_id = f.chapter_id WHERE o.level1_id = ? order by f.sortorder", langcol, langcol];
        NSLog(@"query: %@", query);
        FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[[NSNumber numberWithLong:group.idval]]];
        NSMutableArray *infos = [NSMutableArray arrayWithCapacity:group.count];
        while ([rs next]) {
            NSString *shortlabel = [rs stringForColumnIndex:1];
            NSString *longlabel = [rs stringForColumnIndex:2];
            IndexFigureInfo *info = [[IndexFigureInfo alloc] init];
            info.label = [NSString stringWithFormat:@"%@ %@", shortlabel, longlabel];
            info.idval = [rs intForColumnIndex:0];
            info.available = [rs boolForColumnIndex:3];
            [infos addObject:info];
        }
        group.figureInfos = infos;
    }];
}

#pragma mark - Table view data source


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:12];
    for (int i = 1 ; i < 13 ; i++) {
        [ret addObject:[NSString stringWithFormat:@"%d", i]];
    }
    return ret;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((ChapterGroup*)[_chapterGroups objectAtIndex:section]).name;
//    return [NSString stringWithFormat:@"%d %@", section+1, [_databaseController chapterNameById:(section + 1)]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_chapterGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ((ChapterGroup*)[_chapterGroups objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    ChapterGroup *group = [_chapterGroups objectAtIndex:indexPath.section];
    if (!group.figureInfos) {
        [self loadFiguresForChapter:group];
    }
    IndexFigureInfo *info = [group.figureInfos objectAtIndex:indexPath.row];
    if (info) {
        cell.textLabel.enabled = info.available || [_fullVersionController hasPurchasedChapterId:@(group.idval)];
        cell.textLabel.text = info.label;
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.minimumFontSize = 14;
//        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.textLabel.text = @"";
    }
    
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
    ChapterGroup *group = [_chapterGroups objectAtIndex:indexPath.section];
    IndexFigureInfo *info = [group.figureInfos objectAtIndex:indexPath.row];
    
    NSNumber *chapterId = @(group.idval);
    if (!info.available && ![_fullVersionController hasFullVersion] && ![_fullVersionController hasPurchasedChapterId:chapterId]) {
        if (IS_PHONE) {
            [[FigureDatasource defaultDatasource] showPaidVersionTeaser:self chapterId:chapterId];
        } else {
            NSLog(@"splitViewController: %@ / parentViewController: %@", self.splitViewController, self.splitViewController.parentViewController);
            MainSplitViewController* svc = ((MainSplitViewController *)self.splitViewController);
            [svc dismissLeftPopoverAnimated:YES];
            [[FigureDatasource defaultDatasource] showPaidVersionTeaser:(UIViewController *)[svc.viewControllers objectAtIndex:1] chapterId:chapterId];
        }
        return;
    }
    
    FigureDatasource *ds = [FigureDatasource defaultDatasource];
//    [ds loadForFigureId:info.idval];
    [ds loadForChapterId:indexPath.section+1];
    [ds setCurrentSelectionFigureId:info.idval];
    
//    [self performSegueWithIdentifier:@"showImage" sender:self];
    
    if (IS_PHONE) {
        ImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
        [vc setFigure:ds];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
    UIViewController *lastViewController = [navController.viewControllers lastObject];
    
    if ([lastViewController isKindOfClass:[ImageViewController class]]) {
//        [((ImageViewController *)lastViewController) setFigure:ds];
//        [((ImageViewController *)lastViewController) reloadFromDatasource];
    } else {
        if ([lastViewController isKindOfClass:[HomescreenViewController class]]) {
            ImageGridViewController *igvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageGridViewController"];
            [navController pushViewController:igvc animated:NO];
        }
        ImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
        [vc setFigure:ds];

        [navController pushViewController:vc animated:YES];
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

@implementation ChapterGroup

- (id)init {
    self = [super init];
    if (self) {
        _figureInfos = nil;
    }
    return self;
}

@end

@implementation IndexFigureInfo
@end