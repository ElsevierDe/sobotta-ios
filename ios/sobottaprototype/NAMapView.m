//
// NAMapView.m
// NAMapKit
//
// Created by Neil Ang on 21/07/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import "NAMapView.h"
#import "NAPinAnnotationView.h"
#import "NALabelView.h"
#import "DejalActivityView.h"

#define ZOOM_STEP    1.5

@implementation NAMapView

//@synthesize containerView  = _containerView;
@synthesize customMap      = _customMap;
@synthesize imageView	   = _imageView;
@synthesize pinAnnotations = _pinAnnotations;
@synthesize callout        = _callout;
@synthesize orignalSize    = _orignalSize;
@synthesize label		   = _label;
@synthesize index		   = _index;
//@synthesize scaledLabel	   = _scaledLabel;

#pragma mark NAMapView class

- (void)commonInit {
    _isLoadingDialog = NO;
	self.delegate                       = self;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator   = NO;
	self.bounces = NO;
	self.bouncesZoom = YES;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
	self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
	
	[self setUserInteractionEnabled:YES];
    _fullVersionController = [FullVersionController instance];
	//self.contentMode = UIViewContentModeTopLeft;
	//self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
	
	//self.layer.borderColor = [UIColor blueColor].CGColor;
	//self.layer.borderWidth = 2.0f;
}

- (id)init {
	self = [super init];
	if(self){
		[self commonInit];
	}
	return self;
}

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
////    NSLog(@"touchesShouldCancelInContentView? %@", view);
//    return YES;
//}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		[self commonInit];
	}
	return self;
}

#pragma mark Tap to Zoom

#define cMapViewFactor 1.5


- (void)displayLoading {
	CGRect bounds = [Global bounds];
	if (self.customMap) {
        [self.customMap removeFromSuperview];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    NSLog(@"frame: %@ bounds: %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
//    view.backgroundColor = [UIColor blueColor];
    
//    [DejalActivityView activityViewForView:view withLabel:@"Please wait while the figure is loaded."];
    
    if (_fullVersionController.status == DownloadStatusInProgress) {
        _loadingView = [[DejalActivityView alloc] initForView:view withLabel:NSLocalizedString(@"Please wait while the figure is loaded.", nil) width:0];
    } else {
        
        UITextView *notice = [[UITextView alloc] initWithFrame:CGRectMake(view.bounds.size.width / 2 - 150, view.bounds.size.height / 2 - 100, 300, 200)];
        notice.editable = NO;
        notice.text = [NSString stringWithFormat:NSLocalizedString(@"This figure has not yet been downloaded.\nResume the download on the home screen.", nil)];
        notice.font = [UIFont systemFontOfSize:14];
        notice.textColor = [UIColor colorWithRed:89/256. green:89/256. blue:89/256. alpha:1];
        [view addSubview:notice];
//        UITextView *startDownload = [[UITextView alloc] initWithFrame:CGRectMake(view.bounds.size.width / 2 - 150, view.bounds.size.height / 2, 300, 100)];
//        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"Start download"];
//        [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
//                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
//                          range:(NSRange){0,[attString length]}];
//        startDownload.attributedText = attString;
//        startDownload.textAlignment = UITextAlignmentCenter;
//        [view addSubview:startDownload];
    }
    
//    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    progressView.progress = 0.3;
//    progressView.frame = CGRectMake(20, 100, view.frame.size.width-40, 30);
//    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    NSLog(@"width: %d", view.frame.size.width);
//    UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, view.frame.size.width-40, 30)];
//    txt.text = @"Please wait while the figure is loaded.";
//    txt.textAlignment = UITextAlignmentCenter;
//    [view addSubview:progressView];
//    [view addSubview:txt];
    self.customMap = view;
    _isLoadingDialog = YES;
    self.contentSize = view.frame.size;
    
    self.autoresizesSubviews = YES;
//    self.backgroundColor = [UIColor greenColor];
    [self addSubview:_customMap];
    [self removeAllAnnotationsOrLabels];
}

- (void)displayMap:(UIImage *)map inTraining:(BOOL)training {
    _isLoadingDialog = NO;
	[self hideCallOut];
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
	
	CGRect bounds = [Global bounds];
	if (self.customMap) {
        [self.customMap removeFromSuperview];
    }
    BOOL colordebug = NO;
	if (true || !self.customMap) {
        // for me it makes absolutely no sense whatsoever to add the view bounds to the image size.. we could just add some random value.. but as long as it doesn't cause any problems, let's leave it in..
		UIView *view = nil;
        if (training) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, map.size.width+(cMapViewFactor*(bounds.size.width)), map.size.height+(cMapViewFactor*(bounds.size.height)))];
        } else {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, map.size.width*1.25, map.size.height*1.15)];
        }
		view.backgroundColor = [UIColor whiteColor];
        if (colordebug) {
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.layer.borderWidth = 2;
            self.backgroundColor = [UIColor blackColor];
            view.backgroundColor = [UIColor greenColor];
            view.layer.borderColor = [UIColor blueColor].CGColor;
            view.layer.borderWidth = 2;
        }
        
        self.imageView = [[UIImageView alloc] initWithImage:map];
		self.imageView.userInteractionEnabled = YES;
		self.imageView.autoresizingMask = UIViewAutoresizingNone;
		self.imageView.contentMode = UIViewContentModeTopLeft;
