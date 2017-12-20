//
//  ImageGridViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/20/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridViewController.h"
#import "ImageGridCell.h"
#import "ImageViewController.h"
#import "MasterViewController.h"
#import "MainSplitViewController.h"
#import "AutocompleteViewController.h"
#import "DejalActivityView.h"
#import "SOBNavigationViewController.h"
#import "GAI.h"
#import <Crashlytics/Crashlytics.h>

//#define CELLSIZE_DEFAULT 220.f
//#define CELLSIZE_DEFAULT 240.f
#define CELLSIZE_DEFAULT 230.f
#define CELLSIZE_MIN 150.f
#define CELLSIZE_MAX 500.f

#define CELLPADDING (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 10.f : 50.f)
#define CELLPADDING_HEIGHT 20.f
//#define CELLPADDING 10.f
#define GRIDSIZE_CONFIG @"gridsizeConfig"

@implementation ImageGridViewController



#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fullVersionController = [FullVersionController instance];
        dbController = [DatabaseController Current];
//        _figureDatasource = [[FigureDatasource alloc] init];
//        _figureDatasource.delegate = self;
        _figureDatasource = [FigureDatasource defaultDatasource];
        _requestLoadMasterView = NO;
        _jumpToPosition = -1;

    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(figureDatasourceDataChangedEvent:) name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(figureDatasourceStartsLoading:) name:SOB_FIGUREDATASOURCE_STARTSLOADING object:nil];
        

    }
    return self;
}


- (void)languageChanged:(NSNotification *)notification {
//    if (self.isViewLoaded && self.view.window) {
//        [self reloadData];
//    }
}

- (void)loadView {
    [super loadView];
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
    [wrapperView addSubview:self.view];
    wrapperView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    UIView *loading = nil;
    if (IS_PHONE) {
        loading = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60, self.view.bounds.size.height / 2 - 60, 120, 120)];
    } else {
        loading = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60 - 120, self.view.bounds.size.height / 2 - 60 - 120, 120, 120)];
    }
    
    loading.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    loading.layer.cornerRadius = 15;
    loading.opaque = NO;
    loading.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.frame = CGRectMake(42, 42, 37, 37);
    
    [loading addSubview:_activityIndicator];
    _loading = loading;
    _loading.hidden = YES;
    
//    [self.view addSubview:_activityIndicator];
    [wrapperView addSubview:loading];
    self.view = wrapperView;
}

- (void)viewDidLoad
{
    
    _isInitialized = NO;
    [super viewDidLoad];
    
    
    
    loadsearchqueue = dispatch_queue_create("com.austrianapps.ios.elsevier.kls", NULL);
    
    CLS_LOG(@"ImageGridViewController.viewDidLoad - requestSearch: %d", _requestSearch);

    //self.title = @"Hehe";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int gridSize = [userDefaults integerForKey:GRIDSIZE_CONFIG];
    if (gridSize == 0) {
        _currentGridSize = 1;
    } else {
        _currentGridSize = gridSize - 1;
    }
    
    
    //Init Segmented Control
	_gridSizeSelector = [[UISegmentedControl alloc]initWithItems:[NSArray array]];
	[_gridSizeSelector insertSegmentWithTitle:@"5x3" atIndex:0 animated:NO];
	[_gridSizeSelector insertSegmentWithTitle:@"3x3" atIndex:1 animated:NO];
	[_gridSizeSelector insertSegmentWithTitle:@"2x2" atIndex:2 animated:NO];
	_gridSizeSelector.segmentedControlStyle = UISegmentedControlStyleBar;
	[_gridSizeSelector addTarget:self action:@selector(changeGridSizePressed:) forControlEvents:UIControlEventValueChanged];
	_gridSizeSelector.selectedSegmentIndex = 1;

	UIBarButtonItem *segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:_gridSizeSelector];

    
    
    
    
    
