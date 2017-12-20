
#import "MHPagingScrollView.h"

@interface MHPage : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) NSInteger index;

@end

@implementation MHPage

@synthesize view;
@synthesize index;

@end

@implementation MHPagingScrollView
{
	NSMutableSet *recycledPages;
	NSMutableSet *visiblePages;
	int firstVisiblePageIndexBeforeRotation;      // for autorotation
	CGFloat percentScrolledIntoFirstVisiblePage;
}

@synthesize previewInsets;
@synthesize pagingDelegate;

- (void)commonInit
{
	recycledPages = [[NSMutableSet alloc] init];
	visiblePages  = [[NSMutableSet alloc] init];

	self.pagingEnabled = YES;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.contentOffset = CGPointZero;
	self.bounces = YES;
	self.alwaysBounceHorizontal = YES;
	self.alwaysBounceVertical = NO;
	self.bouncesZoom = NO;
	self.exclusiveTouch = YES;
	self.delaysContentTouches = NO;
    self.pagingDelegate = nil;
	
	//self.layer.borderColor = [UIColor redColor].CGColor;
	//self.layer.borderWidth = 2.0f;
	//self.previewInsets = UIEdgeInsetsMake(0, 30, 0, 30);
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self commonInit];
	}
	return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	// This allows for touch handling outside of the scroll view's bounds.

	CGPoint parentLocation = [self convertPoint:point toView:self.superview];

	CGRect responseRect = self.frame;
	responseRect.origin.x -= previewInsets.left;
	responseRect.origin.y -= previewInsets.top;
	responseRect.size.width += (previewInsets.left + previewInsets.right);
	responseRect.size.height += (previewInsets.top + previewInsets.bottom);

	return CGRectContainsPoint(responseRect, parentLocation);
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index == NSNotFound) {
//        NSLog(@"WHAT THE FUCK?!");
        return;
    }
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}

//    NSLog(@"selectPageAtIndex(%d): %f", index, self.bounds.size.width * index);
	self.contentOffset = CGPointMake(self.bounds.size.width * index, 0);

	if (animated)
		[UIView commitAnimations];
}

- (NSInteger)indexOfSelectedPage
{
	CGFloat width = self.bounds.size.width;
	int currentPage = (self.contentOffset.x + width/2.0f) / width;
	return currentPage;
}

- (UIView*)pageAtIndex:(NSInteger)index {
	for (MHPage* page in visiblePages) {
		if(page.index == index)
			return page.view;
	}
	return nil;
}

- (NSInteger)numberOfPages
{
	return [pagingDelegate numberOfPagesInPagingScrollView:self];
}

- (CGSize)contentSizeForPagingScrollView
{
	CGRect rect = self.bounds;
	return CGSizeMake(rect.size.width * [self numberOfPages], rect.size.height);
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	for (MHPage *page in visiblePages)
	{
		if (page.index == index)
			return YES;
	}
	return NO;
}

- (UIView *)dequeueReusablePage
{
	MHPage *page = [recycledPages anyObject];
	if (page != nil)
	{
		UIView *view = page.view;
		[recycledPages removeObject:page];
		return view;
	}
	return nil;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
	CGRect rect = self.bounds;
	rect.origin.x = rect.size.width * index;
	return rect;
}

- (void)tilePages 
{
	CGRect visibleBounds = self.bounds;
    NSLog(@"tilePages - visibleBounds: %@", NSStringFromCGRect(visibleBounds));
	CGFloat pageWidth = CGRectGetWidth(visibleBounds);
	visibleBounds.origin.x -= previewInsets.left;
	visibleBounds.size.width += (previewInsets.left + previewInsets.right);

	int firstNeededPageIndex = floorf((CGRectGetMinX(visibleBounds)+10) / pageWidth);
	int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-10) / pageWidth);
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN(lastNeededPageIndex, [self numberOfPages] - 1);
	
//	NSLog(@"FirstPage: %d   LastPage: %d --- numberOfPages: %d", firstNeededPageIndex, lastNeededPageIndex, [self numberOfPages]);
//    NSLog(@"visiblebounds: (%f, %f, %f, %f) -- rectminx: %f, cgrectmaxx: %f", visibleBounds.origin.x, visibleBounds.origin.y, visibleBounds.size.width, visibleBounds.size.height, CGRectGetMinX(visibleBounds), CGRectGetMaxX(visibleBounds));

	for (MHPage *page in visiblePages)
	{
		if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex)
		{
			[recycledPages addObject:page];
			[page.view removeFromSuperview];
		}
	}

	[visiblePages minusSet:recycledPages];

	for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; ++i)
	{
		if (![self isDisplayingPageForIndex:i])
		{
			UIView *pageView = [pagingDelegate pagingScrollView:self pageForIndex:i];
			pageView.frame = [self frameForPageAtIndex:i];
			[self addSubview:pageView];

			MHPage *page = [[MHPage alloc] init];
			page.index = i;
			page.view = pageView;
			[visiblePages addObject:page];
		}
	}
//    NSLog(@"Visible Pages: %@", visiblePages);
	
	if(firstNeededPageIndex == lastNeededPageIndex){
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		NSNumber *numIndex = [[NSNumber alloc] initWithInteger:firstNeededPageIndex];
		[self performSelector:@selector(pageChanged:) withObject:[[NSArray alloc] initWithObjects:numIndex, nil] afterDelay:0.2];
	}
}

- (void)pageChanged:(NSArray*)data {
	if(pagingDelegate) {
		NSNumber *numIndex = [data objectAtIndex:0];
		[pagingDelegate currentPageChanged:[numIndex integerValue]];
	}
}

- (void)reloadPages
{
	self.contentSize = [self contentSizeForPagingScrollView];
	[self tilePages];
}

- (void)scrollViewDidScroll
{
	[self tilePages];
}

- (void)beforeRotation
{
	CGFloat offset = self.contentOffset.x;
	CGFloat pageWidth = self.bounds.size.width;

	if (offset >= 0)
		firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
	else
		firstVisiblePageIndexBeforeRotation = 0;

	percentScrolledIntoFirstVisiblePage = offset / pageWidth - firstVisiblePageIndexBeforeRotation;
}

- (void)afterRotation
{
	self.contentSize = [self contentSizeForPagingScrollView];

	for (MHPage *page in visiblePages)
		page.view.frame = [self frameForPageAtIndex:page.index];

	CGFloat pageWidth = self.bounds.size.width;
	CGFloat newOffset = (firstVisiblePageIndexBeforeRotation + percentScrolledIntoFirstVisiblePage) * pageWidth;
	self.contentOffset = CGPointMake(newOffset, 0);
}

- (void)didReceiveMemoryWarning
{
	[recycledPages removeAllObjects];
}

- (void)setViewHeight:(CGFloat)height {
	[self beforeRotation];
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
	[self afterRotation];
}

@end
