//
//  FigureDatasource.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/29/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "FigureDatasource.h"
#import "Bookmark.h"
#import "AppDelegate.h"
#import "FakeBookmarklist.h"
#import "FigureProxy.h"
#import <mach/mach_time.h>
#import "GAI.h"
#import "FullVersionController.h"

@implementation FigureDatasource


- (id)init {
    self = [super init];
    if (self) {
        _currentSelectionIndex = -1;
        _currentSelectionFigureId = -1;
        _fullVersionController = [FullVersionController instance];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = delegate.managedObjectContext;
        _isLoading = NO;
        _searchWildCardMatch = YES;
        _cheatMode = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
    }
    return self;
}

static FigureDatasource *_defaultDatasource;


+ (FigureDatasource *) defaultDatasource; {
    if (!_defaultDatasource) {
        _defaultDatasource = [[FigureDatasource alloc] init];
    }
    return _defaultDatasource;
}

- (void)languageChanged:(NSNotification *)notification {
    [self reloadData];
}


- (long)sectionCount {
    if (_sections) {
        return [_sections count];
    }
    return 0;
}

- (int)numberofItemsInSection:(int)section {
    if (_sections) {
        SectionInfo* sectionInfo = [_sections objectAtIndex:section];
        return (int) [sectionInfo.images count];
    }
    return 0;
}

- (SectionInfo *) sectionAtIndex:(NSUInteger)section {
    if (_sections && [_sections count] > section) {
        return [_sections objectAtIndex:section];
    }
    return nil;
}

- (NSString *) sectionTitleAtIndex:(int)section {
    SectionInfo *sectionInfo = [self sectionAtIndex:section];
    if (sectionInfo) {
        NSDictionary *mapping = [[DatabaseController Current] chapterMapping];
        Section *section = [mapping objectForKey:sectionInfo.chapterId];
        Section *s = [section.children objectForKey:sectionInfo.sectionId];
        return s.name;
    }
    return @"";
}

- (FigureInfo *) figureAtIndex:(int)index inSection:(int)section {
    if ([_sections count] <= section) {
        NSLog(@"we don't know about that section.");
        return nil;
    }
    SectionInfo *sectionInfo = [_sections objectAtIndex:section];
    if ([sectionInfo.images count] <= index) {
        NSLog(@"section info does not contain that many items.");
        return nil;
    }
    FigureInfo *figure = [sectionInfo.images objectAtIndex:index];
    return figure;
}

- (void) resetContent {
    _chapterId = 0;
    _sections = nil;
    _bookmarkList = nil;
    _training = nil;
    _allfigures = nil;
    _currentSelection = nil;
    _currentSelectionFigureId = -1;
    _searchText = nil;
    _figureId = -1;
    _searchWildCardMatch = YES;
}

