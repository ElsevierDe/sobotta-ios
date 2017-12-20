//
//  DatabaseController.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Training.h"


#define SOBLANGUAGECHANGED @"com.elsevier.apps.sobotta.languagechanged"
//#define SOBFIGURESLOADED @"com.elsevier.apps.sobotta.figuresloaded"
#define PREFS_LANG @"lang"


@class Section;

@interface Language : NSObject {
}

- initLanguage:(NSString*)label longLabel:(NSString*)longLabel structureLangLabel:(NSString*)structureLangLabel colname:(NSString*)colname;

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *longLabel;
@property (strong, nonatomic) NSString *colname;
@property (strong, nonatomic) NSString *structureLangLabel;

@end

@interface DatabaseController : NSObject<UIAlertViewDelegate> {
	@private
	NSString *_databasePath;
	//FMDatabase *db;
    
    FMDatabaseQueue *contentDatabaseQueue;
    NSManagedObjectContext *_managedObjectContext;
    
    NSMutableDictionary *_chapterMapping;
    NSMutableArray *_languages;
    NSString *_dataPath;
    id<GAITracker> _tracker;
}

@property (strong, nonatomic) NSString * langcolname;

+ (DatabaseController*)Current;

- (FMDatabaseQueue *) contentDatabaseQueue;
- (NSDictionary *) chapterMapping;
- (NSString *) chapterNameById:(int) chapterId;
- (Section *) chapterById:(int) chapterId;
- (Language *) currentLanguage;
- (void) setCurrentLanguage: (Language *)currentLanguage;
- (NSArray *) languages;
- (NSString *)dataPath;

- (BOOL) hasRunningTraining;
- (Training *)getRunningTraining;
- (Training *)getLastRepetitionLearningTraining;
- (void) abortRunningTrainings;


- (void) trackView:(NSString*)viewName;
- (void) trackEventWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value;
- (void) trackPurchaseStatus:(NSString*)purchaseStatus;
- (void) trackLang:(NSString *)lang;
- (void) trackBookmarklistCount:(NSUInteger) count;
- (void) trackNotesCount:(NSUInteger) count;

@end


@interface Section : NSObject {
    
}

+ (Section *)mainSectionWithname:(NSString*)name andEnen:(NSString*)nameEnen;
+ (Section *)sectionFromDictionary:(NSDictionary *)dictionary;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *nameEnen;
@property (strong, nonatomic) NSMutableDictionary *children;
@property (strong, nonatomic) NSMutableArray *sortedChildren;

@end
