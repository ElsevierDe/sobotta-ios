//
//  InAppMessagePanel.h
//  sobottaprototype
//
//  Created by Herbert Poul on 28/07/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import "UAModalPanel.h"

#import "SOBButtonImage.h"

@class InAppMessage;

@interface InAppMessagePanel : UAModalPanel {
    UIView *_parentView;
}

- (id)initWithView:(UIView *)parentView msg:(InAppMessage*)msg;

@property (strong, nonatomic) IBOutlet UIView *subView;

@property (weak, nonatomic) IBOutlet UILabel *messageTitle;
@property (weak, nonatomic) IBOutlet UILabel *messageBody;
@property (weak, nonatomic) IBOutlet SOBButtonImage *button1;
@property (weak, nonatomic) IBOutlet SOBButtonImage *button2;

@end