//    self.gridView.cellSize = CGSizeMake(CELLSIZE_DEFAULT, CELLSIZE_DEFAULT);
    self.gridView.cellPadding = CGSizeMake(CELLPADDING, CELLPADDING_HEIGHT);
    [self updateCellSize];
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(myGestureRecognized:)];
    [self.view addGestureRecognizer:_pinchGestureRecognizer];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _searchBar.backgroundImage = [[UIImage alloc] init];
    _searchBar.delegate = self;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_searchBar], segmentedControlItem];

    MainSplitViewController *msvc = (MainSplitViewController*)[self splitViewController];
    
    if (_figureDatasource.chapterId) {
        [self loadMasterView:NO];
        [self loadForChapterId:_figureDatasource.chapterId];
    }
    if (_requestSearch) {
        MainSplitViewController *msvc = (MainSplitViewController *)self.splitViewController;
        UINavigationController *navcontroller = [msvc.viewControllers objectAtIndex:0];
        MasterViewController *oldmvc = [[navcontroller viewControllers] lastObject];
        if (!_requestSearchFromMasterView) {
            [msvc.splitViewBarButton.target performSelector: msvc.splitViewBarButton.action withObject: msvc.splitViewBarButton];
        }
        if ([oldmvc isKindOfClass:[MasterViewController class]]) {
            [oldmvc performSegueWithIdentifier:@"openSearch" sender:self];
        } else {
            [((AutocompleteViewController *)oldmvc).searchBar becomeFirstResponder];
        }
    }
    if (_requestLoadMasterView || _requestSearchFromMasterView) {
        _requestLoadMasterView = NO;
        [self loadMasterView:YES];
        [msvc willPresentMasterViewControllerInImageGrid];
    }

    _isInitialized = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // track view...
    if (_figureDatasource.chapterId) {
        Section *section = [dbController chapterById:_figureDatasource.chapterId];
        [[DatabaseController Current] trackView:[NSString stringWithFormat:@"FigureList/%@", section.nameEnen]];
    } else {
        [[DatabaseController Current] trackView:@"FigureList"];
    }
}

- (void)viewWillLayoutSubviews {
    [self updateCellSize];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"View did layout subviews!");
    if (_jumpToPosition > -1) {
        [self.gridView scrollToItemAtIndexPath:[KKIndexPath indexPathForIndex:0 inSection:_jumpToPosition] animated:NO position:KKGridViewScrollPositionTop];
        _jumpToPosition = -1;
    }
}


