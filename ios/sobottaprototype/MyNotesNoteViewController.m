//
//  MyNotesNoteViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/24/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "MyNotesNoteViewController.h"
#import "AppDelegate.h"

#import "FigureDatasource.h"
#import "ImageViewController.h"

@interface MyNotesNoteViewController ()

@end

@implementation MyNotesNoteViewController


- (void) replaceOpenFigureButton {
    SOBButtonImage *newOpenButton = [[SOBButtonImage alloc] initContentButtonWithImage:nil andText:NSLocalizedString(@"Open Figure", nil)];
    NSLog(@"newOpenButton width: %f", newOpenButton.frame.size.width);
    newOpenButton.frame = CGRectMake(self.view.bounds.size.width - newOpenButton.frame.size.width - 10., _openFigureButton.frame.origin.y, newOpenButton.frame.size.width, newOpenButton.frame.size.height);
    newOpenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [newOpenButton addTarget:self action:@selector(openFigureClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:newOpenButton aboveSubview:_openFigureButton];
    [_openFigureButton removeFromSuperview];
    _openFigureButton = newOpenButton;
    _openFigureButton.sobLabel.text = NSLocalizedString(@"Open Figure", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self replaceOpenFigureButton];
    _imageLabelParent.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"mynotes-header"] resizableImageWithCapInsets:UIEdgeInsetsMake(6., 6., 6., 6.)]];
    
    
    
    self.imageLabel.text = _figureLabel;
    
    MyNotesBackgroundLinesView *contentView = [[MyNotesBackgroundLinesView alloc] initWithFrame:CGRectMake(0, 0, _noteContentScrollView.bounds.size.width, 100)];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    
    
    // first find all labels for the figure..
    DatabaseController *db = [DatabaseController Current];
    FMDatabaseQueue *queue = [db contentDatabaseQueue];
    NSString *tmp = [@"" stringByPaddingToLength:[_labelids count]*2-1 withString:@"?," startingAtIndex:0];
    NSMutableArray *figurelabelIds = [NSMutableArray array];
    NSString *sqlwhere = [NSString stringWithFormat:@"SELECT l.id, l.text_%@ FROM label l WHERE l.figure_id = ? AND l.id IN (%@)", db.langcolname, tmp];
    NSLog(@"sql: %@", sqlwhere);
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:_figureId];
    [arguments addObjectsFromArray:_labelids];
    NSMutableDictionary *labelText = [NSMutableDictionary dictionary];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sqlwhere withArgumentsInArray:arguments];
        while([rs next]) {
            NSNumber *labelId = [NSNumber numberWithInt:[rs intForColumnIndex:0]];
            [figurelabelIds addObject:labelId];
            [labelText setObject:[rs stringForColumnIndex:1] forKey:labelId];
        }
    }];
    
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.predicate = [NSPredicate predicateWithFormat:@"label_id IN %@", [NSArray arrayWithArray:figurelabelIds]];
    [request setEntity:entity];
//    [request setResultType:NSDictionaryResultType];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [_managedObjectContext executeFetchRequest:request error:&error];
    
    for (Note *note in objects) {
        NSString *lbl = [labelText objectForKey:note.label_id];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectNull];
        label.font = contentView.font;
        NSString* color = note.color;
        UIColor *usecolor = [UIColor redColor];
        if([color isEqualToString:@"red"])
            usecolor = [UIColor redColor];
        else if([color isEqualToString:@"green"])
            usecolor = [UIColor greenColor];
        else if([color isEqualToString:@"blue"])
            usecolor = [UIColor blueColor];
        else if([color isEqualToString:@"pink"])
            usecolor = [UIColor colorWithRed:1 green:192/255. blue:203/255. alpha:1];
        else if([color isEqualToString:@"violet"])
            usecolor = [UIColor colorWithRed:143/255. green:0 blue:1 alpha:1];
        label.textColor = usecolor;
        label.backgroundColor = [UIColor clearColor];
        label.text = lbl;
        label.numberOfLines = 0;
        [contentView addSubview:label];
        
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectNull];
        noteLabel.font = contentView.font;
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.text = note.text;
        noteLabel.numberOfLines = 0;
        [contentView addSubview:noteLabel];
        
        UILabel *emptyline = [[UILabel alloc] initWithFrame:CGRectNull];
        emptyline.text = @"  ";
        emptyline.numberOfLines = 0;
        emptyline.backgroundColor = [UIColor clearColor];
        [contentView addSubview:emptyline];
    }

    /*
    double currentHeight = 0;
    for (int i = 0 ; i < 100 ; i++) {
        UILabel *lorem = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 5)];
        lorem.font = contentView.font;
        lorem.backgroundColor = [UIColor clearColor];
        lorem.text = [NSString stringWithFormat:@"Lorem Ipsum %d", i];
        if (i == 3) {
            lorem.text = [NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse egestas consectetur augue in fringilla. Donec pulvinar, arcu quis imperdiet bibendum, lectus turpis dapibus sem, at vulputate velit erat sagittis sem. Sed laoreet velit vitae lectus blandit aliquam. Duis quis eros vel augue auctor commodo. Phasellus at libero vel sem auctor pellentesque vel et dui. Integer ultrices quam facilisis tellus varius vel lobortis nisi ultrices. Donec nec eros quis ipsum volutpat fringilla. Curabitur iaculis pharetra nibh, et vehicula ligula pellentesque non. Ut sed porttitor nunc."];
            lorem.lineBreakMode = NSLineBreakByWordWrapping;
            lorem.numberOfLines = 0;
        }
//        [lorem sizeToFit];
//        lorem.frame = CGRectMake(lorem.frame.origin.x, lorem.frame.origin.y, contentView.frame.size.width, lorem.frame.size.height);
//        lorem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        currentHeight += lorem.frame.size.height;
        [contentView addSubview:lorem];
    }
     */
    
    
    [contentView sizeToFit];
    contentView.backgroundColor = [UIColor whiteColor];
