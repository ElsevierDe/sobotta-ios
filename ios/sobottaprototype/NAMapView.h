//
// NAMapView.h
// NAMapKit
//
// Created by Neil Ang on 21/07/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAAnnotation.h"
#import "NACallOutView.h"
#import "NALabelView.h"
#import "DejalActivityView.h"
#import "FullVersionController.h"
#import <CoreText/CoreText.h>

@interface NAMapView : UIScrollView<UIScrollViewDelegate> {
@private
	UIView    *_customMap;
	UIImageView *_imageView;
	NSMutableArray *_pinAnnotations;
	CGSize          _orignalSize;
	NACallOutView  *_callout;
	NALabelView    *_label;
	NSInteger		_index;
    BOOL _isLoadingDialog;
    DejalActivityView *_loadingView;
    FullVersionController *_fullVersionController;
}

- (void)displayMap:(UIImage *)map  inTraining:(BOOL)training;
- (void)displayLoading;
- (void)addAnnotation:(NAAnnotation *)annotation animated:(BOOL)animate;
- (void)addAnnotation:(NAAnnotation *)annotation withDelegate:(id)target;
//- (void)addAnnotations:(NSArray *)annotations animated:(BOOL)animate;
- (BOOL)hideCallOut;
- (IBAction)showCallOut:(id)sender;
- (void)centreOnPoint:(CGPoint)point animated:(BOOL)animate;
- (void)centerMap;
- (void)removeAllAnnotationsOrLabels;
- (void)addLabels:(NSArray *)labels withDelegate:(id)target;
- (void)updatePinPosition;

@property (nonatomic, retain) UIView    *customMap;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *pinAnnotations;
@property (nonatomic, retain) NACallOutView  *callout;
@property (nonatomic, assign) CGSize          orignalSize;
@property (nonatomic, retain) NALabelView    *label;
@property (nonatomic, assign) NSInteger		 index;
@property (nonatomic, assign) int loadedFigureId;

@end
