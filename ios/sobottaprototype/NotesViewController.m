//
//  NotesViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 11/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//
// iphone view controller for notes.

#import "NotesViewController.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

#define kNotesViewPadding 5

- (id)initWithNotesView:(NotesView *)notesView {
    self = [super init];
    if (self) {
        _subNotesView = notesView;
    }
    return self;
}


- (void)loadView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGRect frame = [UIScreen mainScreen].applicationFrame;//CGRectMake(0, 0, 200, 200);
    CGRect subframe = CGRectMake(kNotesViewPadding, kNotesViewPadding, frame.size.width-2*kNotesViewPadding, frame.size.height-2*kNotesViewPadding);
    
    UIView *rootView = [[UIView alloc] initWithFrame:frame];
    rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rootView.backgroundColor = [UIColor whiteColor];
    
    _subNotesView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _subNotesView.autoresizesSubviews = YES;
    _subNotesView.frame = subframe;
    rootView.autoresizesSubviews = YES;
    [rootView addSubview:_subNotesView];
    
    NSLog(@"subnotesview frame: %@ /// textview: %@", NSStringFromCGRect(_subNotesView.frame), NSStringFromCGRect(_subNotesView.textView.frame));
    
    [self registerForKeyboardNotifications];
    
    self.view = rootView;
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"View did layout subviews.");
    NSLog(@"subnotesview frame: %@ /// textview: %@", NSStringFromCGRect(_subNotesView.frame), NSStringFromCGRect(_subNotesView.textView.frame));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    CGSize kbSize = kbRect.size;
    
    //UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _subNotesView.frame = CGRectMake(kNotesViewPadding, kNotesViewPadding, self.view.bounds.size.width - 2*kNotesViewPadding, self.view.bounds.size.height - kbSize.height - 2*kNotesViewPadding);
    NSLog(@"Keyboard shown -- self bounds: %@ / kbSize: %@", NSStringFromCGRect(self.view.bounds), NSStringFromCGSize(kbSize));
    //scrollView.scrollIndicatorInsets = contentInsets;
    
    /*
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
     */
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect frame = self.view.bounds;
    CGRect subframe = CGRectMake(kNotesViewPadding, kNotesViewPadding, frame.size.width-2*kNotesViewPadding, frame.size.height-2*kNotesViewPadding);
    _subNotesView.frame = subframe;
}

@end
