//
//  CaptionViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 12/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptionViewController : UIViewController<UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet UIWebView *captionWebView;

@property (nonatomic, assign) NSString* captionHtml;

@end