+ (NSString*) trainingNameLocalizedForTraining:(Training *)training {
    return [FigureDatasource trainingNameLocalizedForNameType:[training.nametype intValue] withName:training.name];
}
+ (NSString*) trainingNameLocalizedForNameType:(TrainingNameType)nameType withName:(NSString*)name {
    switch (nameType) {
        case TrainingNameTypeBookmarks:
            return [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Bookmark List", nil), name];
        case TrainingNameTypeChapter:
            return [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Chapter", nil), name];
        case TrainingNameTypeSearch:
            return [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Search for", nil), name];
        case TrainingNameTypeSingleFigure:
            return [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Figure", nil), name];
    }
    NSLog(@"Invalid training type: %d", nameType);
    return name;
}

- (NSString*) trainingNameLocalized {
    NSString *name = [self trainingName];
    return [FigureDatasource trainingNameLocalizedForNameType:[self trainingNameType] withName:name];
}

- (NSString*) trainingName {
    if (_training) {
        return _training.name;
    } else if (_searchText) {
        return _searchText;
    } else if (_chapterId) {
        return [[DatabaseController Current] chapterNameById:_chapterId];
    } else if (_bookmarkList) {
        return _bookmarkList.name;
    }
    return nil;
}
- (TrainingNameType) trainingNameType {
    if (_training) {
        return [_training.nametype intValue];
    } else if (_searchText) {
        return TrainingNameTypeSearch;
    } else if (_chapterId) {
        return TrainingNameTypeChapter;
    } else if (_bookmarkList) {
        if ([_bookmarkList.sectionalias boolValue]) {
            return TrainingNameTypeChapter;
        }
        return TrainingNameTypeBookmarks;
    }
    return 0;
}


- (void) loadForChapterId: (int) chapterId {
    [self resetContent];
    _chapterId = chapterId;
    NSLog(@"loading for chapter %d", chapterId);
    [self reloadData];
}

- (void) loadForFigureId: (long) figureId {
    [self resetContent];
    _figureId = figureId;
    _currentSelectionIndex = 0;
    [self reloadData];
}

- (void) loadForBookmarklist: (Bookmarklist *)bookmarkList {
    [self resetContent];
    _bookmarkList = bookmarkList;
    [_bookmarkList bookmarks];
    [self reloadData];
}

- (void)loadForTraining:(Training *)training finished:(void(^_Nullable)())finishedCallback {
    [self resetContent];
    _training = training;
    [self reloadData:finishedCallback];
}

- (void)loadForGlobalSearchText:(NSString *)searchText {
    [self resetContent];
    _searchText = searchText;
    _searchWildCardMatch = NO;
    [self reloadData];
}

- (void) reloadData {
    [self reloadData:nil];
}

- (void) reloadData:(void(^_Nullable)())finishedCallback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [self _asyncLoad:finishedCallback];
    });
}


- (void) setSearchText:(NSString *)searchText {
    // we only remember chapter Id for now.
    if (searchText && [[searchText lowercaseString] isEqualToString:@"xxtapodebug"]) {
        _cheatMode = !_cheatMode;
        
        [_managedObjectContext lock];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FigureProxy"];
        NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        for (FigureProxy *proxy in ret) {
            NSLog(@"figure_id: %@ / best percent: %@ / worst percent: %@", proxy.figure_id, proxy.bestTrainingResult.percent_correct, proxy.worstTrainingResult.percent_correct);
        }
        
        [_managedObjectContext unlock];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"FTW" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    int chapterId = _chapterId;
    [self resetContent];
    _chapterId = chapterId;
    if (searchText && searchText.length == 0) {
        searchText = nil;
    }
    _searchText = searchText;
    [self reloadData];
}

void logMachTime_withIdentifier_(uint64_t machTime, NSString *identifier) {
    static double timeScaleSeconds = 0.0;
    if (timeScaleSeconds == 0.0) {
        mach_timebase_info_data_t timebaseInfo;
        if (mach_timebase_info(&timebaseInfo) == KERN_SUCCESS) {    // returns scale factor for ns
            double timeScaleMicroSeconds = ((double) timebaseInfo.numer / (double) timebaseInfo.denom) / 1000;
            timeScaleSeconds = timeScaleMicroSeconds / 1000000;
        }
    }
    
    NSLog(@"%@: %g seconds", identifier, timeScaleSeconds*machTime);
}



- (void) _asyncLoad:(void(^_Nullable)())finishedCallback {
    FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
    NSString *searchedText = _searchText;
    [queue inDatabase:^(FMDatabase *db) {
        if (searchedText != _searchText) {
            NSLog(@"search text changed even before we could do anything. abort.");
            return;
        }
        db.logsErrors = YES;
        _isLoading = YES;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [notificationCenter postNotificationName:SOB_FIGUREDATASOURCE_STARTSLOADING object:self];
        });
        
        NSString *chapterQuery = _chapterId != 0 ? @" and outline.level1_id = ? " : @"";
         
        NSMutableArray *queryArguments = _chapterId != 0 ? [NSMutableArray arrayWithObject:[NSNumber numberWithInt:_chapterId] ] : [NSMutableArray array];
        // querySelectArguments will be put first in queryArguments, once final query is built.
        NSArray *querySelectArguments = [NSArray array];
        
        BOOL hasPurchased = _chapterId != 0 ? _fullVersionController.hasFullVersion || [_fullVersionController hasPurchasedChapterId:@(_chapterId)] : _fullVersionController.hasFullVersion;
        
        NSString *bookmarkQuery = @"";
        NSString *figureQuery = @"";
        if (_bookmarkList) {
            [_managedObjectContext lock];

            if ([_bookmarkList isKindOfClass:[FakeBookmarklist class]]) {
                FakeBookmarklist *fake = (FakeBookmarklist*) _bookmarkList;
                if (fake.type == FakeBookmarklistTypeBelow60Percent) {
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FigureProxy"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bestTrainingResult.percent_correct < 60"];
                    fetchRequest.propertiesToFetch = @[@"figure_id", @"bestTrainingResult.percent_correct"];
                    fetchRequest.resultType = NSDictionaryResultType;
                    NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];

                    if ([ret count] < 1) {
                        bookmarkQuery = @" and 1=2 ";
                    } else {
                        NSString *tmp = [@"" stringByPaddingToLength:[ret count]*2-1 withString:@"?," startingAtIndex:0];
                        bookmarkQuery = [NSString stringWithFormat:@" and figure.id IN (%@)", tmp];
                        for (NSDictionary *dict in ret) {
                            [queryArguments addObject:[dict objectForKey:@"figure_id"]];
                            //NSLog(@"adding figure id %@ - %@", [dict objectForKey:@"figure_id"], [dict objectForKey:@"maxPercent"]);
                            NSLog(@"adding figure id %@", dict);
                        }
                    }
                }
            } else {
                if ([_bookmarkList.bookmarks count] < 1) {
                    bookmarkQuery = @" and 1=2 ";
                } else {
                    NSString *tmp = [@"" stringByPaddingToLength:[_bookmarkList.bookmarks count]*2-1 withString:@"?," startingAtIndex:0];
                    bookmarkQuery = [NSString stringWithFormat:@" and figure.id IN (%@)", tmp];
                    NSLog(@"Adding all bookmarks to query - %lu", (unsigned long)[_bookmarkList.bookmarks count]);
                    for (Bookmark *bm in _bookmarkList.bookmarks) {
                        [queryArguments addObject:bm.figure_id];
                        NSLog(@"Adding bookmark: %ld", [bm.figure_id longValue]);
                    }
                }
            }
            [_managedObjectContext unlock];
        } else if (_training) {
            [_managedObjectContext lock];
            if ([_training.figures count] < 1) {
                bookmarkQuery = @" and 1=2 ";
            } else {
                NSString *tmp = [@"" stringByPaddingToLength:[_training.figures count]*2-1 withString:@"?," startingAtIndex:0];
                bookmarkQuery = [NSString stringWithFormat:@" and figure.id IN (%@)", tmp];
                for (Training_Figures *figure in _training.figures) {
                    [queryArguments addObject:figure.figure_id];
                }
            }
            [_managedObjectContext unlock];
        } else if (_figureId != -1) {
            figureQuery = @" and figure.id = ?";
            [queryArguments addObject:[NSNumber numberWithLong:_figureId]];
        }
        
        NSString *query = nil;
        NSString *langcolname = [DatabaseController Current].langcolname;
        NSString *select = [NSString stringWithFormat:@"select figure.id, figure.filename, outline.level2_id, figure.shortlabel_%@ shortlabel, figure.longlabel_%@, outline.level1_id longlabel,figure.available,figure.interactive,figure.label_count  ", langcolname, langcolname];
        
        NSArray<NSNumber *> *purchasedChapterIds = [_fullVersionController purchasedChapterIds];
        if (_chapterId == 0 && !hasPurchased) {
            if (purchasedChapterIds.count > 0) {
                NSString *purchasedChapterPlaceholders = [@"" stringByPaddingToLength:purchasedChapterIds.count*2-1 withString:@"?," startingAtIndex:0];
                select = [NSString stringWithFormat:@"%@,(figure.available or outline.level1_id IN (%@)) as haspurchased_or_available ", select, purchasedChapterPlaceholders];
                querySelectArguments = purchasedChapterIds;
            } else {
                select = [NSString stringWithFormat:@"%@,(figure.available) as haspurchased_or_available ", select];
            }
        }
        
        BOOL isSearch = NO;
        if (searchedText && ![searchedText isEqualToString:@""]) {
            isSearch = YES;
            NSString *searchString = nil;
            if (_searchWildCardMatch) {
                searchString = [NSString stringWithFormat:@"%%%@%%", searchedText];
            } else {
                searchString = searchedText;
            }
            [queryArguments insertObject:searchString
                                 atIndex:0];
            [queryArguments insertObject:searchString
                                 atIndex:0];
            [queryArguments insertObject:searchString
                                 atIndex:0];
            
            NSString *orderby = @"figure.available DESC, outline.sortorder, figure.sortorder";
            if (_chapterId == 0 && !hasPurchased) {
                orderby = @"haspurchased_or_available DESC, outline.sortorder, figure.sortorder";
            } else if (hasPurchased) {
                orderby = @"outline.sortorder, figure.sortorder";
            }
            query = [NSString stringWithFormat:@"%@, MIN(label.x), MIN(label.y), MAX(label.x), MAX(label.y) from figure inner join outline on figure.chapter_id = outline.chapter_id inner join label on label.figure_id = figure.id where (label.text_delat_normalized like ? OR label.text_enlat_normalized like ? OR label.text_enen_normalized LIKE ?) %@ %@ %@ group by figure.id order by %@  LIMIT 300", select, chapterQuery, bookmarkQuery, figureQuery, orderby];
            queryArguments = [[querySelectArguments arrayByAddingObjectsFromArray:queryArguments] mutableCopy];
            
        } else {
            NSString *orderby = @"figure.available DESC, figure.sortorder";
            if (_chapterId == 0 && !hasPurchased) {
                orderby = @"haspurchased_or_available DESC, outline.sortorder, figure.sortorder";
            } else if (hasPurchased) {
                orderby = @"figure.sortorder";
            }
            query = [NSString stringWithFormat:@"%@ from figure inner join outline on figure.chapter_id = outline.chapter_id where 1=1 %@ %@ %@ order by %@ LIMIT 300", select, chapterQuery, bookmarkQuery, figureQuery, orderby];
            queryArguments = [[querySelectArguments arrayByAddingObjectsFromArray:queryArguments] mutableCopy];
        }
        
        
        uint64_t startTime, stopTime1, stopTime2;
        startTime = mach_absolute_time();
        
        FMResultSet *result = [db executeQuery:query withArgumentsInArray:queryArguments];
        
        stopTime1 = mach_absolute_time();
        
        
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray *allfigures = [NSMutableArray array];
        SectionInfo *sectionInfo = nil;
        long lastSectionId = 0;
        int availableCount = 0;
        NSLog(@"selecting from %d with query %@", _chapterId, query);
        while ([result next]) {
            if (searchedText != _searchText) {
                NSLog(@"search text changed. aborting.");
                return;
            }
            FigureInfo *figure = [[FigureInfo alloc] initWithResultSet:result forSearch:isSearch];
            long currentSectionId = figure.level2id;
            //NSLog(@"last: %d / current: %d", lastSectionId, currentSectionId);
            if (lastSectionId == 0 || currentSectionId != lastSectionId) {
                lastSectionId = currentSectionId;
                sectionInfo = [[SectionInfo alloc] init];
                sectionInfo.sectionId = [NSNumber numberWithLong:currentSectionId];
                sectionInfo.chapterId = [NSNumber numberWithLong:figure.level1id];
                sectionInfo.images = [NSMutableArray array];
                sectionInfo.available = figure.available;
                [sections addObject:sectionInfo];
            }
            if (hasPurchased || figure.available || [purchasedChapterIds containsObject:@(figure.level1id)]) {
                availableCount++;
            }
            figure.section = sectionInfo;
            [allfigures addObject:figure];
            [sectionInfo.images addObject:figure];
        }
        stopTime2 = mach_absolute_time();
        logMachTime_withIdentifier_(stopTime1 - startTime, @"duration for query");
        logMachTime_withIdentifier_(stopTime2 - stopTime1, @"duration for walking through result set.");
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            long globalIndex = [self getCurrentSelectionGlobalIndex];
            _sections = sections;
            _allfigures = allfigures;
            _figureAvailableCount = availableCount;
            if (_currentSelectionIndex >= 0) {
                [self setCurrentSelection:[self figureAtGlobalIndex:_currentSelectionIndex]];
                _currentSelectionIndex = -1;
            } else if (_currentSelectionFigureId >= 0) {
                [self setCurrentSelectionFigureId:_currentSelectionFigureId];
            } else {
                if (_currentSelection) {
                    if (globalIndex >= 0 && [_allfigures count] <= globalIndex) {
                        [self setCurrentSelection:[self figureAtGlobalIndex:globalIndex]];
                    }
                }
            }
            if (searchedText != _searchText) {
                NSLog(@"search text changed. aborting.");
                return;
            }
            
            _isLoading = NO;
            
            [notificationCenter postNotificationName:SOB_FIGUREDATASOURCE_CHANGED
                                              object:self];
            if (_delegate) {
                [_delegate figureDatasourceDataChanged];
            }
            /*
            [self.gridView reloadData];
            if (_masterViewController) {
                _masterViewController.sections = _sections;
            }
             */

            if (finishedCallback) {
                finishedCallback();
            }
        });
    }];
    
}


