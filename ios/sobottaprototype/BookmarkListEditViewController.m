//
//  BookmarkListEditViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "BookmarkListEditViewController.h"

@interface BookmarkListEditViewController ()

@end

@implementation BookmarkListEditViewController
@synthesize titleField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"New Bookmark Folder", nil);
    self.titleField.placeholder = NSLocalizedString(@"Folder Name", nil);
    self.titleField.delegate = self;
    if (_bookmarkList) {
        self.titleField.text = _bookmarkList.name;
    }
    [titleField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (titleField.text.length > 0) {
//        [AppDelegate mana
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        appDelegate.managedObjectContext
        Bookmarklist *list = _bookmarkList;
        if (!list) {
            list = (Bookmarklist *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmarklist" inManagedObjectContext:appDelegate.managedObjectContext ];
        }
        if (![list.name isEqualToString:titleField.text]) {
            list.name = titleField.text;
            list.updated = [NSDate date];
            NSError *error = nil;
            [appDelegate.managedObjectContext save:&error];
        }
    }
}

- (void)viewDidUnload
{
    [self setTitleField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}
- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 320);
}

@end
