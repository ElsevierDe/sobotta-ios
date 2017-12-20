//
//  InAppMessagePanel.m
//  sobottaprototype
//
//  Created by Herbert Poul on 28/07/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import "InAppMessagePanel.h"
#import "InAppMessageController.h"

@implementation InAppMessagePanel

- (id)initWithView:(UIView *)parentView msg:(InAppMessage *)msg {
    self = [super initWithFrame:parentView.bounds];
    if (self) {
        _parentView = parentView;
        self.contentColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [self recalculatePaddings];
        
        
//        _messageTitle.text = msg.title;
//        _messageBody.text = msg.message;
        
        [[NSBundle mainBundle] loadNibNamed:@"InAppMessageView" owner:self options:nil];
        [self.contentView addSubview:_subView];

        
        [_button1 removeFromSuperview];
        SOBButtonImage *sobButton1 = [[SOBButtonImage alloc] initButtonOfType:BARBUTTON withImage:nil andText:msg.button1Label];
//        sobButton1.frame = CGRectMake((300. / 2) - (sobButton1.frame.size.width / 2), _button1.frame.origin.y, sobButton1.frame.size.width, sobButton1.frame.size.height);
        sobButton1.frame = CGRectMake((100.) - (sobButton1.frame.size.width / 2), _button1.frame.origin.y, sobButton1.frame.size.width, sobButton1.frame.size.height);
//        [sobButton addTarget:self action:@selector(upgradeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:sobButton1];
        
        SOBButtonImage *sobButton2 = [[SOBButtonImage alloc] initButtonOfType:BARBUTTON withImage:nil andText:msg.button2Label];
//        sobButton2.frame = CGRectMake((300. / 2) - (sobButton2.frame.size.width / 2), _button2.frame.origin.y, sobButton2.frame.size.width, sobButton2.frame.size.height);
        sobButton2.frame = CGRectMake((200.) - (sobButton2.frame.size.width / 2), _button2.frame.origin.y, sobButton2.frame.size.width, sobButton2.frame.size.height);
        [self.contentView addSubview:sobButton2];
    }
    return self;
}


- (void) recalculatePaddings {
    CGRect frame = _parentView.bounds;
    NSLog(@"Recalculate paddings. %@", NSStringFromCGRect(frame));
    CGSize mySize = CGSizeMake(300, 400);
    CGFloat h = (frame.size.height - mySize.height) / 2;
    CGFloat w = (frame.size.width - mySize.width) / 2;
    CGFloat paddingDefault = 2;
    self.margin = UIEdgeInsetsMake(h, w, h, w);
    self.padding = UIEdgeInsetsMake(paddingDefault, paddingDefault, paddingDefault, paddingDefault);
    
}

- (void)layoutSubviews {
    [self recalculatePaddings];
	[super layoutSubviews];
    
	[_subView setFrame:self.contentView.bounds];
}
@end