- (void)viewDidUnload {
    NSLog(@"image grid did unload!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
    [super viewDidUnload];
}

- (void)setCurrentGridSize:(int)currentGridSize {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:currentGridSize+1 forKey:GRIDSIZE_CONFIG];
    _currentGridSize = currentGridSize;
    if (_isInitialized) {
        [self updateCellSize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view will disappear ...");
    if (_searchBar/* && _searchBar.isFirstResponder */) {
        NSLog(@"view should resign first responder.");
        [_searchBar resignFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) changeGridSizePressed:(id) sender {
    [self updateCellSize];
}

- (void) updateCellSize {
    int selectedItem = _currentGridSize;
    int itemsPerLine = 1;
    switch (selectedItem) {
        case 2:
            itemsPerLine = 5;
            break;
        case 1:
            itemsPerLine = 3;
            break;
        case 0:
            itemsPerLine = 2;
            break;
    }
    float totalWidth = self.view.frame.size.width;
    totalWidth = totalWidth - (itemsPerLine * CELLPADDING) - CELLPADDING;
    float itemWidth = totalWidth / itemsPerLine;
    itemWidth -= 1;
//    itemWidth = itemWidth - (CELLPADDING*2) - 2*CELLPADDING;
    NSLog(@"view: %f / frame.size.width: %f / bounds.size.width: %f / cellSize: %f / cellpadding: %f", self.view.frame.size.width, self.gridView.frame.size.width, self.gridView.bounds.size.width, itemWidth, CELLPADDING);
    self.gridView.cellSize = CGSizeMake(itemWidth, itemWidth + LABEL_HEIGHT);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateCellSize];
}



#pragma mark - KKGridView

- (NSUInteger)numberOfSectionsInGridView:(KKGridView *)gridView
{
    NSLog(@"ImageGridViewController.numberOfSectionsInGridView: %d", [_figureDatasource sectionCount]);
    return [_figureDatasource sectionCount];
    /*
    if (_sections) {
        NSLog(@"number of sections: %d", [_sections count]);
        return [_sections count];
    }
    return 0;*/
}

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    return [_figureDatasource numberofItemsInSection:section];
}

- (UIView *)gridView:(KKGridView *)gridView viewForHeaderInSection:(NSUInteger)section {
    //ImageGridSectionHeaderLabel *label = [[ImageGridSectionHeaderLabel alloc] initWithString:[self titleForHeaderInSection:section]];
    ImageGridHeaderView *label = [[ImageGridHeaderView alloc] initWithString:[self titleForHeaderInSection:section]];
    label.imageGridViewController = self;
    label.figureDatasource = _figureDatasource;
    label.sectionIdx = section;
    
    return label;
    
    /*
    KKGridViewSectionLabel *label = [[KKGridViewSectionLabel alloc] initWithString:[self gridView:self titleForHeaderInSection:section]];
    return label;
     */
}

//- (NSString *)gridView:(KKGridView *)gridView titleForHeaderInSection:(NSUInteger)section
- (NSString *) titleForHeaderInSection:(NSUInteger)section
{
    return [_figureDatasource sectionTitleAtIndex:section];
}

- (CGFloat)gridView:(KKGridView *)gridView heightForHeaderInSection:(NSUInteger)section {
//    NSLog(@"blah: %f", [ImageGridHeaderView height]);
    return [ImageGridHeaderView height];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    ImageGridCell *cell = [ImageGridCell cellForGridView:gridView];
    FigureInfo *figure = [_figureDatasource figureAtIndex:indexPath.index inSection:indexPath.section];
    /*
    if ([_sections count] <= indexPath.section) {
        NSLog(@"we don't know about that section.");
        return nil;
    }
    SectionInfo *sectionInfo = [_sections objectAtIndex:indexPath.section];
    if ([sectionInfo.images count] <= indexPath.index) {
        NSLog(@"section info does not contain that many items.");
        return nil;
    }
     FigureInfo *figure = [sectionInfo.images objectAtIndex:indexPath.index];
     */
    if (!figure) {
        NSLog(@"Unable to find figure!");
        // we are not allowed to return nil, so simply return a dummy object..
        return cell;
    }
    
    [cell showFigureInfo:figure fromDatasource:_figureDatasource inQueue:loadsearchqueue];
    
    //cell.label.text = [NSString stringWithFormat:@"%u", indexPath.index];
    
    //CGFloat percentage = (CGFloat)indexPath.index / (CGFloat)[[_fillerData objectAtIndex:indexPath.section] count];
    //cell.contentView.backgroundColor = [UIColor colorWithWhite:percentage alpha:1.f];
    
    return cell;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"shouldREcognizeSimultaneouslyWithGestureRecognizer...");
    return YES;
}

- (void)gestureRecognized:(UIGestureRecognizer *)sender {
    NSLog(@"recognized gesture");
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"gesture recognizer should begin?");
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"should receive touch?");
    return YES;
}

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    if (self.navigationController.topViewController != self) {
        NSLog(@"topViewController is not self, doing nothing.");
        return;
    }
    [gridView deselectAll:NO];
    FigureInfo *figure = [_figureDatasource figureAtIndex:(int)indexPath.index inSection:(int)indexPath.section];
    if (![_fullVersionController allowShowFigure:figure]) {
        [_figureDatasource showPaidVersionTeaser: self chapterId:@(figure.level1id)];
        return;
    }
    [_figureDatasource setCurrentSelection:figure];
    
