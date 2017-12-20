//
//  HasVoucherController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/18/13.
//  Copyright (c) 2013 Stephan Kitzler-Walli. All rights reserved.
//

#import "HasVoucherController.h"
#import "DatabaseController.h"
#import "FullVersionController.h"
#import "SOBButtonImage.h"

@implementation HasVoucherController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundlePricesUpdated:) name:EVENT_BUNDLE_PRICE_UPDATED object:nil];
    
    NSString *upgradeString = NSLocalizedString(@"Unlock all three Volumes (over 1600 figures) of the Sobotta Human Anatomy Atlas.", nil);
    _lblTextUpgradeText.text = upgradeString;
    [_upgradeButton setTitle:NSLocalizedString(@"Upgrade", nil) forState:UIControlStateNormal];
    [_upgradeChapterButton setTitle:NSLocalizedString(@"Select chapter", nil) forState:UIControlStateNormal];
    
    [self bindLabels];
    
    [_lblDoYouHaveVoucher setTitle:NSLocalizedString(@"Do you have a __voucher__?", nil) forState:UIControlStateNormal];
    [_lblRestore setTitle:NSLocalizedString(@"Or restore previous purchase.", nil) forState:UIControlStateNormal];
    
}

- (void)bindLabels {
    NSDecimalNumber *cheapestPrice = nil;
    NSString *cheapestFormattedPrice = nil;
    for (Bundle *bundle in [BundleService instance].bundles) {
        if (!cheapestPrice || [bundle.price compare:cheapestPrice] == NSOrderedAscending) {
            cheapestPrice = bundle.price;
            cheapestFormattedPrice = bundle.formattedPrice;
        }
    }
    if (!cheapestFormattedPrice) {
        cheapestFormattedPrice = @"$9.99";
    }
    _lblUpgradeChapter.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock single chapters from %@", nil), cheapestFormattedPrice];
    


    
    [self.closeButton setTitle:NSLocalizedString(@"Close", nil)];
    self.title = NSLocalizedString(@"Upgrade App", nil);
    if (self.selectedBundle) {
        self.lblUpgradeChapter.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock chapter %@ (%d figures)", nil), self.selectedBundle.label, self.selectedBundle.figureCount];
        self.lblChooseDifferentChapter.hidden = NO;
        [self.lblChooseDifferentChapter setTitle:NSLocalizedString(@"Choose a different chapter", nil) forState:UIControlStateNormal];
        if (self.selectedBundle.formattedPrice) {
            [self.upgradeChapterButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Upgrade for %@", nil), self.selectedBundle.formattedPrice] forState:UIControlStateNormal];
        } else {
            [self.upgradeChapterButton setTitle:NSLocalizedString(@"Unlock chapter", nil) forState:UIControlStateNormal];
        }
    } else {
        self.lblChooseDifferentChapter.hidden = YES;
    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bundlePricesUpdated:(NSNotification *)notification {
    [self bindLabels];
}

- (IBAction)restoreButton:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)upgradeClicked:(id)sender {
    [[FullVersionController instance] startFullInAppPurchase];
    [self close];
}
- (IBAction)redeemVoucherClicked:(id)sender {
    [[FullVersionController instance] askForVoucher];
    [self close];
}
- (IBAction)closePressed:(id)sender {
    [self close];
}
- (IBAction)upgradeChapterButtonPressed:(id)sender {
    if (self.selectedBundle) {
        [self close];
        [[FullVersionController instance] startInAppPurchaseWithActivityView:self.selectedBundle.productId];
    } else {
        [self performSegueWithIdentifier:@"ShowUnlockChapter" sender:nil];
    }
}

- (void)close {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
