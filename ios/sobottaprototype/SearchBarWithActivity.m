//
//  SearchBarWithActivity.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/13/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SearchBarWithActivity.h"

@implementation SearchBarWithActivity

@synthesize activityIndicatorView;

- (void)layoutSubviews {
    UITextField *searchField = nil;
    
    for(UIView* view in self.subviews){
        if([view isKindOfClass:[UITextField class]]){
            searchField= (UITextField *)view;
            break;
        }
    }
    
    if(searchField) {
        if (!self.activityIndicatorView) {
            UIActivityIndicatorView *taiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            taiv.center = CGPointMake(searchField.leftView.bounds.origin.x + searchField.leftView.bounds.size.width/2,
                                      searchField.leftView.bounds.origin.y + searchField.leftView.bounds.size.height/2);
            taiv.hidesWhenStopped = YES;
            taiv.backgroundColor = [UIColor whiteColor];
            self.activityIndicatorView = taiv;
            startCount = 0;
            
            [searchField.leftView addSubview:self.activityIndicatorView];
        }
    }
    
    [super layoutSubviews];
}

- (void)startActivity  {
    self.startCount = startCount + 1;
}

- (void)finishActivity {
    self.startCount = startCount - 1;
}

- (int)startCount {
    return startCount;
}

- (void)setStartCount:(int)startCount_ {
    startCount = startCount_;
    if (startCount > 0)
        [self.activityIndicatorView startAnimating];
    else {
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)dealloc {
    if (activityIndicatorView) {
        activityIndicatorView = nil;
    }
}

@end