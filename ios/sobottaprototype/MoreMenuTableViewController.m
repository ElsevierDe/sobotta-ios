//
//  MoreMenuTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MoreMenuTableViewController.h"

#import "SOBNavigationViewController.h"
#import "TrainingResultsTableViewController.h"
#import "StaticContentViewController.h"
#import "MyNotesCategoriesTableViewController.h"

@interface MoreMenuTableViewController ()

@end

@implementation MoreMenuTableViewController

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
    
    self.title = NSLocalizedString(@"More", nil);
    _aboutSobottaLabel.text = NSLocalizedString(@"About Sobotta", nil);
    _faqLabel.text = NSLocalizedString(@"FAQ", nil);
    _rateAppLabel.text = NSLocalizedString(@"Rate App", nil);
    _tellafriendLabel.text = NSLocalizedString(@"Tell a Friend", nil);
    _feedbackLabel.text = NSLocalizedString(@"Feedback", nil);
    _imprintLabel.text = NSLocalizedString(@"Imprint", nil);
    _dataprivacyLabel.text = NSLocalizedString(@"Data Privacy",nil);
    _imageCreditsLabel.text = NSLocalizedString(@"Picture Credits", nil);
    _myNotesLabel.text = NSLocalizedString(@"My Notes", nil);
    _trainingResultsLabel.text = NSLocalizedString(@"Training Results", nil);
    _abbreviationsLabel.text = NSLocalizedString(@"Abbreviations", nil);
    _googlePlusSignIn.text = NSLocalizedString(@"More Menu: Social Sign In", nil);
    _redeemVoucherLabel.text = NSLocalizedString(@"Redeem Voucher", nil);
    _versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], SOB_IS_FREE ? @"Free" : @"Full"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [[DatabaseController Current] trackView:@"MoreMenu"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Information", @"More section");
    } else if (section == 1){
        return NSLocalizedString(@"Share & Feedback", @"More section");
    } else if (section == 2) {
        return NSLocalizedString(@"Personal", @"More section");
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(!SOB_IS_FREE && cell.textLabel == _redeemVoucherLabel) {
        
        return 0; //set the hidden cell's height to 0
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.textLabel == _myNotesLabel) {
//        NSLog(@"this is the about label. yeah.");
//    }
//    if (indexPath.row == 1) {
        NSLog(@"Open My Notes");
        UIStoryboard *notes = [UIStoryboard storyboardWithName:@"MyNotes" bundle:[NSBundle mainBundle]];
        if (IS_PHONE) {
            MyNotesCategoriesTableViewController *notesCategories = [notes instantiateViewControllerWithIdentifier:@"MyNotesCategories"];
            [self.navigationController pushViewController:notesCategories animated:YES];
        } else {
            UIViewController *vc = [notes instantiateInitialViewController];
            [_sobNavigationController pushViewController:vc animated:YES];
            [_sobNavigationController dismissPopovers:nil];
        }
        
        
//    } else if (indexPath.row == 2) {
    } else if (cell.textLabel == _trainingResultsLabel) {
        UIStoryboard* results = [UIStoryboard storyboardWithName:IS_PHONE?@"TrainingResults-iphone" : @"TrainingResults" bundle:[NSBundle mainBundle]];
        TrainingResultsTableViewController *resultsView = [results instantiateInitialViewController];
        [_sobNavigationController pushViewController:resultsView animated:YES];
        [_sobNavigationController dismissPopovers:nil];

    } else if (cell.textLabel == _rateAppLabel) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", SOB_APPID]]];
    } else if (cell.textLabel == _faqLabel) {
        NSString *faqUrl = NSLocalizedString(@"FAQ Label URL", @"URL zu den FAQs von elsevier");
        NSLog(@"Opening FAQ: %@", faqUrl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:faqUrl]];
    } else if (cell.textLabel == _aboutSobottaLabel) {
        [self showStaticContent:@"2aboutsobotta"];
    } else if (cell.textLabel == _tellafriendLabel) {
        
//        [mail stringByAddingPercentEscapesUsingEncoding:<#(NSStringEncoding)#>]
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:?subject="]];
        [self openMailComposerFor:nil
                          subject:NSLocalizedString(@"Sobotta App for iPad!", @"tell a friend")];
    } else if (cell.textLabel == _feedbackLabel) {
        [self openMailComposerFor:@"info@elsevier.de"
                          subject:NSLocalizedString(@"Feedback Sobotta App", @"feedback mail")];
    } else if (cell.textLabel == _imageCreditsLabel) {
        [self showStaticContent:@"credits"];
    } else if (cell.textLabel == _abbreviationsLabel) {
        [self showStaticContent:@"abbrvs"];
    } else if (cell.textLabel == _imprintLabel) {
        //[self showStaticContent:@"7impressum"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"http://www.sobottaapp.com/imprint/", nil)]];
    } else if (cell.textLabel == _dataprivacyLabel) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.elsevier.de/datenschutz/"]];
    } else if (cell.textLabel == _redeemVoucherLabel) {
        if (!IS_PHONE) {
//            UIPopoverController *popc = (UIPopoverController *)self.parentViewController.parentViewController;
//            [popc dismissPopoverAnimated:YES];
            [_sobNavigationController dismissPopovers:nil];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        [[FullVersionController instance] askForVoucher];
    } else if (cell.textLabel == _googlePlusSignIn) {
//        [[GPPSignIn sharedInstance] authenticate];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) showStaticContent:(NSString *)staticContentName {
    StaticContentViewController *staticViewer = [self.storyboard instantiateViewControllerWithIdentifier:@"StaticContentView"];
    staticViewer.staticContentName = staticContentName;
//    [_sobNavigationController dismissPopovers:nil];
//    [_sobNavigationController pushViewController:staticViewer animated:YES];
    [self.navigationController pushViewController:staticViewer animated:YES];
}

- (void) openMailComposerFor:(NSString *)recipient subject:(NSString*)subject {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        if (recipient) {
            [composer setToRecipients:@[recipient]];
        }
        if (subject) {
            [composer setSubject:subject];
        }
        [self presentModalViewController:composer animated:YES];
    } else {
        // show error message.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support sending emails."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [self setAbbreviationsLabel:nil];
    [self setImageCreditsLabel:nil];
    [self setMyNotesLabel:nil];
    [self setTrainingResultsLabel:nil];
    [self setRateAppLabel:nil];
    [self setAboutSobottaLabel:nil];
    [self setFaqLabel:nil];
    [self setTellafriendLabel:nil];
    [self setFeedbackLabel:nil];
    [self setImprintLabel:nil];
    [super viewDidUnload];
}

@end
