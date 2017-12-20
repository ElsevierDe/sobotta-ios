//
//  TrainingViewController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 16.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

//Table Sections
//0 = Pin/Text Segmented Control
//1 = Button Solve/next
//2 = Find ...
//3 = Result ...
//4 = Intermediate Result Buttons
//5 = Endresult Buttons


#import "TrainingViewController.h"
#import "DatabaseController.h"
#import "SOBNavigationViewController.h"

//#import <FacebookSDK/FacebookSDK.h>


#define cDefaultHeaderHeight 40
#define cDefaultFooterHeight 10
#define cZeroHeight 0.000001f
#define cTableViewFontSize 17
#define cTrainingCellIdentifier @"TrainingCell"
#define cTrainingCellButtonIdentifier @"TrainingButton"
#define cTrainingCellSegment @"SegmentCell"

@interface TrainingViewController ()

@end

@implementation TrainingViewController
@synthesize trainingModeControl;
@synthesize parentPopoverController;
@synthesize delegate;
@synthesize viewMode = _viewMode;
@synthesize labels;
@synthesize solveButtonEnabled;
@synthesize nextQuestionEnabled;
@synthesize showEndButton;

@synthesize correctStructures;
@synthesize wrongStructures;
@synthesize percentage;
@synthesize structuresCount;
@synthesize trainingName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.allowsMultipleSelection = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	trainingModeControl = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:NSLocalizedString(@"Pin",nil), NSLocalizedString(@"Text",nil), nil]];
	[trainingModeControl addTarget:self action:@selector(trainingModeAction:) forControlEvents:UIControlEventValueChanged];
	trainingModeControl.selectedSegmentIndex = 0;
	
	self.viewMode = cTrainingViewModeTraining;
	self.solveButtonEnabled = YES;
    
    [trainingModeControl setTitle:NSLocalizedString(@"Pin Mode", @"Training Mode Control") forSegmentAtIndex:0];
    [trainingModeControl setTitle:NSLocalizedString(@"Text", @"Training Mode Control") forSegmentAtIndex:1];
}

- (void)viewDidUnload
{
	[self setTrainingModeControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)trainingModeAction:(id)sender {
	if(delegate)
		[delegate trainingModeChange:self];
}

- (IBAction)solveAction:(id)sender {
	if(delegate && solveButtonEnabled)
		[delegate solveQuestion:self];
}

- (IBAction)nextQuestionAction:(id)sender {
	if(delegate && nextQuestionEnabled)
		[delegate nextQuestion:self];
}

- (IBAction)nextFigureAction:(id)sender {
	if(delegate)
		[delegate nextFigureWithDialog:(self.viewMode == cTrainingViewModeTraining)];
}

- (IBAction)endTrainingAction:(id)sender {
	if(delegate) {
		[delegate endTrainingWithDialog:YES];
    }
}

- (IBAction)continueTrainingAction:(id)sender {
	if(delegate)
		[delegate continueTraining:self];
}

- (IBAction)backToListAction:(id)sender {
	if(delegate)
		[delegate backToList:self];
}

- (void)setSolveButtonEnabled:(BOOL)sbe {
	solveButtonEnabled = sbe;
	[self reloadDataAndPreserveSelection];
}

- (void)setNextQuestionEnabled:(BOOL)nqe {
	nextQuestionEnabled = nqe;
	[self reloadDataAndPreserveSelection];
}

- (void)setShowEndButton:(BOOL)seb {
	showEndButton = seb;
	[self reloadDataAndPreserveSelection];
}

- (void)selectRowWithLabelID:(NSInteger)labelid {
	for (int i = 0; i<self.labels.count; i++) {
		NSDictionary *label = [self.labels objectAtIndex:i];
		if([[label objectForKey:@"id"] integerValue] == labelid){
			[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2] animated:YES scrollPosition:UITableViewScrollPositionTop];
			break;
		}
	}
}

