//
//  Bookmark.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/14/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmarklist;

@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSNumber * figure_id;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) Bookmarklist *bookmarklist;

@end