//    _noteContentScrollView.backgroundColor = [UIColor blueColor];
    contentView.frame = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, 20.);
//    NSLog(@"content size: %f -- height: %f", contentView.frame.size.height, currentHeight);
    _noteContentView = contentView;
    [_noteContentScrollView addSubview:contentView];
    _noteContentScrollView.contentSize = contentView.frame.size;
}

- (void)viewDidLayoutSubviews {
    CGRect frame = _noteContentView.frame;
    _noteContentView.frame = CGRectMake(frame.origin.x, frame.origin.y, _noteContentScrollView.frame.size.width, frame.size.height);
    
    float currentHeight = 0;
    float margin = 5.;
    int i = 0;
    for (UILabel *subview in _noteContentView.subviews) {
        CGSize size = [subview.text sizeWithFont:subview.font constrainedToSize:CGSizeMake(_noteContentView.frame.size.width - 2*margin, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        if (i == 3) {
            NSLog(@"width: %f // size.height: %f (size.width: %f)", _noteContentView.frame.size.width, size.height, size.width);
        }
        i++;
        subview.frame = CGRectMake(margin, currentHeight, _noteContentView.frame.size.width-2*margin, size.height);
//        int step = currentHeight / leading;
//        currentHeight = (step+1) * leading;
//        [subview sizeToFit];
//        subview.frame = CGRectMake(0, currentHeight, _noteContentView.frame.size.width, subview.frame.size.height);
        currentHeight += size.height;
    }
    float scrollviewheight = _noteContentScrollView.frame.size.height;
    if (currentHeight < scrollviewheight) {
        currentHeight = scrollviewheight;
    }
    _noteContentView.frame = CGRectMake(frame.origin.x, frame.origin.y, _noteContentScrollView.frame.size.width, currentHeight);
    _noteContentScrollView.contentSize = _noteContentView.frame.size;
    
    
    
    
    UIImage *bgimage = [[UIImage imageNamed:@"mynotes-header"] resizableImageWithCapInsets:UIEdgeInsetsMake(6., 6., 6., 6.)];
    // redraw the image to fit |yourView|'s size
    UIGraphicsBeginImageContextWithOptions(_imageLabelParent.frame.size, NO, 0.f);
    [bgimage drawInRect:CGRectMake(0.f, 0.f, _imageLabelParent.frame.size.width, _imageLabelParent.frame.size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_imageLabelParent setBackgroundColor:[UIColor colorWithPatternImage:resultImage]];
    
    [_noteContentView setNeedsDisplay];

}
- (IBAction)openFigureClicked:(id)sender {
    FigureDatasource *figureDatasource = [FigureDatasource defaultDatasource];
    [figureDatasource loadForFigureId:[_figureId longValue]];
    
    ImageViewController *ivc = (ImageViewController *)[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    [ivc setFigure:figureDatasource];
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageLabel:nil];
    [self setNoteContentScrollView:nil];
    [self setImageLabelParent:nil];
    [self setOpenFigureButton:nil];
    [super viewDidUnload];
}
@end
