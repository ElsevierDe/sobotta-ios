//
//  HomescreenViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAMapView.h"
#import "DatabaseController.h"
#import "MasterViewController.h"
#import "BookmarksTableViewController.h"
#import "ContestView.h"
#import "FullVersionController.h"
#import "InAppMessageController.h"


@class LineView;

typedef enum {
    RequestedItemNone = 0,
    RequestedItemSearch = 1,
    RequestedItemShowChapter = 2,
    RequestedItemSearchWithinMasterview = 3,
    RequestedItemJumpToSection = 4,
} RequestedItem;


@interface HomescreenViewController : UIViewController<UIScrollViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, BookmarksDelegate> {
    DatabaseController *dbController;
    
    SEL action;
	id target;
    int _selectedChapterId;
    
    UIPopoverController *_bookmarksPopover;
    RequestedItem _requestItem;
    NSTimeInterval timeViewLoaded;
    DownloadStatus _downloadStatus;
}

- (void)repositionAnnotations;

// currentViewController must be set to the caller,  so we can make sure that it's still in control of the navigation controller.
- (void)openCategoriesGallery:(int)chapterId currentViewController:(UIViewController *)viewController;
// currentViewController must be set to the caller,  so we can make sure that it's still in control of the navigation controller.
- (void)openCategoriesGallery:(int)chapterId requestItem:(RequestedItem)requestedItem currentViewController:(UIViewController *)viewController;
- (void)openImageGrid;
- (void)openImageGridNoPopNavController:(BOOL)noPop;

@property (weak, nonatomic) IBOutlet UIView *scrollWrapper;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet LineView *drawView;
@property (weak, nonatomic) IBOutlet UIButton *btnBuySobotta;
@property (weak, nonatomic) IBOutlet UIImageView *btnBuySobottaImage;


@property (strong, nonatomic) UIPopoverController *currentPopover;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *showChapterButton;
@property (nonatomic) int jumpToSectionPosition;

@property (weak, nonatomic) IBOutlet UILabel *lascheLblStatus;

@property (weak, nonatomic) IBOutlet UILabel *lascheLblProgress;

@end
