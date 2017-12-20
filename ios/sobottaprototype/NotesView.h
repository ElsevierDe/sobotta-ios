//
//  NotesViewController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 14.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesTextView.h"
#import "NALabel.h"

@class NotesView;

@protocol NotesViewDelegate <NSObject> 

- (void) notes:(id)sender colorSelected:(UIColor*)color;
- (void) notes:(id)sender deleteNote:(id)e;
- (void) notes:(id)sender textViewDidChange:(NSString*)notetext;
- (void) notes:(id)sender textViewDidEndEditing:(NSString*)notetext;

@end

@interface NotesView : UIView <UITextViewDelegate, UIGestureRecognizerDelegate> {
	NALabel *_label;
}
- (IBAction)blueColorSelected:(id)sender;
- (IBAction)greenColorSelected:(id)sender;
- (IBAction)pinkColorSelected:(id)sender;
- (IBAction)violetColorSelected:(id)sender;
- (IBAction)redColorSelected:(id)sender;
- (IBAction)deleteNote:(id)sender;
- (IBAction)handleCapturePan:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIImageView *noteHeaderImageView;
@property (strong, nonatomic) IBOutlet NotesTextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) NALabel *label;

@property (weak, nonatomic) id<NotesViewDelegate> delegate;
@end
