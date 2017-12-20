//
//  NALabel.h
//  MedicalPrototype
//
//  Created by Stephan Kitzler-Walli on 13.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "Training_Figure_Labels.h"

@interface NALabel : NSObject {
	CGPoint	  _labelPoint;
	CGPoint	  _targetPoint;
	NSString *_title;
	NSString *_align;
	BOOL	  _relevant;
	BOOL	  _disabled;
	BOOL	  _selected;
	NSInteger _labelid;
	
	//Note
	BOOL	  _hasNote;
	UIColor  *_noteColor;
	Note *_managedNote;
	
	//Training
	BOOL	  _currentlyAsked;
	NSInteger _trainingState;
	Training_Figure_Labels *_managedLabel;
}

@property (nonatomic, assign) CGPoint   labelPoint;
@property (nonatomic, assign) CGPoint   targetPoint;
@property (nonatomic, copy) NSString   *title;
@property (nonatomic) NSString *align;
@property (nonatomic) BOOL relevant;
@property (nonatomic) BOOL disabled;
@property (nonatomic) BOOL selected;
@property (nonatomic) NSInteger labelid;

@property (nonatomic) BOOL hasNote;
@property (nonatomic) UIColor *noteColor;
@property (nonatomic) Note *managedNote;

@property (nonatomic) BOOL currentlyAsked;
@property (nonatomic) NSInteger trainingState;
@property (nonatomic) Training_Figure_Labels *managedLabel;

@end
