//
//  Note.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 24.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * label_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * updated;

@end