- (void) setCurrentSelection: (FigureInfo *)selection {
    _currentSelection = selection;
}
- (void) setCurrentSelectionIndex: (int)currentSectionIndex {
    if (_allfigures || [_allfigures count] < 1) {
        _currentSelectionIndex = currentSectionIndex;
    } else {
        [self setCurrentSelection:[self figureAtGlobalIndex:currentSectionIndex]];
    }
}
- (void) setCurrentSelectionFigureId:(long)figureId {
    if (_allfigures) {
        for (FigureInfo *figure in _allfigures) {
            if (figure.idval == figureId) {
                [self setCurrentSelection:figure];
                break;
            }
        }
    } else {
        _currentSelectionFigureId = figureId;
    }
}

- (FigureInfo *) getCurrentSelection {
    if (!_currentSelection) {
        return [self figureAtGlobalIndex:0];
    }
    return _currentSelection;
}
- (long)getCurrentSelectionGlobalIndex {
    if (!_currentSelection) {
        return 0;
    }
    return [_allfigures indexOfObject:_currentSelection];
}
- (FigureInfo *) figureAtGlobalIndex: (long) index {
    if ([_allfigures count] <= index) {
        return nil;
    }
    return [_allfigures objectAtIndex:index];
}
- (long)figureCount {
    return [_allfigures count];
}

