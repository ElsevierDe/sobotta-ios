//
//  FakeBookmarklist.m
//  sobottaprototype
//
//  Created by Herbert Poul on 12/4/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "FakeBookmarklist.h"

@implementation FakeBookmarklist

- (id)init {
    return self;
}

- (void)setType:(FakeBookmarklistType)type {
    _type = type;
}

- (NSString *)name {
    return NSLocalizedString(@"Trained below 60%", nil);
}

- (NSOrderedSet *)bookmarks {
    return nil;
}

- (NSNumber *)sectionalias {
    return nil;
}

- (FakeBookmarklistType)type {
    return _type;
}


@end
