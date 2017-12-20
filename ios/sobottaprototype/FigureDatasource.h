//
//  FigureDatasource.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/29/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseController.h"
#import "Bookmarklist.h"
#import "Training.h"
#import "Training_Figures.h"
#import "Training_Figure_Labels.h"
#import "Note.h"
#import <mach/mach_time.h>

@class FullVersionController;

#define SOB_FIGUREDATASOURCE_CHANGED @"com.elsevier.apps.sobotta.figuresloaded"
#define SOB_FIGUREDATASOURCE_STARTSLOADING @"com.elsevier.apps.sobotta.figuresstartloading"


#define ALERT_VIEW_APPSTORE 1




typedef enum {
    TrainingNameTypeSearch = 1,
    TrainingNameTypeChapter = 2,
    TrainingNameTypeBookmarks = 3,
    TrainingNameTypeSingleFigure = 4,
} TrainingNameType;


@interface SectionInfo : NSObject

@property (strong, nonatomic) NSNumber * chapterId;
@property (strong, nonatomic) NSNumber * sectionId;
@property (strong, nonatomic) NSMutableArray *images;
@property (nonatomic) BOOL available;

@end

@interface FigureInfo : NSObject

- initWithResultSet:(FMResultSet*)rs forSearch:(BOOL)isSearch;
- (NSDictionary *)dictionary;

@property (nonatomic) long idval;
@property (strong, nonatomic) NSString *filename;
@property (nonatomic) long level1id;
@property (nonatomic) long level2id;
@property (strong, nonatomic) NSString *shortlabel;
@property (strong, nonatomic) NSString *longlabel;
@property (nonatomic) BOOL available;
@property (nonatomic) BOOL interactive;
@property (nonatomic) long labelCount;

@property (nonatomic) int max_x;
@property (nonatomic) int max_y;
@property (nonatomic) int min_x;
@property (nonatomic) int min_y;

@property (weak, nonatomic) SectionInfo *section;

@end


@protocol FigureDatasourceDelegate

- (void) figureDatasourceDataChanged;

@end


@interface FigureDatasource : NSObject<UIAlertViewDelegate> {
    NSArray *_sections;
    int _chapterId;
    Bookmarklist *_bookmarkList;
    Training *_training;
    long _figureId;
    FullVersionController *_fullVersionController;
    
    
    FigureInfo *_currentSelection;
    int _currentSelectionIndex;
    int _figureAvailableCount;
    long _currentSelectionFigureId;
    NSManagedObjectContext *_managedObjectContext;
}


+ (FigureDatasource *) defaultDatasource;

- (long) sectionCount;
- (int) numberofItemsInSection:(int) section;
- (SectionInfo *) sectionAtIndex:(NSUInteger) section;
- (NSString *) sectionTitleAtIndex:(int)section;
- (FigureInfo *) figureAtIndex:(int)index inSection:(int) section;
- (FigureInfo *) figureAtGlobalIndex: (long) index;
- (long) figureCount;

- (NSString*) trainingName;
- (TrainingNameType) trainingNameType;
- (NSString*) trainingNameLocalized;
+ (NSString*) trainingNameLocalizedForTraining:(Training *)training;


- (void) loadForChapterId: (int) chapterId;
- (void) loadForBookmarklist: (Bookmarklist *)bookmarkList;
- (void) loadForTraining:(Training *)training finished:(void(^_Nullable)())finishedCallback;
- (void) loadForFigureId: (long) figureId;
- (void) loadForGlobalSearchText:(NSString *)searchText;


- (void) reloadData;

- (void) setCurrentSelection: (FigureInfo *)figure;

- (FigureInfo *) getCurrentSelection;
- (long) getCurrentSelectionGlobalIndex;
- (void) setCurrentSelectionIndex: (int)currentSectionIndex;
- (void) setCurrentSelectionFigureId: (long)figureId;

- (void)removeFiguresOfSectionIdx:(int)sectionIdx fromBookmarkList:(Bookmarklist *)bookmarkList;
- (void)addFiguresOfSectionIdx:(int)sectionIdx intoBookmarkList:(Bookmarklist *)bookmarkList;
- (BOOL) addFigure:(FigureInfo *)figureInfo toBookmarklist:(Bookmarklist *)bookmarkList;

- (void) showPaidVersionTeaser:(UIViewController *)parentViewController chapterId:(NSNumber *)chapterId;


@property (strong, nonatomic) NSString *searchText;
@property (nonatomic) BOOL searchWildCardMatch;
@property (weak, nonatomic) id<FigureDatasourceDelegate> delegate;
@property (readonly) int chapterId;
@property (readonly) NSArray* sections;
@property (readonly) NSArray* allfigures;
@property (readonly) int figureAvailableCount;
@property (readonly) Bookmarklist * bookmarkList;
@property (readonly) BOOL isLoading;
@property (readonly) BOOL cheatMode;


@end


