//
//  GridSizeChooserViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SOBNavigationViewController.h"

@interface GridSizeChooserViewController : UIViewController {
}


@property (weak, nonatomic) IBOutlet UISegmentedControl *gridSize;
@property SOBNavigationViewController *navViewController;

@end
