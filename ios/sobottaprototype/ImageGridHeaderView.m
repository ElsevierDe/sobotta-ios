//
//  ImageGridHeaderView.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/27/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridHeaderView.h"
#import "ImageGridViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation ImageGridHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (float)height {
    id<SOTheme> theme = [SOThemeManager sharedTheme];
    return (2*[theme imageGridHeaderPadding]) + [theme imageGridHeaderFont].lineHeight + 1.f;
}

- (id)initWithString:(NSString *)string
{
    id<SOTheme> theme = [SOThemeManager sharedTheme];
    CGRect tmp = CGRectMake(0, 0, 100, [ImageGridHeaderView height]);
    sticky = NO;
    if ((self = [super initWithFrame:tmp])) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                           [theme imageGridHeaderPadding],
                                                           [theme imageGridHeaderPadding],
                                                           tmp.size.width,
                                                           tmp.size.height - 1.f - 2*[theme imageGridHeaderPadding])];
        //_label.textColor = [UIColor whiteColor];
        _label.textColor = UIColorFromRGB(0x3D2918);
        _label.font = [theme imageGridHeaderFont];// [UIFont boldSystemFontOfSize:16.f];
        //_label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
        //_label.shadowOffset = CGSizeMake(0.f, 1.f);
        _label.textAlignment = UITextAlignmentLeft;
        _label.text = string;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.f];
        self.backgroundColor = UIColorFromRGB(0xFFD5B3);

//        _label.layer.borderColor = [UIColor blackColor].CGColor;_label.layer.borderWidth = 1.f;
//        self.layer.borderColor = [UIColor greenColor].CGColor; self.layer.borderWidth = 1.f;
        
        //self.backgroundColor = [UIColor colorWithRed:55/255. green:106/255. blue:137/255. alpha:0.5f];
        //_label.backgroundColor
        UIView *tmpview = [[UIView alloc] initWithFrame:CGRectMake(0, tmp.size.height - 1.f, tmp.size.width, 1.f)];
        tmpview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        tmpview.backgroundColor = [theme imageGridBottomBorderColor];
        self.bottomBorder = tmpview;

        
        UIView *tmptopview = [[UIView alloc] initWithFrame:CGRectMake(0, 1.f, tmp.size.width, 1.f)];
        tmptopview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        tmptopview.backgroundColor = [theme imageGridBottomBorderColor];
        self.topBorder = tmptopview;
        
        UIButton *startTraining = [UIButton buttonWithType:UIButtonTypeCustom];
        [startTraining setImage:[UIImage imageNamed:@"ic_training_play"] forState:UIControlStateNormal];
        startTraining.frame = CGRectMake(tmp.size.width-26-26-(2*[theme imageGridHeaderPadding]), 5, 26, 26);
        startTraining.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [startTraining addTarget:self action:@selector(startTrainingPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //_detail  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        _detail = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detail setImage:[UIImage imageNamed:@"more-icon.png"] forState:UIControlStateNormal];
        _detail.frame = CGRectMake(0, 0, 26, 26);
        CGRect oldframe = _detail.frame;
        NSLog(@"oldframe: %@", NSStringFromCGRect(oldframe));
        _detail.frame = CGRectMake(tmp.size.width-oldframe.size.width-[theme imageGridHeaderPadding], 5, oldframe.size.width, oldframe.size.height);
        _detail.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_detail addTarget:self action:@selector(detailPressed:) forControlEvents:UIControlEventTouchUpInside];

        
        [self addSubview:_label];
        [self addSubview:_topBorder];
        [self addSubview:_bottomBorder];
        [self addSubview:startTraining];
        [self addSubview:_detail];
        
//        _topBorder.hidden = YES;
//        _bottomBorder.hidden = NO;
        sticky = YES;
        [self changedToUnSticky];
        
        /*
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-1.f, self.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [self.layer addSublayer:bottomBorder];
         */
    }
    
    return self;
}

- (void)startTrainingPressed:(id)sender {
    [self.imageGridViewController startTrainingForSectionIdx:_sectionIdx];
}

- (void)detailPressed: (id) sender {
    [self dismissPopovers];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ImageActionsStoryboard" bundle:[NSBundle mainBundle]];
    if (IS_PHONE){
        NSString *removeBookmarks = NSLocalizedString(@"Remove Bookmarks", nil);
        if (!_figureDatasource.bookmarkList) {
            removeBookmarks = nil;
        }
        _actionSheetSelectedSectionIdx = _sectionIdx;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.label.text delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Start Training", nil), NSLocalizedString(@"Add to Bookmarks", nil), removeBookmarks, nil];
        //    [actionSheet showFromRect:_detail.frame inView:_detail.superview animated:YES];
        actionSheet.tag = kActionSheetHeaderAction;
        [actionSheet showInView:_detail];
        return;
    }
    UINavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ImageGridActions"];
    ImageGridHeaderActionViewController* actionVc = [[vc viewControllers] lastObject];
    actionVc.figureDatasource = _figureDatasource;
    actionVc.sectionIdx = _sectionIdx;
    actionVc.imageGridHeaderView = self;
    
    
    _detailPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    _detailPopover.delegate = self;
    CGRect rect = [self convertRect:_detail.frame toView:self.superview];
    [_detailPopover presentPopoverFromRect:rect inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void)dismissPopovers {
    if (_detailPopover) {
        [_detailPopover dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == _detailPopover) {
        _detailPopover = nil;
    }
}


- (void)changedToSticky {
    //NSLog(@"sticky.");
    if (!sticky) {
        sticky = YES;
        _bottomBorder.hidden = NO;
        _topBorder.hidden = YES;
    }
}
- (void)changedToUnSticky {
    if (sticky) {
        sticky = NO;
        _bottomBorder.hidden = YES;
        _topBorder.hidden = NO;
    }
}

/*
- (void)layoutSubviews {
    id<SOTheme> theme = [SOThemeManager sharedTheme];
    CGRect tmp = self.frame;
    _label.frame = CGRectMake(
                              [theme imageGridHeaderPadding],
                              [theme imageGridHeaderPadding],
                              tmp.size.width,
                              tmp.size.height - 1.f - [theme imageGridHeaderPadding]);
}
*/

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetHeaderAction) {
        if (buttonIndex == 0) {
            // Start Training
            [self.imageGridViewController startTrainingForSectionIdx:_actionSheetSelectedSectionIdx];
        } else if (buttonIndex == 1) {
            // Add to Bookmarks
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"BookmarksStoryboard" bundle:[NSBundle mainBundle]];
            UINavigationController *vc = [main instantiateInitialViewController];
            BookmarksTableViewController *bookmarks = (BookmarksTableViewController*)vc.topViewController;
            bookmarks.bookmarksDelegate = self;
            
//            [self.navigationController pushViewController:bookmarks animated:YES];
            [_imageGridViewController.navigationController pushViewController:bookmarks animated:YES];

        } else if (_figureDatasource.bookmarkList && buttonIndex == 2) {
            // Remove from Bookmarks
            [_figureDatasource removeFiguresOfSectionIdx:_actionSheetSelectedSectionIdx fromBookmarkList:_figureDatasource.bookmarkList];
            
            [_figureDatasource reloadData];
        }
    }
}

- (void)openFiguresForBookmarkList:(Bookmarklist *)bookmarkList {
    [_figureDatasource addFiguresOfSectionIdx:_actionSheetSelectedSectionIdx intoBookmarkList:bookmarkList];
    [_imageGridViewController.navigationController popViewControllerAnimated:YES];
}

@end
