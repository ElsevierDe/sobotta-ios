//
//  ImageGridViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/20/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKGridView/KKGridViewController.h>
#import "DatabaseController.h"
#import "SearchAutocompleteViewController.h"
#import "ImageGridSectionHeaderLabel.h"
#import "ImageGridHeaderView.h"
#import "FigureDatasource.h"
#import "FullVersionController.h"


@class MasterViewController;
@class MainSplitViewController;
@class FigureInfo;

#define ALERT_VIEW_APPSTORE 1

@interface ImageGridViewController : KKGridViewController <UIGestureRecognizerDelegate, UISearchBarDelegate, UIPopoverControllerDelegate, FigureDatasourceDelegate, UIAlertViewDelegate> {
    CGSize _scaleStartSize;
    
    
    DatabaseController *dbController;
    FigureInfo *_selectedItem;
    UIPopoverController *_searchPopover;
    SearchAutocompleteViewController *_searchController;
    
    UISegmentedControl *_gridSizeSelector;
    
    FigureDatasource *_figureDatasource;
    FullVersionController *_fullVersionController;
    
    BOOL _isInitialized;
    dispatch_queue_t loadsearchqueue;
    BOOL _requestLoadMasterView;
    
    UIActivityIndicatorView *_activityIndicator;
    UIView *_loading;
}

- (IBAction)myGestureRecognized:(UIGestureRecognizer*)sender;
- (void) loadMasterView:(BOOL)animated;

- (void) loadForChapterId: (int) chapterId;
- (void) jumpToSectionAtPosition: (int) sectionPosition;
- (NSString *) titleForHeaderInSection:(NSUInteger)section;
- (void) startTrainingForSectionIdx: (NSUInteger) sectionIdx;

@property (strong, nonatomic) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL requestSearch;
@property (nonatomic) BOOL requestSearchFromMasterView;
@property (nonatomic) int jumpToPosition;

@property (weak, nonatomic) MasterViewController *masterViewController;

@property (nonatomic) int currentGridSize;
@property (strong, nonatomic) FigureDatasource *figureDatasource;

@end
