//
//  PurchaseBundleTableViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 02/01/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "PurchaseBundleTableViewController.h"

#import "FullVersionController.h"
#import "BundleService.h"
#import "MainSplitViewController.h"
#import "SOBNavigationViewController.h"
#import "Theme.h"
#import "AppDelegate.h"


@interface BundleHeaderTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation BundleHeaderTableViewCell

- (void)awakeFromNib {
    self.headerLabel.text = NSLocalizedString(@"The free Sobotta version offers a preview of every chapter. Feel free to browse through the chapters before buying.", nil);
}

@end


@interface BundleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *chapterName;
@property (weak, nonatomic) IBOutlet UIButton *purchaseOrOpenButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *purchaseActivityIndicator;

@property Bundle *bundle;
@property UIViewController *viewController;
@property BOOL hasPurchased;

@end

@implementation BundleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.purchaseOrOpenButton.hidden = YES;
    self.purchaseActivityIndicator.hidden = YES;
    [self.purchaseOrOpenButton setTitle:@"" forState:UIControlStateNormal];
    self.purchaseOrOpenButton.layer.cornerRadius = 5.;
    self.purchaseOrOpenButton.tintColor = [[SOThemeManager sharedTheme] barTintColor];
    self.purchaseOrOpenButton.layer.borderColor = self.purchaseOrOpenButton.tintColor.CGColor;
//    self.purchaseOrOpenButton.titleEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    self.purchaseOrOpenButton.layer.borderWidth = 1;
}

- (void)bindBundle:(Bundle *)bundle parentViewController:(UIViewController *)viewController {
    self.bundle = bundle;
    self.viewController = viewController;
    self.chapterName.text = bundle.label;
    self.hasPurchased = [[[FullVersionController instance] purchasedBundleIds] containsObject:bundle.bundleId];
    
    
    
    if (self.hasPurchased) {
        [self.purchaseOrOpenButton setTitle:NSLocalizedString(@"Open", nil) forState:UIControlStateNormal];
        self.purchaseActivityIndicator.hidden = YES;
        self.purchaseOrOpenButton.hidden = NO;
    } else if (bundle.formattedPrice) {
        NSLog(@"binding purchase or open button to %@", bundle.formattedPrice);
        [self.purchaseOrOpenButton setTitle:bundle.formattedPrice forState:UIControlStateNormal];
        self.purchaseActivityIndicator.hidden = YES;
        self.purchaseOrOpenButton.hidden = NO;
    } else {
        self.purchaseActivityIndicator.hidden = NO;
        self.purchaseOrOpenButton.hidden = YES;
        [self.purchaseActivityIndicator startAnimating];
    }
}

- (IBAction)purchasePressed:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    if (self.hasPurchased) {
        NSLog(@"Opening chapter %@", self.bundle.chapterIds.firstObject);
        [SOB_APP openCategoriesGallery:self.bundle.chapterIds.firstObject.intValue];
    } else {
        [[FullVersionController instance] startInAppPurchaseWithActivityView:self.bundle.productId];
    }
}

@end



@interface PurchaseBundleTableViewController ()

@property BundleService *bundleService;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation PurchaseBundleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Unlock chapter", nil);
    self.bundleService = [BundleService instance];
    [self.closeButton setTitle:NSLocalizedString(@"Close", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundlePricesUpdated:) name:EVENT_BUNDLE_PRICE_UPDATED object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bundlePricesUpdated:(id)notification {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePressed:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.bundleService.bundles.count;
    }
    @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"unexpected section." userInfo:@{@"section": @(section)}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"HeaderTableViewCell" forIndexPath:indexPath];
    }
    
    BundleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BundleTableViewCell" forIndexPath:indexPath];
    
    [cell bindBundle:self.bundleService.bundles[indexPath.row] parentViewController:self];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return;
    }
    
    NSLog(@"Selected row at index: %ld", (long) indexPath.row);
    Bundle *bundle = self.bundleService.bundles[indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [SOB_APP openCategoriesGallery:bundle.chapterIds.firstObject.intValue];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