//    SectionInfo *sectionInfo = [_sections objectAtIndex:indexPath.section];
//    FigureInfo *figure = [sectionInfo.images objectAtIndex:indexPath.index];
//    _selectedItem = figure;
	//selectedItem = [figures objectForKey:[[figures allKeys] objectAtIndex:position]];
	[self performSegueWithIdentifier:@"showImage" sender:self];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showImage"]) {
        //_sections = nil;
        //[self.gridView reloadData];
        [(ImageViewController *)[segue destinationViewController] setFigure: _figureDatasource];
    }
}

- (IBAction)myGestureRecognized:(UIPinchGestureRecognizer *)sender {
    //NSLog(@"Recognized gesture. HATSCHI");
    /*
    if (sender.state == UIGestureRecognizerStateBegan) {
        _scaleStartSize = self.gridView.cellSize;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        float cellsize = _scaleStartSize.width * sender.scale;
        if (cellsize < CELLSIZE_MIN) {
            cellsize = CELLSIZE_MIN;
        } else if (cellsize > CELLSIZE_MAX) {
            cellsize = CELLSIZE_MAX;
        }
        self.gridView.cellSize = CGSizeMake(cellsize, cellsize);
        NSLog(@"cellsize: %f", cellsize);
    }
     */
}


- (void) jumpToSectionAtPosition: (int) sectionPosition {
    NSLog(@"we need to scroll to %d -- %d", sectionPosition, self.isViewLoaded);
    if (!self.isViewLoaded) {
        _jumpToPosition = sectionPosition;
    }
    [self.gridView scrollToItemAtIndexPath:[KKIndexPath indexPathForIndex:0 inSection:sectionPosition] animated:YES position:KKGridViewScrollPositionTop];
}

- (void) loadForChapterId: (int) chapterId {
    if (_figureDatasource.chapterId != chapterId) {
        [_figureDatasource loadForChapterId:chapterId];
    }
    NSString *title = [dbController chapterNameById:chapterId];
    self.title = title;
    NSLog(@"loading for chapter %d - %@", chapterId, title);
//    [self reloadData];
}

- (void) reloadData {
    //    [self _asyncLoadForChapterId:chapterId];
    [_figureDatasource reloadData];
}


- (void) requestLoadMasterView {
    _requestLoadMasterView = YES;
}



- (void) loadMasterView:(BOOL)animated {
    NSLog(@"Loading master view ...");
    if (_figureDatasource.chapterId) {
        MainSplitViewController *msvc = (MainSplitViewController *)self.splitViewController;
        UINavigationController *navcontroller = [msvc.viewControllers objectAtIndex:0];
        MasterViewController *oldmvc = [[navcontroller viewControllers] lastObject];
        if ([oldmvc isKindOfClass:[AutocompleteViewController class]]) {
            return;
            //[navcontroller popViewControllerAnimated:NO];
        } else if (![oldmvc isKindOfClass:[MasterViewController class]]) {
            [navcontroller popToRootViewControllerAnimated:NO];
        } else {
            if (oldmvc.chapterId) {
                if (oldmvc.chapterId != _figureDatasource.chapterId) {
                    oldmvc.chapterId = _figureDatasource.chapterId;
                }
                return;
            }
        }

        MasterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
        self.masterViewController = vc;
        vc.chapterId = _figureDatasource.chapterId;
        if (_figureDatasource.sections) {
            vc.sections = _figureDatasource.sections;
        } else {
            vc.sections = [NSArray array];
        }
        //vc.splitViewController = msvc;
        [navcontroller pushViewController:vc animated:animated];
    } else {
        if (animated) {
            _requestLoadMasterView = YES;
        }
    }

    NSLog(@"Done.");
}

