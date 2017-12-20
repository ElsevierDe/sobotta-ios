//
//  BookmarkListEditViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Bookmarklist.h"

@interface BookmarkListEditViewController : UIViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) Bookmarklist *bookmarkList;

@end
