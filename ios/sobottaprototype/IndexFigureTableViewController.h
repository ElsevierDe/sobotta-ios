//
//  IndexFigureTableViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/8/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DatabaseController.h"
#import "FigureDatasource.h"



@interface IndexFigureTableViewController : UITableViewController {
    FullVersionController *_fullVersionController;
    DatabaseController *_databaseController;
    
    NSArray * _chapterGroups;
}

@end


@interface ChapterGroup : NSObject {
    
}

@property (nonatomic) int idval;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) int count;
@property (nonatomic, strong) NSArray *figureInfos;

@end

@interface IndexFigureInfo : NSObject {
}

@property (nonatomic, strong) NSString *label;
@property (nonatomic) long idval;
@property (nonatomic) BOOL available;

@end


