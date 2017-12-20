//
//  DatabaseController.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 09.08.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "DatabaseController.h"
#import "AppDelegate.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <Crashlytics/Crashlytics.h>
#import "Repetition_FigureLabel+CoreDataClass.h"


@implementation Language

- initLanguage:(NSString*)label longLabel:(NSString*)longLabel structureLangLabel:(NSString*)structureLangLabel colname:(NSString*)colname {
    self = [super init];
    if (self) {
        _label = label;
        _longLabel = longLabel;
        _colname = colname;
        _structureLangLabel = structureLangLabel;
    }
    return self;
}


@end


@implementation DatabaseController

static DatabaseController *current;

+ (DatabaseController *)Current {
	if(!current){
		current = [[DatabaseController alloc] init];
	}
	
	return current;
}

- (id)init {
	self = [super init];
	if (self != nil) {
        _languages = [NSMutableArray array];
        [_languages addObject:[[Language alloc] initLanguage:@"DE-LAT" longLabel:@"Deutsch-Latein" structureLangLabel:@"Latein" colname:@"delat"]];
        [_languages addObject:[[Language alloc] initLanguage:@"EN-LAT" longLabel:@"English-Latin" structureLangLabel:@"Latin" colname:@"enlat"]];
        [_languages addObject:[[Language alloc] initLanguage:@"EN-EN" longLabel:@"English-English" structureLangLabel:@"English" colname:@"enen"]];
        self.langcolname = NSLocalizedString(@"enen", @"The default language column.");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *tmplang = [defaults stringForKey:PREFS_LANG];
        if (tmplang) {
            self.langcolname = tmplang;
        }

        _chapterMapping = nil;
		// Build the path to the database file
        /*
        databasePath = [[NSBundle mainBundle] pathForResource:@"sobottacontent" ofType:@"sqlite"];
		db = [[FMDatabase alloc] initWithPath:databasePath];
         */
        
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = app.managedObjectContext;
        _tracker = [[GAI sharedInstance] defaultTracker];

	}
	return self;
}

- (void) abortRunningTrainings {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Training"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"inprogress == %@", [NSNumber numberWithBool:YES]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Training *training in ret) {
        training.inprogress = [NSNumber numberWithBool:NO];
        if (training.end == nil && training.trainingType == TrainingTypeRepetition) {
            DDLogDebug(@"Training was in progress, but had no end date.");
            NSArray<Repetition_FigureLabel *> *lastscheduled = [Repetition_FigureLabel where:[NSPredicate predicateWithFormat:@"figure.last_training = %@", training] inContext:_managedObjectContext order:@{@"lastscheduled": @"DESC"} limit:@1];
            if (lastscheduled.count > 0) {
                training.end = lastscheduled[0].lastscheduled;
            }
            NSDate *start = training.laststart ? training.laststart : training.start;
            NSTimeInterval duration = [training.end timeIntervalSinceDate:start];
            if (training.duration) {
                duration += [training.duration doubleValue];
            }
            training.duration = @(duration);
        }
    }
    [_managedObjectContext save:&error];
}

- (Training *)getRunningTraining {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_managedObjectContext = app.managedObjectContext;
    [_managedObjectContext lock];
    
    //check if old training is available
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Training"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"inprogress == %@", [NSNumber numberWithBool:YES]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Training *training = nil;
    if (ret.count > 0) {
        training = [ret objectAtIndex:0];
    }
    [_managedObjectContext unlock];
    return training;
}

- (Training *)getLastRepetitionLearningTraining {
    _managedObjectContext = [AppDelegate shared].managedObjectContext;
    [_managedObjectContext lock];
    
    NSArray<Training *> *trainingList = [Training where:[NSPredicate predicateWithFormat:@"training_type == %@", @(TrainingTypeRepetition)] inContext:_managedObjectContext order:@{@"start": @"DESC"} limit:@1];
    
    
    [_managedObjectContext unlock];
    return trainingList.firstObject;
}

- (BOOL)hasRunningTraining {
    return [self getRunningTraining] != nil;
}

- (Language *)currentLanguage {
    for (Language *lang in _languages) {
        if ([lang.colname isEqualToString:self.langcolname]) {
            return lang;
        }
    }
    return nil;
}

- (void)setCurrentLanguage:(Language *)currentLanguage {
    _langcolname = currentLanguage.colname;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_langcolname forKey:PREFS_LANG];
    [defaults synchronize];
    
    _chapterMapping = nil;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:SOBLANGUAGECHANGED
                                      object:self];
}

