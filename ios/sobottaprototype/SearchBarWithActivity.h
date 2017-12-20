//
//  SearchBarWithActivity.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBarWithActivity : UISearchBar
{
    UIActivityIndicatorView *activityIndicatorView;
    int startCount;
}

@property(retain) UIActivityIndicatorView *activityIndicatorView;
@property int startCount;

- (void)startActivity;  // increments startCount and shows activity indicator
- (void)finishActivity; // decrements startCount and hides activity indicator if 0

@end