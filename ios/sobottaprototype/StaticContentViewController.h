//
//  StaticContentViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 10/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticContentViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSString *staticContentName;

@end
