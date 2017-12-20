//
//  ImageGridCell.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/20/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "ImageGridCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Theme.h"

@implementation ImageGridCell



- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])) {
        _fullVersionController = [FullVersionController instance];
        _databaseController = [DatabaseController Current];
    //if ((self = [super initWithFrame:frame])) {
        //self.reuseIdentifier = reuseIdentifier;
        self.imageView.hidden = YES;
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:FONT_SIZE];

        float imageHeight = self.frame.size.height-LABEL_HEIGHT-LABEL_VPADDING;
        float imageWidth = imageHeight;
        float hspacing = (self.frame.size.width - imageWidth) / 2.f;
        
        _label = [[VerticalAlignedLabel alloc] initWithFrame:CGRectMake(hspacing, self.frame.size.height-LABEL_HEIGHT, self.frame.size.width - 2*hspacing, LABEL_HEIGHT)];
        _label.verticalAlignment = VerticalAlignmentTop;
        _label.text = @"Testing";
        //_label.backgroundColor = [UIColor lightGrayColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.font = font;
        _label.numberOfLines = 2;

        _label.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        _label.baselineAdjustment = UIBaselineAdjustmentNone;
        //_label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        //_label.backgroundColor = [UIColor greenColor];
        
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _label.contentMode = UIViewContentModeBottom;
        
        
        _figureImageView = [[ImageGridCellImageView alloc] initWithFrame:CGRectMake(hspacing, 0.f, imageWidth, imageHeight)];
        //_figureImageView.image = [UIImage imageNamed:@"500_chp001_032.png"];
        _figureImageView.contentMode = UIViewContentModeScaleAspectFit;

        _figureImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _figureImageView.backgroundColor = [UIColor whiteColor];
        
        _overlay = [[ImageGridCellImageViewOverlay alloc] initWithFrame:_figureImageView.frame];
        _overlay.autoresizingMask = _figureImageView.autoresizingMask;

        if (YES) {
            /*
            // use shadow
            _figureImageView.layer.masksToBounds = NO;
            _figureImageView.layer.cornerRadius = 3;
            _figureImageView.layer.shadowRadius = 3;
            _figureImageView.layer.shadowOffset = CGSizeMake(0, 0);
            _figureImageView.layer.shadowOpacity = 1;
            _figureImageView.layer.shouldRasterize = YES;
            _figureImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_figureImageView.bounds].CGPath;
             */
            _figureImageView.layer.cornerRadius = [[SOThemeManager sharedTheme ] cellBorderRadius];

        UIColor* borderColor = [[SOThemeManager sharedTheme] cellBorderColor];
        CGColorRef cgcolor = borderColor.CGColor;
        _figureImageView.layer.borderColor = cgcolor;
        _figureImageView.layer.borderWidth = 1.f;
        
        } else {
            // use a simple border ..
            _figureImageView.layer.borderColor = [UIColor grayColor].CGColor;
            _figureImageView.layer.borderWidth = 2.f;
        }
        
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_figureImageView];
        [self.contentView addSubview:_overlay];
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _figureImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_figureImageView.bounds].CGPath;
}