//		self.imageView.frame = CGRectMake(view.frame.size.width/2 - map.size.width/2, view.frame.size.height/2 - map.size.height/2, map.size.width, map.size.height);
        if (training) {
            self.imageView.frame = CGRectMake(view.frame.size.width/2 - map.size.width/2, view.frame.size.height/2 - map.size.height/2, map.size.width, map.size.height);
        } else {
            self.imageView.frame = CGRectMake(view.frame.size.width/2 - map.size.width/2, map.size.height*0.05, map.size.width, map.size.height);
        }
		//imageView.layer.borderColor = [UIColor redColor].CGColor;
		//imageView.layer.borderWidth = 2.0f;
		[view addSubview:self.imageView];
		self.customMap = view;
		[self addSubview:self.customMap];
		//[imageView release];
	}	else {
        if (training) {
            self.customMap.frame = CGRectMake(0, 0, map.size.width+(cMapViewFactor*(bounds.size.width)), map.size.height+(cMapViewFactor*(bounds.size.height)));
        } else {
            self.customMap.frame = CGRectMake(0, 0, map.size.width, map.size.height);
        }
		self.imageView.image = nil;
		self.imageView.image = map;
		self.imageView.frame = CGRectMake(self.customMap.frame.size.width/2 - map.size.width/2, self.customMap.frame.size.height/2 - map.size.height/2, map.size.width, map.size.height);
	}
	
	// store orignal content size
	self.orignalSize = CGSizeMake(self.customMap.frame.size.width, self.customMap.frame.size.height);
	self.contentSize = self.orignalSize;
	
	NSLog(@"Image size  width: %f  height: %f", map.size.width, map.size.height);
	NSLog(@"cmMap size  width: %f  height: %f", self.customMap.frame.size.width, self.customMap.frame.size.height);
	NSLog(@"Orig  size  width: %f  height: %f", self.orignalSize.width, self.orignalSize.height);
	NSLog(@"IView size  width: %f  height: %f", self.imageView.frame.size.width, self.imageView.frame.size.height);
	NSLog(@"Bound size  width: %f  height: %f", bounds.size.width, bounds.size.height);
}

- (void)addAnnotation:(NAAnnotation *)annotation animated:(BOOL)animate {
    if (_isLoadingDialog) {
        return;
    }
	NAPinAnnotationView *pinAnnotation = [[NAPinAnnotationView alloc] initWithAnnotation:annotation onView:self animated:animate];
	
	if (!_pinAnnotations) {
		_pinAnnotations = [[NSMutableArray alloc] init]; // Why does this leak?
	}
	
	[self.pinAnnotations addObject:pinAnnotation];
}

