//
//  Bookmarklist.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/27/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmark, Training;

@interface Bookmarklist : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * sectionalias;
@property (nonatomic, retain) NSOrderedSet *bookmarks;
@property (nonatomic, retain) Training *trainings;
@end

@interface Bookmarklist (CoreDataGeneratedAccessors)

- (void)insertObject:(Bookmark *)value inBookmarksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBookmarksAtIndex:(NSUInteger)idx;
- (void)insertBookmarks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBookmarksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBookmarksAtIndex:(NSUInteger)idx withObject:(Bookmark *)value;
- (void)replaceBookmarksAtIndexes:(NSIndexSet *)indexes withBookmarks:(NSArray *)values;
- (void)addBookmarksObject:(Bookmark *)value;
- (void)removeBookmarksObject:(Bookmark *)value;
- (void)addBookmarks:(NSOrderedSet *)values;
- (void)removeBookmarks:(NSOrderedSet *)values;
@end
