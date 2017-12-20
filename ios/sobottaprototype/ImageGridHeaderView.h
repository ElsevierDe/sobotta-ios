//
//  ImageGridHeaderView.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/27/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureDatasource.h"
#import "ImageGridHeaderActionViewController.h"

#define kActionSheetHeaderAction 1

@class ImageGridViewController;

@interface ImageGridHeaderView : UIView <KKGridViewSticky, UIPopoverControllerDelegate, UIActionSheetDelegate, BookmarksDelegate> {
    BOOL sticky;
    UIButton *_detail;
    
    UIPopoverController *_detailPopover;
    NSUInteger _actionSheetSelectedSectionIdx;
}

+ (float) height;

- (id)initWithString:(NSString *)string;

- (void)changedToSticky;
- (void)changedToUnSticky;
- (void) dismissPopovers;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *topBorder;
@property (strong, nonatomic) UIView *bottomBorder;
@property (nonatomic) NSUInteger sectionIdx;
@property (nonatomic) FigureDatasource* figureDatasource;
@property (weak, nonatomic) ImageGridViewController* imageGridViewController;

@end