- (void)addAnnotation:(NAAnnotation *)annotation withDelegate:(id)target {
    if (_isLoadingDialog) {
        return;
    }
	NAPinAnnotationView *pinAnnotation = [[NAPinAnnotationView alloc] initWithAnnotation:annotation onView:self animated:NO andDelegate:target];
	
	if (!_pinAnnotations) {
		_pinAnnotations = [[NSMutableArray alloc] init]; // Why does this leak?
	}
	
	[self.pinAnnotations addObject:pinAnnotation];
}

- (void)removeAllAnnotationsOrLabels {
	//renderMode = -1;
    _loadedFigureId = 0;
	if (self.pinAnnotations) {
		for (NAPinAnnotationView *view in self.pinAnnotations) {
			[view removeFromSuperview];
		}
		_pinAnnotations = [[NSMutableArray alloc] init]; // Why does this leak?
	}
	if (self.label) {
		@try {
			//[self removeObserver:self.label forKeyPath:@"contentSize"];
			[self.label removeFromSuperview];
			self.label = nil;
		}
		@catch (NSException *exception) {
			NSLog(@"");
		}
	}
	
}

- (void)addLabels:(NSArray *)labels withDelegate:(id)target {
    if (_isLoadingDialog) {
        return;
    }
	//renderMode = 1;
	for (NALabel *label in labels) {
		if(!self.label){
			self.label = [[NALabelView alloc] initWithLabel:label onView:self];
			self.label.delegate = target;
		}
		else {
			[self.label addLabel:label];
		}
	}
}