- (int)figureAvailableCount {
    return _figureAvailableCount;
}


- (void)removeFiguresOfSectionIdx:(int)sectionIdx fromBookmarkList:(Bookmarklist *)bookmarkList {
    int count = [self numberofItemsInSection:sectionIdx];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    [managedObjectContext lock];
    @try {
        
        //    NSMutableOrderedSet *adding = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet* toremove = [NSMutableOrderedSet orderedSetWithOrderedSet:bookmarkList.bookmarks];
        for (int i = 0 ; i < count ; i++) {
            FigureInfo *info = [self figureAtIndex:i inSection:sectionIdx];
            for (Bookmark *bookmark in toremove) {
                if ([bookmark.figure_id longValue] == info.idval) {
                    [toremove removeObject:bookmark];
                    NSLog(@"removed bookmark from list.");
                    break;
                }
            }
        }
        NSLog(@"removed bookmarks from list - before: %lu, now: %lu, count: %d", (unsigned long)[bookmarkList.bookmarks count], (unsigned long)[toremove count], count);
        
        bookmarkList.bookmarks = toremove;
        
        [appDelegate.managedObjectContext save:nil];
    }
    @finally {
        [managedObjectContext unlock];
    }

}

- (void)addFiguresOfSectionIdx:(int)sectionIdx intoBookmarkList:(Bookmarklist *)bookmarkList {
    int count = [self numberofItemsInSection:sectionIdx];
    [[DatabaseController Current] trackEventWithCategory:@"addbookmark" withAction:@"addfiguresofsection" withLabel:[NSString stringWithFormat:@"section %d", sectionIdx] withValue:[NSNumber numberWithInt:count]];
    AppDelegate *appDelegate = [AppDelegate shared];
    
    //    NSMutableOrderedSet *adding = [NSMutableOrderedSet orderedSet];
    NSMutableOrderedSet* adding = [NSMutableOrderedSet orderedSetWithOrderedSet:bookmarkList.bookmarks];
    
    for (int i = 0 ; i < count ; i++) {
        FigureInfo *info = [self figureAtIndex:i inSection:sectionIdx];
        
        
        // check if the bookmark is already in that bookmark list.
        BOOL isduplicate = NO;
        for (Bookmark *tmpbookmark in adding) {
            if ([tmpbookmark.figure_id longValue] == info.idval) {
                NSLog(@"Found duplicate to add to boomkark list.");
                isduplicate = YES;
                break;
            }
        }
        
        if (!isduplicate) {
            Bookmark *bookmark = (Bookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:appDelegate.managedObjectContext ];
            
            bookmark.figure_id = [NSNumber numberWithLong:info.idval];
            
            [adding addObject:bookmark];
        }
        //        [bookmarkList addBookmarksObject:bookmark];
        
    }
    //    [bookmarkList addBookmarks:adding];
    bookmarkList.bookmarks = adding;
    
    [appDelegate.managedObjectContext save:nil];
    //    [self.navigationController popToViewController:self animated:YES];
}


