//
//  ImageGridCell.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/20/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KKGridView/KKGridViewCell.h>
#import "VerticalAlignedLabel.h"
#import "FigureDatasource.h"
#import "ImageGridCellImageView.h"
#import "ImageGridCellImageViewOverlay.h"
#import "FullVersionController.h"


#define FONT_SIZE 12
#define LABEL_HPADDING 5.f
#define LABEL_VPADDING LABEL_HPADDING
#define LABEL_HEIGHT FONT_SIZE * 4


@interface ImageGridCell : KKGridViewCell {
    FigureDatasource *_figureDatasource;
    FigureInfo *_figure;
    dispatch_queue_t _queue;
    __weak DatabaseController *_databaseController;
    NSMutableArray *_spots;
    FullVersionController *_fullVersionController;
}

@property (strong, nonatomic) ImageGridCellImageView *figureImageView;
@property (strong, nonatomic) ImageGridCellImageViewOverlay *overlay;
@property (strong, nonatomic) VerticalAlignedLabel *label;


- (void) showFigureInfo:(FigureInfo*) figure fromDatasource:(FigureDatasource *)figureDatasource inQueue:(dispatch_queue_t)queue;

@end