- (void)didReceiveMemoryWarning {
    NSLog(@"did receive memory warning!!!");
    [super didReceiveMemoryWarning];
}

#pragma mark UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!_searchPopover) {
        _searchController = [[SearchAutocompleteViewController alloc] initWithStyle:UITableViewStylePlain];
        _searchController.imageGrid = self;
        _searchController.chapterId = _figureDatasource.chapterId;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_searchController];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        _searchPopover = popover;
        _searchPopover.delegate = self;
        
        // Ensure the popover is not dismissed if the user taps in the search bar.
        popover.passthroughViews = [NSArray arrayWithObject:searchBar];
        // Display the search results controller popover.
        [_searchPopover presentPopoverFromRect:[searchBar bounds]
                                                         inView:searchBar
                                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchController filterResultsUsingString:searchText];
    _figureDatasource.searchText = searchText;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [_searchBar resignFirstResponder];
    _searchPopover = nil;
    _searchController = nil;
}

- (void)figureDatasourceDataChanged {
}
- (void) figureDatasourceDataChangedEvent:(NSNotification *)notification {
    _loading.hidden = YES;
    if (self.isViewLoaded) {
        [_activityIndicator stopAnimating];
        [self.gridView reloadData];
    }
    if (_figureDatasource.chapterId) {
        NSString *title = [dbController chapterNameById:_figureDatasource.chapterId];
        self.title = title;
    }
    if (_figureDatasource.searchText) {
        self.title = NSLocalizedString(@"Search results", nil);
    }
    if (_requestLoadMasterView) {
        _requestLoadMasterView = NO;
        [self loadMasterView:YES];
    }
    if (_masterViewController) {
        _masterViewController.sections = _figureDatasource.sections;
    }
}
- (void) figureDatasourceStartsLoading:(NSNotification *)notification {
    if (_figureDatasource.isLoading && self.isViewLoaded) {
//        [self reloadData];
        _loading.hidden = NO;
        [_activityIndicator startAnimating];
    }
}

- (void) startTrainingForSectionIdx: (NSUInteger) sectionIdx {
    if ([[DatabaseController Current] hasRunningTraining]) {
        
        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Start new Training: Training in progress", nil) message:NSLocalizedString(@"Start new Training: There is already a training in progress. Do you want to end the current training?", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Start new Training", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self doStartTrainingForSectionIdx:sectionIdx];
            }
        }];
        
    } else {
        [self doStartTrainingForSectionIdx:sectionIdx];
    }
}

- (void)doStartTrainingForSectionIdx:(NSUInteger)sectionIdx {

    SectionInfo *sectionInfo = [_figureDatasource sectionAtIndex:sectionIdx];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    Bookmarklist *list = (Bookmarklist *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmarklist" inManagedObjectContext:appDelegate.managedObjectContext ];
    list.name = [dbController chapterNameById:[sectionInfo.chapterId intValue]];
    list.updated = [NSDate date];
    list.deleted = [NSNumber numberWithBool:YES];
    list.sectionalias = [NSNumber numberWithBool:YES];
    NSError *error = nil;
    [appDelegate.managedObjectContext save:&error];
    
    
    [_figureDatasource addFiguresOfSectionIdx:sectionIdx intoBookmarkList:list];
    
    
    [_figureDatasource loadForBookmarklist:list];
    
    
    ImageViewController* ivc = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    [ivc setFigure:_figureDatasource];
    SOBNavigationViewController *sobNavigationViewController = (SOBNavigationViewController*) self.navigationController;
    [ivc startTrainingOrPostpone:sobNavigationViewController.resumeTrainingItem createOption:CreateTrainingOptionAllFromDatasource];

    [sobNavigationViewController pushViewController:ivc animated:YES];
    
    

}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOB_FIGUREDATASOURCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOBLANGUAGECHANGED object:nil];
//    dispatch_release(loadsearchqueue);
    loadsearchqueue = nil;
}


@end
