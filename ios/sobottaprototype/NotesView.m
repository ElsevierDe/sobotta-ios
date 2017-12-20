//
//  NotesViewController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 14.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "NotesView.h"

@implementation NotesView {
	BOOL didAwakeFromNib;
}
@synthesize delegate;
@synthesize noteHeaderImageView;
@synthesize textView;
@synthesize labelView;
@synthesize label = _label;

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	if (!didAwakeFromNib) {
		// do nib load stuff
		/*
		self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCapturePan:)];
		self.panGestureRecognizer.minimumNumberOfTouches = 1;
		//self.panGestureRecognizer.delegate = self;
		[self.noteHeaderImageView addGestureRecognizer:self.panGestureRecognizer];
		*/
		didAwakeFromNib = YES;
        
        [labelView setText:NSLocalizedString(@"Note", nil)];
	}
}

- (IBAction)blueColorSelected:(id)sender {
	[self.textView resignFirstResponder];
	[self setHeaderImagesWithColor:@"blue"];
	if(delegate)
		[delegate notes:self colorSelected:cNoteColorBlue];
}

- (IBAction)greenColorSelected:(id)sender {
	[self.textView resignFirstResponder];
	[self setHeaderImagesWithColor:@"green"];
	if(delegate)
		[delegate notes:self colorSelected:cNoteColorGreen];
}

- (IBAction)pinkColorSelected:(id)sender {
	[self.textView resignFirstResponder];
	[self setHeaderImagesWithColor:@"pink"];
	if(delegate)
		[delegate notes:self colorSelected:cNoteColorPink];
}

- (IBAction)violetColorSelected:(id)sender {
	[self.textView resignFirstResponder];
	[self setHeaderImagesWithColor:@"violet"];
	if(delegate)
		[delegate notes:self colorSelected:cNoteColorViolet];
}

- (IBAction)redColorSelected:(id)sender {
	[self.textView resignFirstResponder];
	[self setHeaderImagesWithColor:@"red"];
	if(delegate)
		[delegate notes:self colorSelected:cNoteColorRed];
}

- (IBAction)deleteNote:(id)sender {
	[self.textView resignFirstResponder];
	if(delegate)
		[delegate notes:self deleteNote:self];
}

- (void)setLabel:(NALabel *)label {
	_label = label;
	if(self.label.managedNote != nil){
		self.textView.text = [label.managedNote valueForKey:@"text"];
		if(self.textView.text.length ==0){
			[self.textView becomeFirstResponder];
		}
		if([self.label.noteColor isEqual:cNoteColorBlue]){
			[self setHeaderImagesWithColor:@"blue"];
		}
		else if ([self.label.noteColor isEqual:cNoteColorGreen]) {
			[self setHeaderImagesWithColor:@"green"];
		}
		else if ([self.label.noteColor isEqual:cNoteColorPink]) {
			[self setHeaderImagesWithColor:@"pink"];
		}
		else if ([self.label.noteColor isEqual:cNoteColorRed]) {
			[self setHeaderImagesWithColor:@"red"];
		}
		else if ([self.label.noteColor isEqual:cNoteColorViolet]) {
			[self setHeaderImagesWithColor:@"violet"];
		}
	}
}

- (void)setHeaderImagesWithColor:(NSString*)color {
	self.noteHeaderImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"notes-header-%@", color]];
	self.deleteButton.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"notes-delete-%@", color]];
}

- (IBAction)handleCapturePan:(id)sender {
	UIPanGestureRecognizer *recognizer = sender;
	CGPoint translation = [recognizer translationInView:self];
	self.frame = CGRectMake(translation.x, translation.y, self.frame.size.width, self.frame.size.height);
	[recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

/*
- (IBAction)panGestureAction:(id)sender {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	CGPoint translation = [panGestureRecognizer translationInView:self.view];
	CGFloat y = self.view.bounds.size.height - cCaptionHideHeight - cCaptionSpacingBottom;
	if((panGestureRecognizer.view.frame.origin.y + translation.y) < y) {
		y = panGestureRecognizer.view.frame.origin.y + translation.y;
		displayCaption = YES;
	}
	else {
		displayCaption = NO;
	}
	y = MAX(100, y);
	CGFloat height = self.view.bounds.size.height - y - cCaptionSpacingBottom;
	[defaults setBool:displayCaption forKey:@"ImageViewController.displayCaption"];
	//[self.pagingScrollView setViewHeight:self.view.frame.size.height - height + cCaptionClipHeight];
    panGestureRecognizer.view.frame = CGRectMake(panGestureRecognizer.view.frame.origin.x, y, panGestureRecognizer.view.frame.size.width, MIN(height,self.view.bounds.size.height-100));
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}
*/

- (void)textViewDidChange:(UITextView *)textView {
	if(delegate)
		[delegate notes:self textViewDidChange:[textView text]];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if(delegate)
		[delegate notes:self textViewDidEndEditing:[textView text]];
}

@end