- (BOOL) addFigure:(FigureInfo *)figure toBookmarklist:(Bookmarklist *)bookmarkList {
    [[DatabaseController Current] trackEventWithCategory:@"addbookmark" withAction:@"addfigure" withLabel:[NSString stringWithFormat:@"figure %@", figure.filename] withValue:nil];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    [managedObjectContext lock];
    
    @try {
        
        NSMutableOrderedSet* adding = [NSMutableOrderedSet orderedSetWithOrderedSet:bookmarkList.bookmarks];
        
        for (Bookmark *tmp in adding) {
            if ([tmp.figure_id longValue] == figure.idval) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error while adding bookmark", nil) message:NSLocalizedString(@"This figure is already in the selected bookmark list.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        
        Bookmark *bookmark = (Bookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:managedObjectContext ];
        
        bookmark.figure_id = [NSNumber numberWithLong:figure.idval];
        
        [adding addObject:bookmark];
        bookmarkList.bookmarks = adding;
        
        [appDelegate.managedObjectContext save:nil];
        
        if (IS_PHONE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Added to Bookmarklist", nil) message:NSLocalizedString(@"Successfully added current figure to Bookmarklist", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        
        return YES;
    }
    @finally {
        [managedObjectContext unlock];
    }

}

- (void) showPaidVersionTeaser:(UIViewController *)parentViewController chapterId:(NSNumber *)chapterId {
    [[DatabaseController Current] trackView:@"OpenPremiumFigure"];
    [_fullVersionController askForVoucherOnBuyClick:parentViewController chapterId:chapterId];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_VIEW_APPSTORE) {
        if (buttonIndex == 1) {
            [[DatabaseController Current] trackEventWithCategory:@"OpenPremiumFigure" withAction:@"touched" withLabel:@"OK" withValue:nil];
            NSString *url = [NSString stringWithFormat:SOB_PAID_APPLINK];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            [[DatabaseController Current] trackEventWithCategory:@"OpenPremiumFigure" withAction:@"touched" withLabel:@"Cancel" withValue:nil];
        }
    }
}



@end




@implementation FigureInfo

- initWithResultSet:(FMResultSet*)rs forSearch:(BOOL)isSearch {
    self = [super init];
    if (self) {
        _idval = [rs intForColumnIndex:0];
        _filename = [rs stringForColumnIndex:1];
        _level2id = [rs intForColumnIndex:2];
        _shortlabel = [rs stringForColumnIndex:3];
        _longlabel = [rs stringForColumnIndex:4];
        _level1id = [rs intForColumnIndex:5];
        _available = [rs intForColumnIndex:6] == 1;
        _interactive = [rs intForColumnIndex:7] == 1;
        _labelCount = [rs longForColumnIndex:8];
        if (isSearch) {
            _min_x = [rs intForColumnIndex:9];
            _min_y = [rs intForColumnIndex:10];
            _max_x = [rs intForColumnIndex:11];
            _max_y = [rs intForColumnIndex:12];
        }
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLong:_idval] forKey:@"id"];
    [dict setObject:_filename forKey:@"filename"];
    return dict;
}

@end

@implementation SectionInfo

@end

