//
//  TrainingResultsTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/28/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "TrainingResultsTableViewController.h"
#import "TrainingResultsCell.h"
#import "Training.h"
#import "FigureDatasource.h"

@interface TrainingResultsTableViewController ()

@end

@implementation TrainingResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    _dateFormatter.dateStyle = NSDateFormatterFullStyle;
    _dateFormatter.locale = [NSLocale currentLocale];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Training"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"inprogress == %@", [NSNumber numberWithBool:NO]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_controller sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Training Results", nil);
}
 */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = CGRectMake(0, 0, 100, 30);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    float hmargin = 20;
    float topmargin = 10;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(hmargin, topmargin, frame.size.width-(2*hmargin), frame.size.height-topmargin)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    label.font = [[SOThemeManager sharedTheme] imageGridHeaderFont];
    label.text = NSLocalizedString(@"Training Results", nil);
    headerView.autoresizesSubviews = YES;
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TrainingResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Training *training = [_controller objectAtIndexPath:indexPath];
    
    cell.lblQuestionCountLabel.text = NSLocalizedString(@"Questions", @"Question Count in Training Results"); // Abbildungen
    cell.lblFigureCountLabel.text = NSLocalizedString(@"Figures", @"Figure Count in Training Results"); // Strukturen
    if (training.trainingType == TrainingTypeRepetition) {
        cell.lblQuestionCorrectLabel.text = NSLocalizedString(@"Learned", nil);
    } else {
        cell.lblQuestionCorrectLabel.text = NSLocalizedString(@"Correct Answers", @"Correct answers in Percent in Training Results"); // richtige Antworten
    }

    
    cell.lblTrainingName.text = [FigureDatasource trainingNameLocalizedForTraining:training];
    cell.lblTrainingDate.text = [training.inprogress boolValue] ? NSLocalizedString(@"In Progress", nil) : [_dateFormatter stringFromDate:training.end];
    if (training.trainingType == TrainingTypeRepetition) {
        int totalQuestions = training.repetition_amount_total.intValue;
        int learnedQuestions = training.repetition_amount_learned_total.intValue;
        int percent = totalQuestions == 0 ? 0 : (int) round(100. / totalQuestions * learnedQuestions);

        cell.lblFigureCount.text = [NSString stringWithFormat:@"%d", training.figures.count];
        cell.lblQuestionCount.text = [NSString stringWithFormat:@"%d", totalQuestions];
        cell.lblCorrectPercent.text = [NSString stringWithFormat:@"%d (%d%%)", learnedQuestions, percent];
    } else {
        int completedFigures = [training.amount_completed_figures intValue];
        if (completedFigures <= 0) {
            completedFigures = [training.figures count];
        }
        
        cell.lblFigureCount.text = [NSString stringWithFormat:@"%d", completedFigures];
        cell.lblQuestionCount.text = [NSString stringWithFormat:@"%d", [training.amount_answered intValue]];
        
        int totalQuestions = [training.amount_answered intValue];
        int correctQuestions = [training.amount_correct intValue];
        int percent = 0;
        if (totalQuestions > 0) {
            percent = (int) (100. / totalQuestions * correctQuestions);
        }
        cell.lblCorrectPercent.text = [NSString stringWithFormat:@"%d%%", percent];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
