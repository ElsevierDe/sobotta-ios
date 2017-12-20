//
//  Training_Figure_Labels.h
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 24.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Training_Figures;

@interface Training_Figure_Labels : NSManagedObject

@property (nonatomic, retain) NSNumber * label_id;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) Training_Figures *figure;

@end
