//
//  NotesViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 11/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesView.h"

@interface NotesViewController : UIViewController {
    NotesView *_subNotesView;
};

- (id)initWithNotesView:(NotesView *)notesView;

@end
