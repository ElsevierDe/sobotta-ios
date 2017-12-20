//
//  ImageViewController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NAMapView.h"
#import "NALabelView.h"
#import "MHPagingScrollView.h"
#import "FigureDatasource.h"
#import "ThumbImageView.h"
#import "ThumbScrollView.h"
#import "SlideUpView.h"
#import "TrainingViewController.h"
#import "NotesView.h"
#import "SOBButtonImage.h"
#import "FullVersionController.h"
#import "Training.h"
#import "Repetition_Figure+CoreDataClass.h"

NS_ENUM(NSInteger, CreateTrainingOption) {
    CreateTrainingOptionResume,
    CreateTrainingOptionAllFromDatasource,
    CreateTrainingOptionSingleFigure
};

@interface QuestionInfo : NSObject {
}

@property FigureInfo *figure;
@property Repetition_Figure *repetitionFigure;
@property NSDictionary *label;
@property NSArray<NSDictionary *> *spots;

@end


@interface ImageViewController : UIViewController<UIPopoverControllerDelegate, UIScrollViewDelegate, ThumbImageViewDelegate, UIGestureRecognizerDelegate, MHPagingScrollViewDelegate,UIPrintInteractionControllerDelegate, UIWebViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, TrainingDelegate,
NALabelViewDelegate, NotesViewDelegate> {
@private
	BOOL _viewLoaded;
	FigureDatasource *_datasource;
	ThumbScrollView *_thumbScrollView;
    SlideUpView *_slideUpView;
	BOOL _thumbViewShowing;
	int _currentPage;
    int _currentFigureIndex;
	NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_resultsController;
	NSDictionary *_currentDBFigure;
	NSMutableArray *_labels;
	NSMutableDictionary *_spots;
	UIPopoverController *_trainingPopover;
	TrainingViewController *_trainingController;
	BOOL _trainingMode;
    BOOL _pausedTraining;
	Training_Figures *_currentFigure;
	Training *_currentTraining;
	NSDictionary *_currentTrainingLabel;
	NotesView *_notesView;
    NSString *_captionHtml;
    
    Repetition_Figure *_currentRepetitionFigure;
                                                        
                                                        
    BOOL _trainingNeedStart;
    enum CreateTrainingOption _trainingCreateNew;
    BOOL _isReloading;
    FullVersionController *_fullVersionController;
    
    // flag whether the view has appeared (ie. is visible, animation finished)
    BOOL _viewHasAppeared;
                                                        
}
@property (weak, nonatomic) IBOutlet MHPagingScrollView *pagingScrollView;
@property (weak, nonatomic) IBOutlet UIView *trainingHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *trainingHeaderLabel;
@property (strong, nonatomic) UIPopoverController *layerViewPopover;
@property (retain, nonatomic) FigureDatasource *datasource;

@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *captionLabelShadow;
@property (weak, nonatomic) IBOutlet UIWebView *captionWebView;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) SOBButtonImage *btnNextQuestion;

- (IBAction)singleTapAction:(id)sender;
- (IBAction)doubleTapAction:(id)sender;
- (IBAction)captionTapAction:(id)sender;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *captionTapGestureRecognizer;

// methods called due to user actions in the main ui
- (void) startPrinting:(id)button;
- (void) startTraining:(id)button createOption:(enum CreateTrainingOption)createNew;
- (void) startTrainingOrPostpone:(id)button createOption:(enum CreateTrainingOption)createNew;
- (void) pauseTraining;
- (BOOL) pausedTraining;
- (void) pinSelected:(id)sender;
- (BOOL) isFigureInteractive;
- (BOOL) trainingEnded;
- (NSInteger)numberOfLabelsToGuess;
- (void)showPageResult;
- (void)pressedLayerButton:(id) sender;
- (NSString *)navigationBarTitle;

//Settings
@property (nonatomic) BOOL displayCaption;
@property (nonatomic) int viewMode;
@property (nonatomic) BOOL allStructures;
@property (nonatomic) BOOL displayArtery;
@property (nonatomic) BOOL displayVein;
@property (nonatomic) BOOL displayNerve;
@property (nonatomic) BOOL displayMuscle;
@property (nonatomic) BOOL displayOther;

@property (readonly, nonatomic) BOOL trainingMode;

- (void)setFigure:(FigureDatasource*)source;
- (void)reloadFromDatasource;
- (IBAction)handleCaptionPan:(id)sender;

@end
