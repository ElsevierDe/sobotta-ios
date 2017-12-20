//
//  CaptionViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 12/18/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "CaptionViewController.h"
#import "ImageViewController.h"

@interface CaptionViewController ()

@end

@implementation CaptionViewController


- (void)setCaptionHtml:(NSString *)captionHtml {
    _captionHtml = captionHtml;
    if ([self isViewLoaded]) {
        [_captionWebView loadHTMLString:_captionHtml baseURL:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _captionWebView.delegate = self;
    [_captionWebView loadHTMLString:_captionHtml baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCaptionWebView:nil];
    [super viewDidUnload];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if([request.URL.absoluteString hasPrefix:@"sobotta"]){
        NSArray *vcs = [self.navigationController viewControllers];
        ImageViewController *ivc = [vcs objectAtIndex:vcs.count - 2];
        [ivc webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

@end
