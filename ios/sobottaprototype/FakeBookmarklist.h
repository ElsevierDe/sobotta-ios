//
//  FakeBookmarklist.h
//  sobottaprototype
//
//  Created by Herbert Poul on 12/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Bookmarklist.h"

typedef enum {
    FakeBookmarklistTypeBelow60Percent
} FakeBookmarklistType;

/**
 * fake bookmark lists (e.g. >60%)
 */
@interface FakeBookmarklist : Bookmarklist {
    FakeBookmarklistType _type;
}

@property (nonatomic, assign) FakeBookmarklistType type;

@end