- (void) showFigureInfo:(FigureInfo*) figure fromDatasource:(FigureDatasource *)figureDatasource inQueue:(dispatch_queue_t)queue {
    _figure = figure;
    _figureDatasource = figureDatasource;
    _queue = queue;
    _spots = nil;
    _overlay.spots = nil;
    
    
    bool available = [_fullVersionController allowShowFigure:_figure];
    self.contentView.alpha = available ? 1 : 0.5;
    self.label.text = [NSString stringWithFormat:@"%@ %@", figure.shortlabel, figure.longlabel];
    self.figureImageView.image = nil;
    NSString *filename = figure.filename;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSString *imagename = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg" inDirectory:[NSString stringWithFormat:@"%@/figures/thumbs",_databaseController.dataPath]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagename];
        dispatch_async(dispatch_get_main_queue(), ^{
            //            if (figure.max_x) {
            //                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(100, 100, 200, 200));
            //                // or use the UIImage wherever you like
            //                [cell.figureImageView setImage:[UIImage imageWithCGImage:imageRef]];
            //                CGImageRelease(imageRef);
            //            } else {
            self.figureImageView.image = image;
            
            //            }
        });
    });
    NSString *searchText = _figureDatasource.searchText;
    int figureId = _figure.idval;
    if (searchText) {
        dispatch_async(_queue, ^{
            if (![searchText isEqualToString:_figureDatasource.searchText] || figureId != _figure.idval) {
                NSLog(@"Another search is in progress.");
                return;
            }
            _spots = [NSMutableArray array];
            NSString *query = [NSString stringWithFormat:@"SELECT s.x_thumb, s.y_thumb FROM label l INNER JOIN spot s ON s.label_id = l.id WHERE l.figure_id = ? AND l.text_%@ LIKE ? LIMIT 10", _databaseController.langcolname ];
//            NSLog(@"Running query %@", query);
            NSString *tmpSearchText = [NSString stringWithFormat:@"%%%@%%", searchText];
            FMDatabaseQueue *fmqueue = [_databaseController contentDatabaseQueue];
            
            
            CGFloat width = _figureImageView.image.size.width;
            CGFloat height = _figureImageView.image.size.height;
                        
            
            [fmqueue inDatabase:^(FMDatabase *db) {
                
                
                
                
                
                FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[[NSNumber numberWithInt:figureId], tmpSearchText]];
                while ([rs next]) {
                    [_spots addObject:[NSValue valueWithCGPoint:CGPointMake([rs doubleForColumnIndex:0], [rs doubleForColumnIndex:1])]];


                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![searchText isEqualToString:_figureDatasource.searchText] || figureId != _figure.idval) {
                        NSLog(@"Another search is in progress.");
                        return;
                    }

                    _overlay.spots = _spots;
                    return;
                    // create a new bitmap image context
                    //
                    NSLog(@"BEGIN IMAGE CONTEXT >>>");
                    UIGraphicsBeginImageContext(CGSizeMake(width, height));
                    

                    // get context
                    //
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    if (!context) {
                        UIGraphicsBeginImageContext(CGSizeMake(width, height));
                        context = UIGraphicsGetCurrentContext();
                        if (!context) {
                            NSLog(@"current context is null?!");
                            return;
                        }
                    }
                    [_figureImageView.image drawAtPoint:CGPointZero];
                    
                    // push context to make it current
                    // (need to do this manually because we are not drawing in a UIView)
                    //
//                    UIGraphicsPushContext(context);
                    
                    // drawing code comes here- look at CGContext reference
                    // for available operations
                    //
                    // this example draws the inputImage into the context
                    //
                    
                    // Drawing lines with a white stroke color
                    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);
                    // Draw them with a 2.0 stroke width so they are a bit more visible.
                    CGContextSetLineWidth(context, 5.0);
                    

                    
                    for (NSValue * val in _spots) {
                        CGPoint p = val.CGPointValue;
                        //                    CGContextMoveToPoint(context, 10.0, 30.0);
                        //                    CGContextAddLineToPoint(context, 310.0, 30.0);
                        float x= p.x/2;
                        float y = p.y/2;
                        CGContextMoveToPoint(context, x, y);
                        CGContextAddArc(context, p.x / 2, p.y / 2, 5, 0, 2*M_PI, 1);
                        
                        
//                        NSLog(@"drawing image.");
                    }
                    CGContextStrokePath(context);
                    
                    
                    // pop context
                    //
//                    UIGraphicsPopContext();
                    
                    // get a UIImage from the image context- enjoy!!!
                    //
                    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
                    
                    // clean up drawing environment
                    //
                    UIGraphicsEndImageContext();
                    NSLog(@"END IMAGE CONTEXT <<<<");

                    

                    
                    
                    _figureImageView.image = outputImage;
                });
            }];
            
            
            
            
            
            

        });
    }
}

- (void)setPressedState:(BOOL)pressedState {
    bool available = [_fullVersionController allowShowFigure:_figure];
    if (pressedState) {
        if (available) {
            self.contentView.alpha = 0.5;
        } else {
            self.contentView.alpha = 1;
        }
        //self.contentView.layer.borderColor = [UIColor colorWithRed:137/255. green:138/255. blue:140/255. alpha:1].CGColor;
        //self.contentView.layer.borderWidth = 1;
    } else {
        //self.contentView.layer.borderColor = [UIColor colorWithRed:137/255. green:138/255. blue:140/255. alpha:1];
        //self.contentView.layer.borderWidth = 0;
        if (available) {
            self.contentView.alpha = 1;
        } else {
            self.contentView.alpha = 0.5;
        }
    }
    [self setNeedsLayout];
}


@end
