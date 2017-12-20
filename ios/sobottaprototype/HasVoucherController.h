//
//  HasVoucherController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/18/13.
//  Copyright (c) 2013 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UAModalPanel/UAModalPanel.h>
#import "SOBButtonImage.h"

#import "BundleService.h"

@interface HasVoucherController : UIViewController {
//    UIView *_parentView;
//    UIButton closeButton;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;


@property (strong, nonatomic) Bundle *selectedBundle;


@property (strong, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *upgradeChapterButton;

@property (weak, nonatomic) IBOutlet UILabel *lblTextUpgradeText;
@property (weak, nonatomic) IBOutlet UILabel *lblUpgradeChapter;
@property (weak, nonatomic) IBOutlet UIButton *lblChooseDifferentChapter;
@property (weak, nonatomic) IBOutlet UIButton *lblDoYouHaveVoucher;
@property (weak, nonatomic) IBOutlet UIButton *lblRestore;

@end
