//
//  MoreMenuTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/23/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FullVersionController.h"


@class SOBNavigationViewController;

@interface MoreMenuTableViewController : UITableViewController<MFMailComposeViewControllerDelegate> {
}

@property (weak, nonatomic) IBOutlet UILabel *abbreviationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageCreditsLabel;
@property (weak, nonatomic) IBOutlet UILabel *myNotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainingResultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateAppLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutSobottaLabel;
@property (weak, nonatomic) IBOutlet UILabel *faqLabel;
@property (weak, nonatomic) IBOutlet UILabel *tellafriendLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *imprintLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataprivacyLabel;
@property (weak, nonatomic) IBOutlet UILabel *redeemVoucherLabel;
@property (weak, nonatomic) IBOutlet UILabel *googlePlusSignIn;

@property (weak, nonatomic) SOBNavigationViewController *sobNavigationController;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