- (void)reloadDataAndPreserveSelection {
	NSArray *selected = self.tableView.indexPathsForSelectedRows;
    if (self.navigationController && self.navigationController.topViewController == self) {
        // if we are the top view controller, use some crazy animation.
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 8)] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
	for (NSIndexPath *index in selected) {
		[self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

#pragma mark - Table Datasource

- (NSInteger)numberOfLabels {
	//KWLogDebug(@"Labels: %@", self.labels);
	if(self.labels)
		return self.labels.count;
	else
		return 0;
}

- (UITableViewCell*)getButtonCell {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cTrainingCellButtonIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cTrainingCellButtonIdentifier];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:cTableViewFontSize];
	}
	cell.textLabel.textColor = [UIColor blackColor];
	
	return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cTrainingCellSegment];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cTrainingCellSegment];
		}
		[cell.contentView addSubview:self.trainingModeControl];
		self.trainingModeControl.frame = CGRectMake(10, 8, cell.contentView.frame.size.width-20, cell.contentView.frame.size.height-16);
        self.trainingModeControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell.contentView.autoresizesSubviews = YES;
		
		return cell;
	}
	if(indexPath.section == 1) {
		
		switch (indexPath.row + (IS_PHONE ? 1 : 0)) {
			case 0:
			{
				UITableViewCell *cell = [self getButtonCell];
				if(!solveButtonEnabled)
					cell.textLabel.textColor = [UIColor lightGrayColor];
				cell.textLabel.text = NSLocalizedString(@"Solve", @"Training Action");
				return cell;
			}
			case 1:
			{
				UITableViewCell *cell = [self getButtonCell];
				if(!nextQuestionEnabled)
					cell.textLabel.textColor = [UIColor lightGrayColor];
				cell.textLabel.text = NSLocalizedString(@"Next Question", @"Training Action");
				return cell;
			}
			case 2:
			{
				UITableViewCell *cell = [self getButtonCell];
				if(showEndButton)
					cell.textLabel.text = NSLocalizedString(@"End training", @"Training Action");
				else
					cell.textLabel.text = NSLocalizedString(@"Next Figure", @"Training Action");
				return cell;
			}
			default:
				return nil;
		}
    } else if (IS_PHONE && indexPath.section == 3 && (indexPath.row == 1 || indexPath.row == 2)) {
		switch (indexPath.row) {
			case 1:
			{
				UITableViewCell *cell = [self getButtonCell];
				cell.textLabel.text = NSLocalizedString(@"End Training", nil);
				return cell;
			}
			case 2:
			{
				UITableViewCell *cell = [self getButtonCell];
				cell.textLabel.text = NSLocalizedString(@"Continue Training", nil);
				return cell;
			}
		}
	} else if(indexPath.section >= 2 && indexPath.section <= 5) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cTrainingCellIdentifier];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cTrainingCellIdentifier];
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.numberOfLines = 0;
		}
		
		//Reset font and alignment (could reuse cell for percentage
		cell.textLabel.font = [UIFont systemFontOfSize:cTableViewFontSize];
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];
		
		switch (indexPath.section) {
			case 2:
			{
				NSDictionary *label = [self.labels objectAtIndex:indexPath.row];
				if([[label objectForKey:@"trainingState"] integerValue] != cLabelStateNone)
					cell.textLabel.textColor = [UIColor lightGrayColor];
				NSString *cellText = [label objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
				cellText = [cellText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
				cell.textLabel.text = cellText;
			}
				break;
			case 3:
				cell.textLabel.text = self.trainingName;
				break;
			case 4:
				cell.textLabel.text = self.structuresCount;
				break;
			case 5:
			{
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = self.correctStructures;
						break;
					case 1:
						cell.textLabel.text = self.wrongStructures;
						break;
					case 2:
						cell.textLabel.text = self.percentage;
						cell.textLabel.textAlignment = NSTextAlignmentCenter;
						cell.textLabel.font = [UIFont boldSystemFontOfSize:cTableViewFontSize];
						break;
					default:
						break;
				}
			}
				break;
			default:
				break;
		}
		
		return cell;
	}
	else if(indexPath.section == 6){
		switch (indexPath.row) {
			case 0:
			{
				UITableViewCell *cell = [self getButtonCell];
				cell.textLabel.text = NSLocalizedString(@"End Training", nil);
				return cell;
			}
			case 1:
			{
				UITableViewCell *cell = [self getButtonCell];
				cell.textLabel.text = NSLocalizedString(@"Continue Training", nil);
				return cell;
			}
			default:
				return nil;
		}
	}
	else if(indexPath.section == 7){
        switch (indexPath.row) {
            case 0:
            {
                UITableViewCell *cell = [self getButtonCell];
                cell.textLabel.text = NSLocalizedString(@"Share result on Facebook", nil);
                return cell;
            }
            case 1:
            {
                UITableViewCell *cell = [self getButtonCell];
                cell.textLabel.text = NSLocalizedString(@"Close Training", nil);
                return cell;
            }
            default: return nil;
        }
	}
	else {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 2) {
		NSString *cellText = [[self.labels objectAtIndex:indexPath.row] objectForKey:[NSString stringWithFormat:@"text_%@", [[DatabaseController Current] langcolname]]];
		cellText = [cellText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		UIFont *cellFont = [UIFont systemFontOfSize:cTableViewFontSize];
		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		return labelSize.height + 20;
	}
	else {
		return [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
}

- (void)setLabels:(NSArray *)l {
	labels = l;
	[self reloadDataAndPreserveSelection];
	[self updateTableHeight];
}

#pragma mark - Table view layout

- (void)setViewMode:(NSInteger)vm {
	_viewMode = vm;
	switch (vm) {
		case cTrainingViewModeTraining:
			//self.tableView.allowsSelection = YES;
			break;
		case cTrainingViewModePageResult:
			//self.tableView.allowsSelection = NO;
			break;
		case cTrainingViewModeIntermediateResult:
			//self.tableView.allowsSelection = NO;
			break;
		case cTrainingViewModeEndResult:
			//self.tableView.allowsSelection = NO;
			break;
		default:
			break;
	}
	[self reloadDataAndPreserveSelection];
	[self updateTableHeight];
}

-(void)deselectAllRows {
	NSArray *selected = self.tableView.indexPathsForSelectedRows;
	for (NSIndexPath *index in selected) {
		[self.tableView deselectRowAtIndexPath:index animated:NO];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
	if(indexPath.section == 1){
        int type = indexPath.row;
        if (IS_PHONE) {
            type++;
        }
		switch (type) {
			case 0: // Solve
			{
				[self solveAction:self];
				break;
			}
			case 1: // Next Question
			{
				[self nextQuestionAction:self];
				[self deselectAllRows];
                if (IS_PHONE) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
				break;
			}
			case 2: // Next Figure
			{
				[self nextFigureAction:self];
                if (IS_PHONE) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
				break;
			}
			default:
				break;
		}
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else if(indexPath.section == 2){
		if(delegate && self.solveButtonEnabled) {
			NSDictionary *label = [self.labels objectAtIndex:indexPath.row];
			[delegate answerSelected:[[label objectForKey:@"id"] integerValue]];
			
			if(self.trainingModeControl.selectedSegmentIndex != 1)
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		else {
			[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 1: // end training
                [self endTrainingAction:self];
                break;
            case 2: // continue training
                [self continueTrainingAction:self];
                break;
        }
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
	} else if(indexPath.section == 6) {
		switch (indexPath.row) {
			case 0: // End Training
			{
				[self endTrainingAction:self];
			}
				break;
			case 1: // Continue Training
			{
                [self continueTrainingAction:self];
			}
				break;
			default:
				break;
		}
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else if(indexPath.section == 7){
        switch (indexPath.row) {
            case 0: // share on facebook
                [self shareOnFacebook];
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
            case 1: // close
                // close training
                [self backToListAction:self];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
        }
	}
}

- (void) shareOnFacebook {
    FigureDatasource * fd = [delegate currentFigureDatasource];
    SectionInfo *sectionInfo = [fd sectionAtIndex:0];
    long chapterId = [sectionInfo.chapterId longValue];
    Training *t = [delegate currentTraining];

    if (chapterId < 1) {
        chapterId = 1;
    }
    Section *chapter = [[DatabaseController Current] chapterById:chapterId];
    NSLog(@"got chapter: %@", chapter.name);
    NSString *pictureUrl = [NSString stringWithFormat:@"http://inapp.elsevier-verlag.de/sobotta-data/fb/chp%03ld_000.jpg", chapterId];
//    NSString *description = NSLocalizedString(@"I matched %@ of %d anatomical structures correctly. How about you?", nil);
    NSString *description = NSLocalizedString(@"I got %@ of %d anatomical structures correct. Give it a try!", nil);
    description = [NSString stringWithFormat:description, percentage, [t.amount_wrong intValue] + [t.amount_correct intValue]];
    NSString *fbLink = @"https://www.facebook.com/SobottaAnatomieAtlas";
  
/*  NSDictionary *params = @{
                            @"app_id": SOB_FB_APPID,
                            @"description": description,
//                            @"caption": NSLocalizedString(@"I have completed a training in the Sobotta Anatomy Atlas App.", nil),
                            @"caption": @" ",
                            @"picture": pictureUrl,
                            @"link": fbLink
                            };
*/
 //    NSMutableDictionary *params =
//    [NSMutableDictionary dictionaryWithObjectsAndKeys:
//     SOB_FB_APPID, @"app_id",
//     , @"description",
//     @"https://www.facebook.com/SobottaAnatomieAtlas", @"link",
//     @"I have completed a training in the Sobotta Anatomy Atlas App.", @"caption",
//     @"http://inapp.elsevier-verlag.de/sobotta-data/fb/chp001_000.png", @"picture",
//     nil];
    

   
    
    /*
    FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
//    p.caption = NSLocalizedString(@"I have completed a training in the Sobotta Anatomy Atlas App.", nil);
    p.description = description;
    p.link = [NSURL URLWithString:fbLink];
    p.picture= [NSURL URLWithString:pictureUrl];

    if ([FBDialogs canPresentShareDialogWithParams:p]) {
        NSLog(@"FB: Can present share dialog.. so do it.");
        [FBDialogs presentShareDialogWithParams:p clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            NSLog(@"FB: Returned from facebook. %@", error);
        }];
    } else {
        NSLog(@"FB: Can not present share dialog, show web share dialog.");
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {}
         ];
    }
     */

    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = NSLocalizedString(@"I have completed a training in the Sobotta Anatomy Atlas App.", nil);
    content.contentDescription = description;
    content.contentURL = [NSURL URLWithString:fbLink];
    content.imageURL = [NSURL URLWithString:pictureUrl];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		{
			if(!IS_PHONE && (self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult)) {
				return 1;
            } else {
				return 0;
            }
		}
		case 1:
		{
			if(self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult) {
                if (IS_PHONE) {
                    return 2;
                } else {
                    return 3;
                }
            } else
				return 0;
		}
		case 2:
		{
			if(self.viewMode == cTrainingViewModeTraining)
				return [self numberOfLabels];
			else
				return 0;
		}
		case 3:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult) {
                if (IS_PHONE && self.viewMode == cTrainingViewModeIntermediateResult) {
                    return 3;
                }
				return 1;
            } else
				return 0;
		}
		case 4:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return 1;
			else
				return 0;
		}
		case 5:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModePageResult || self.viewMode == cTrainingViewModeEndResult)
				return 3;
			else
				return 0;
		}
		case 6:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult) {
                if (IS_PHONE) {
                    return 0;
                }
				return 2;
            } else
				return 0;
		}
		case 7:
		{
			if(self.viewMode == cTrainingViewModeEndResult)
				return 2;
			else
				return 0;
		}
		default:
			return 0;
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
		{
			if(!IS_PHONE && (self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult))
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 1:
		{
			if(self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 2:
		{
			if(self.viewMode == cTrainingViewModeTraining)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 3:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 4:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 5:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModePageResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 6:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		case 7:
		{
			if(self.viewMode == cTrainingViewModeEndResult)
				return cDefaultHeaderHeight;
			else
				return cZeroHeight;
		}
		default:
			return cZeroHeight;
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
		{
			if(!IS_PHONE && (self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult))
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 1:
		{
			if(self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 2:
		{
			if(self.viewMode == cTrainingViewModeTraining)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 3:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 4:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 5:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModePageResult || self.viewMode == cTrainingViewModeEndResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 6:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		case 7:
		{
			if(self.viewMode == cTrainingViewModeEndResult)
				return cDefaultFooterHeight;
			else
				return cZeroHeight;
		}
		default:
			return cZeroHeight;
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
		{
			if(self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult)
				return NSLocalizedString(@"Change Training Mode", nil); //Modus wechseln
			else
				return nil;
		}
		case 1:
		{
			if(self.viewMode == cTrainingViewModeTraining || self.viewMode == cTrainingViewModePageResult)
				return NSLocalizedString(@"Action", nil); // Auswahl
			else
				return nil;
		}
		case 2:
		{
			if(self.viewMode == cTrainingViewModeTraining) {
                if (trainingModeControl.selectedSegmentIndex == 0) {
                    return NSLocalizedString(@"Find the structure", nil); // Find
                } else {
                    return NSLocalizedString(@"Find the marked structure", nil);
                }
            } else {
				return nil;
            }
		}
		case 3:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult || self.viewMode == cTrainingViewModeEndResult)
				return NSLocalizedString(@"Trainings Result", nil); // Trainingsergebnis
			else
				return nil;
		}
		case 4:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult)
				return NSLocalizedString(@"Progress", nil); // Fortschritt
			else if(self.viewMode == cTrainingViewModeEndResult)
				return NSLocalizedString(@"Scope", nil); // Umfang
			else
				return nil;
		}
		case 5:
		{
			if(self.viewMode == cTrainingViewModeIntermediateResult)
				return NSLocalizedString(@"Interim Result", nil); //Zwischenergebnis
			else if(self.viewMode == cTrainingViewModeEndResult)
				return NSLocalizedString(@"End Result", nil); // Endergebnis
			else if(self.viewMode == cTrainingViewModePageResult)
				return NSLocalizedString(@"Result of Current Figure", nil); // Ergebnis aktuelle Abbildung
			else
				return nil;
		}
		case 6:
		case 7:
		{
			return nil;
		}
		default:
			return nil;
	}
}

- (void)updateTableHeight {
    // maxHeight is 3/4th of the devices (landscape) height minus 50 points. (20px status bar, 30 px margin)
    CGRect originalFrame = [[UIScreen mainScreen] bounds];
    float maxHeight = (MIN(originalFrame.size.width, originalFrame.size.height) - 50) * .75;
    
    CGSize before = self.preferredContentSize;
    
    self.preferredContentSize = CGSizeMake(MAX(320, self.preferredContentSize.width), MIN(self.tableView.contentSize.height, maxHeight));
    NSLog(@"Setting preferred content size from %@ to %@", NSStringFromCGSize(before), NSStringFromCGSize(self.preferredContentSize));
}




/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
*/
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
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
}
*/


#pragma mark - FBSDKSharingDelegate

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults: (NSDictionary *)results {
 NSLog(@"FB: Successfully shared training result");
}

- (void) sharer: (id<FBSDKSharing>)sharer didFailWithError: (NSError *)error {
 NSLog(@"FB: Sharing failed: %@", error.localizedDescription);
}

- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
 NSLog(@"FB: Sharing canceled");
}

@end