- (NSArray *)languages {
    return _languages;
}

- (NSString *)dataPath {
    return _dataPath;
}


- (FMDatabaseQueue *) contentDatabaseQueue {
    if (!contentDatabaseQueue) {
        NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"all/sobottacontent_autogenerated" ofType:@"sqlite"];
        _dataPath = @"all";
        if (!databasePath) {
            databasePath = [[NSBundle mainBundle] pathForResource:@"free/sobottacontent_autogenerated" ofType:@"sqlite"];
            _dataPath = @"free";
        }
        contentDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    }
	return contentDatabaseQueue;
}

- (NSDictionary *) chapterMapping {
    if (_chapterMapping) {
        return _chapterMapping;
    }
    [[self contentDatabaseQueue] inDatabase:^(FMDatabase *db) {
        if (!_chapterMapping) {
            _chapterMapping = [NSMutableDictionary dictionary];
        }
        NSString *query = [NSString stringWithFormat:@"SELECT subchapter.level1_id, subchapter.chapter_id, subchapter.name_%@ name, mainchapter.name_%@ mainchapter_name, subchapter.name_enen name_enen, mainchapter.name_enen mainchapter_name_enen FROM outline subchapter INNER JOIN outline mainchapter ON mainchapter.chapter_id = subchapter.level1_id WHERE subchapter.level = 2 ORDER BY subchapter.sortorder", self.langcolname, self.langcolname];
        FMResultSet* rs = [db executeQuery:query];
        while ([rs next]) {
            NSDictionary *tmp = [rs resultDictionary];
            NSNumber *number = [tmp valueForKey:@"level1_id"];
            Section *chapter = [_chapterMapping objectForKey:number];
            if (!chapter) {
                chapter = [Section mainSectionWithname:[tmp valueForKey:@"mainchapter_name"] andEnen:[tmp valueForKey:@"mainchapter_name_enen"]];
                [_chapterMapping setObject:chapter forKey:number];
            }
            NSMutableDictionary* subsections = chapter.children;
            NSNumber *sectionId = [tmp valueForKey:@"chapter_id"];
            Section *section = [Section sectionFromDictionary:tmp];
            [subsections setObject:section forKey:sectionId];
            [chapter.sortedChildren addObject:section];
            
        }
    }];
    return _chapterMapping;
}

- (NSString *) chapterNameById:(int) chapterId {
    NSDictionary* mapping = [self chapterMapping];
    Section *section = [mapping objectForKey:[NSNumber numberWithInt:chapterId]];
    return section.name;
}

- (Section *) chapterById:(int) chapterId {
    NSDictionary* mapping = [self chapterMapping];
    Section *section = [mapping objectForKey:[NSNumber numberWithInt:chapterId]];
    return section;
}


- (void)trackView:(NSString *)viewName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:viewName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    CLS_LOG(@"trackView: %@", viewName);
}
- (void) trackEventWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build];
    [tracker send:event];
    CLS_LOG(@"trackEventWithCategory: %@ withAction: %@ withLabel: %@ withValue: %@", category, action, label, value);
}

- (void) trackPurchaseStatus:(NSString *)purchaseStatus {
    [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:2] value:purchaseStatus];
    CLS_LOG(@"trackPurchaseStatus: %@", purchaseStatus);
}
- (void) trackLang:(NSString *)lang {
    [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:1] value:lang];
}
- (void) trackBookmarklistCount:(NSUInteger) count {
    NSLog(@"trackBookmarklistCount: %ld", count);
    [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:3] value:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
}
- (void) trackNotesCount:(NSUInteger) count {
    NSLog(@"trackNotesCount: %ld", count);
    [[[GAI sharedInstance] defaultTracker] set:[GAIFields customDimensionForIndex:4] value:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
}

@end


@implementation Section


- (id) init {
    self = [super init];
    if (self) {
        self.children = [NSMutableDictionary dictionary];
        self.sortedChildren = [NSMutableArray array];
    }
    return self;
}

+ (Section *)mainSectionWithname:(NSString*)name andEnen:(NSString*)nameEnen {
    Section *s = [[Section alloc] init];
    s.name = name;
    s.nameEnen = nameEnen;
    return s;
}

+ (Section*) sectionFromDictionary:(NSDictionary *)dictionary {
    Section *s = [[Section alloc] init];
    NSString *name = [dictionary valueForKey:@"name"];
    s.name = name;
    NSString *nameEnen = [dictionary valueForKey:@"name_enen"];
    s.nameEnen = nameEnen;
    return s;
}


@end
