//
//  NALabel.m
//  MedicalPrototype
//
//  Created by Stephan Kitzler-Walli on 13.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NALabel.h"

@implementation NALabel

@synthesize labelPoint  = _labelPoint;
@synthesize targetPoint = _targetPoint;
@synthesize title       = _title;
@synthesize align	    = _align;
@synthesize relevant	= _relevant;
@synthesize disabled	= _disabled;
@synthesize selected	= _selected;
@synthesize labelid		= _labelid;

@synthesize hasNote		= _hasNote;
@synthesize managedNote = _managedNote;
@synthesize noteColor   = _noteColor;

@synthesize currentlyAsked = _currentlyAsked;
@synthesize trainingState = _trainingState;
@synthesize managedLabel = _managedLabel;

- (void)dealloc {

}

@end
