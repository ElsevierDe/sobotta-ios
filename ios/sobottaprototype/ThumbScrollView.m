//
//  ThumbScrollView.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 30.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ThumbScrollView.h"
#import "ThumbImageView.h"

@implementation ThumbScrollView {
	NSInteger currentImageIndex;
}
//@synthesize delegate;

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 20
#define THUMB_H_PADDING 20

- (id)init {
	self = [super init];
	if(self){
		
		
	}
	return self;
}

-(id)initWithImageNames:(NSArray *)names onTarget:(id<ThumbImageViewDelegate>)target {
	self = [super init];
	if(self){
		imageNames = names;
		delegateTarget = target;
		
		self.delegate = self;
		self.showsVerticalScrollIndicator = YES;
		[self setCanCancelContentTouches:NO];
        [self setClipsToBounds:NO];
		
		self.frame = [self frameForPagingScrollView];
		[self setContentSize:CGSizeMake((THUMB_HEIGHT+THUMB_H_PADDING)*imageNames.count + (2*THUMB_H_PADDING), THUMB_HEIGHT + THUMB_V_PADDING)];
		
		recycledPages = [[NSMutableSet alloc] init];
		visiblePages  = [[NSMutableSet alloc] init];
		
		[self tileImages];
	}
	return self;
}

- (void)updateOrientation {
	self.frame = [self frameForPagingScrollView];
	[self tileImages];
}

-(void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
	//if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
    //    [delegate thumbImageViewWasTapped:tiv];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self tileImages];
}

- (int)pageCount {
	return imageNames.count;
}

- (void)setCurrentImage:(NSInteger)index andCenter:(BOOL)center {
	currentImageIndex = index;

	if(center) {
        if (IS_PHONE) {
            NSLog(@"bounds: %@", NSStringFromCGSize(self.bounds.size));
            CGPoint imagepoint = CGPointMake(((THUMB_HEIGHT+THUMB_H_PADDING) * MAX(index,0)) - (self.bounds.size.width/2) + (THUMB_HEIGHT/2) + THUMB_H_PADDING, 0);
//            if([Global InterfaceOrientationIsLandscape])
//                imagepoint.x -= ((THUMB_HEIGHT/2)+THUMB_H_PADDING);
            if(imagepoint.x < 0)
                imagepoint.x = 0;
            self.contentOffset = imagepoint;
        } else {
            CGPoint imagepoint = CGPointMake((THUMB_HEIGHT+THUMB_H_PADDING) * MAX(index-2,0), 0);
            if([Global InterfaceOrientationIsLandscape])
                imagepoint.x -= ((THUMB_HEIGHT/2)+THUMB_H_PADDING);
            if(imagepoint.x < 0)
                imagepoint.x = 0;
            self.contentOffset = imagepoint;
        }
	}
	
	[self updateSelectedImage];
}

-(void)tileImages {
	// Calculate which pages are visible
    CGRect visibleBounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, Global.bounds.size.width, self.bounds.size.height);
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / (THUMB_HEIGHT+THUMB_H_PADDING));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / (THUMB_HEIGHT+THUMB_H_PADDING));
	firstNeededPageIndex = MAX(firstNeededPageIndex-1, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self pageCount] - 1);
	
	//KWLogDebug(@"FirstPage: %d   LastPage: %d", firstNeededPageIndex, lastNeededPageIndex);
		
    // Recycle no-longer-visible pages
    for (ThumbImageView *page in visiblePages) {
        if (page.imageIndex < firstNeededPageIndex || page.imageIndex > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ThumbImageView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ThumbImageView alloc] init];
				[page setDelegate:delegateTarget];
            }
			[visiblePages addObject:page];
            [self configurePage:page forIndex:index];
            [self addSubview:page];
        }
    }
	
	[self updateSelectedImage];
}

- (void)updateSelectedImage {
	for (ThumbImageView *page in visiblePages) {
		if(page.imageIndex == currentImageIndex){
			page.alpha = 1;
		}
		else {
			page.alpha = 0.7;
		}
	}
}

- (ThumbImageView *)dequeueRecycledPage
{
    ThumbImageView *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

- (void)configurePage:(ThumbImageView *)page forIndex:(NSUInteger)index
{
	page.imageIndex = index;
    page.frame = [self frameForPageAtIndex:index];
    NSString *dbPath = [DatabaseController Current].dataPath;

//	page.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[imageNames objectAtIndex:index] ofType:@"jpg" inDirectory:@"export/figures/thumbs/"]];
    page.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[imageNames objectAtIndex:index] ofType:@"jpg" inDirectory:[NSString stringWithFormat:@"%@/figures/thumbs/", dbPath]]];
    page.isAccessibilityElement = YES;
    page.accessibilityIdentifier = [NSString stringWithFormat:@"thumb_%@", [imageNames objectAtIndex:index]];

}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ThumbImageView *page in visiblePages) {
        if (page.imageIndex == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (CGRect)frameForPagingScrollView {
	float scrollViewHeight = THUMB_HEIGHT + (THUMB_V_PADDING*2);
	float scrollViewWidth  = Global.bounds.size.width;
	
	CGRect frame = CGRectMake(0, 0, scrollViewWidth, scrollViewHeight);
	return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect pageFrame = CGRectMake(((THUMB_HEIGHT+THUMB_H_PADDING)*index)+THUMB_H_PADDING, THUMB_V_PADDING, THUMB_HEIGHT, THUMB_HEIGHT);
    return pageFrame;
}

@end
