@class MHPagingScrollView;

@protocol MHPagingScrollViewDelegate <NSObject>
- (NSInteger)numberOfPagesInPagingScrollView:(MHPagingScrollView *)pagingScrollView;
- (UIView *)pagingScrollView:(MHPagingScrollView *)pagingScrollView pageForIndex:(NSInteger)index;
- (void)currentPageChanged:(NSInteger)index;
@end


@interface MHPagingScrollView : UIScrollView
@property (nonatomic, weak) IBOutlet id <MHPagingScrollViewDelegate> pagingDelegate;
@property (nonatomic, assign) UIEdgeInsets previewInsets;

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)indexOfSelectedPage;
- (UIView*)pageAtIndex:(NSInteger)index;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (UIView *)dequeueReusablePage;
- (void)reloadPages;
- (void)scrollViewDidScroll;
- (void)beforeRotation;
- (void)afterRotation;
- (void)didReceiveMemoryWarning;
- (void)setViewHeight:(CGFloat)height;

@end