// The callout should belong to this class...
- (IBAction)showCallOut:(id)sender {
	for (NAPinAnnotationView *pin in self.pinAnnotations) {
		if (pin == sender && ![pin.annotation.title isEqual:[NSNull null]]) {
			if (!self.callout) {
				// create the callout
				NACallOutView * calloutView = [[NACallOutView alloc] initWithAnnotation:pin.annotation onMap:self];
				calloutView.layer.zPosition = CGFLOAT_MAX;
				self.callout = calloutView;
				
				[self addObserver:self.callout forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
				[self addSubview:self.callout];
			}	else {
				[self hideCallOut];
				[self.callout displayAnnotation:pin.annotation];
				
			}
			
			// centre the map
			//[self centreOnPoint:pin.annotation.point animated:YES];
			
			break;
		}
	}
}

- (BOOL)hideCallOut {
	BOOL state = self.callout.hidden;
	if(!self.callout)
		state = YES;
	
	self.callout.hidden = YES;
	return state;
}

- (void)centreOnPoint:(CGPoint)point animated:(BOOL)animate {
	float x = (point.x * self.zoomScale) - (self.frame.size.width / 2.0f);
	float y = (point.y * self.zoomScale) - (self.frame.size.height / 2.0f);
	
	[self setContentOffset:CGPointMake(x, y) animated:animate];
}

-(void)centerMap {
	float x;
	float y;
	
		x = (self.contentSize.width - self.bounds.size.width) / 2.0f;
		y = (self.contentSize.height - self.bounds.size.height) / 2.0f;
	
    // there are some very weird results if the content is smaller than the frame, so simply don't do anything, it should already be centered anyway.
    if (x > 0 && y > 0) {
        [self setContentOffset:CGPointMake(x, y) animated:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.dragging) {
		[self hideCallOut];
	}
	
	[super touchesEnded:touches withEvent:event];
}

- (void)dealloc {
	// Remove observers
	if (self.callout) {
		[self removeObserver:self.callout forKeyPath:@"contentSize"];
	}
	self.customMap = nil;
}

/*
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    NSLog(@"scrollViewWillBeginZooming");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    NSLog(@"scrollViewDidEndZooming");
}
 */

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidZoom.");
	[self updatePinPosition];
	if(self.label) {
		[self.label updatePositions];
    }
    if (self.callout) {
//        NSLog(@"update callout position. %@",NSStringFromCGSize( self.contentSize));
        [self.callout updatePosition];
        [self setNeedsDisplay];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if(self.label)
		[self.label updatePositions];
}

//Center the map/image when smaller than bounds
- (void)layoutSubviews {
	//Keep the image centered
	[super layoutSubviews];
    if (_isLoadingDialog) {
        return;
    }
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = self.customMap.frame;
	
	CGFloat xfactor = (self.contentSize.width / self.orignalSize.width);
	CGFloat yfactor = (self.contentSize.height / self.orignalSize.height);
	
	//center horizontally
	if(frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width- frameToCenter.size.width) /2;
	else
		frameToCenter.origin.x = 0;
	
	
	
	//center vertically
	if(frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2;
	else
		frameToCenter.origin.y = 0;
	
	self.customMap.frame = frameToCenter;
	
	//Reposition Pin Annotations
	for (NAPinAnnotationView* pin in self.pinAnnotations) {
		pin.annotation.offset = CGPointMake(frameToCenter.origin.x + self.imageView.frame.origin.x*xfactor, frameToCenter.origin.y + self.imageView.frame.origin.y*yfactor);
	}
		
	[self updatePinPosition];
	[self updateLabelPosition];
}

- (void)updateLabelPosition {
	if(self.label){
		self.label.frame = self.frame;
		[self.label updatePositions];
	}
}

- (void)updatePinPosition {	
	for (NAPinAnnotationView* pin in self.pinAnnotations) {
		float      width   = (self.contentSize.width / self.orignalSize.width) * pin.annotation.point.x;
		float      height  = (self.contentSize.height / self.orignalSize.height) * pin.annotation.point.y;
		pin.frame = [pin frameForPoint:CGPointMake(width, height)];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_isLoadingDialog) {
        return nil;
    }
	return self.customMap;
}

#pragma mark -
#pragma mark Printing

- (void)drawRect:(CGRect)rect forViewPrintFormatter:(UIViewPrintFormatter *)formatter {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat xfactor = (rect.size.width / self.imageView.image.size.width);
	CGFloat yfactor = (rect.size.height / self.imageView.image.size.height);
	CGFloat fontSize = xfactor * cLabelViewFont_Size;
	CGPoint offset = CGPointZero;
	CGRect drawImageRect = CGRectZero;
	
	//Get the correct size for the rect
	if(self.imageView.image.size.width > self.imageView.image.size.height){
		drawImageRect = CGRectMake(0, (rect.size.height/2) - ((self.imageView.image.size.height * xfactor)/2), rect.size.width, self.imageView.image.size.height * xfactor);
		yfactor = (drawImageRect.size.height / self.imageView.image.size.height);
	}
	else {
		drawImageRect = CGRectMake((rect.size.width/2) - ((self.imageView.image.size.width * yfactor)/2), 0, self.imageView.image.size.width * yfactor, rect.size.height);
		fontSize = yfactor * cLabelViewFont_Size;
		xfactor = (drawImageRect.size.width / self.imageView.image.size.width);
	}
	offset = CGPointMake(drawImageRect.origin.x, drawImageRect.origin.y);
	
	[self.imageView.image drawInRect:drawImageRect];
	
	for (NALabel *label in self.label.labels) {
		if([label.title isEqual:[NSNull null]]) {
			//KWLogDebug(@"[%@] Label String was null", self.class);
			continue;
		}
		
		CGContextBeginPath(context);
		
		UIFont* font = [UIFont systemFontOfSize:fontSize];
		if(label.relevant)
			font = [UIFont boldSystemFontOfSize:fontSize];
		
		CGSize textSize = [self.label calculateMaxTextWidth:label.title forFont:font];
		
		CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
		if(label.disabled)
			CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
		if(label.selected)
			CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
		
		if([label.align isEqualToString:@"l"]){
			[label.title drawInRect:CGRectMake((label.labelPoint.x * xfactor)+offset.x, (label.labelPoint.y * yfactor)+offset.y, textSize.width, textSize.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
		}
		else {
			[label.title drawInRect:CGRectMake(((label.labelPoint.x * xfactor)-textSize.width)+offset.x, (label.labelPoint.y * yfactor)+offset.y, textSize.width, textSize.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
		}
		
		CGContextStrokePath(context);
	}
}


@end
