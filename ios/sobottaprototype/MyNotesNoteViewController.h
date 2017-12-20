//
//  MyNotesNoteViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyNotesBackgroundLinesView.h"
#import "DatabaseController.h"
#import "Note.h"
#import "SOBButtonImage.h"

@interface MyNotesNoteViewController : UIViewController {
    MyNotesBackgroundLinesView *_noteContentView;
    
    NSManagedObjectContext *_managedObjectContext;
}

@property (weak, nonatomic) IBOutlet UIView *imageLabelParent;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property (weak, nonatomic) IBOutlet SOBButtonImage *openFigureButton;

@property (strong, nonatomic) NSString *figureLabel;
@property (strong, nonatomic) NSNumber *figureId;
@property (weak, nonatomic) IBOutlet UIScrollView *noteContentScrollView;
@property (strong, nonatomic) NSArray *labelids;

@end
