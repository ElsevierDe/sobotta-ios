//
//  StaticContentViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 10/5/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "StaticContentViewController.h"
#import "DatabaseController.h"

@interface StaticContentViewController ()

@end

@implementation StaticContentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:SOBLANGUAGECHANGED object:nil];
	// Do any additional setup after loading the view.
    [self loadContent:_staticContentName];
}

- (void) languageChanged: (NSNotification *) notification {
    [self loadContent:_staticContentName];
}

- (void) loadAbbrs {
    NSString *langcolname = [[DatabaseController Current] langcolname];
    NSString *content = @"Sobotta_en_en_Abbreviations_ff";
    if ([langcolname isEqualToString:@"enlat"]) {
        content = @"Sobotta_en_lat_Abbreviations_ff";
    } else if ([langcolname isEqualToString:@"delat"]) {
        content = @"Sobotta_dt_lat_Abkuerzungen_ff";
    }
    [self loadContent:content];
}

- (void) loadCredits {
    NSString *langcolname = [[DatabaseController Current] langcolname];
    NSString *content = @"Sobotta_en_en_picture_credits";
    if ([langcolname isEqualToString:@"enlat"]) {
        content = @"Sobotta_en_lat_picture_credits";
    } else if ([langcolname isEqualToString:@"delat"]) {
        content = @"Sobotta_dt_lat_Bildernachweis";
    }
    [self loadContent:content];
}

- (void) loadContent:(NSString *)content {
    if ([content isEqualToString:@"abbrvs"]) {
        [self loadAbbrs];
        return;
    } else if ([content isEqualToString:@"credits"]) {
        [self loadCredits];
        return;
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:content withExtension:@"htm"];
    NSLog(@"loading url (contentName: %@): %@", content, url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setWebView:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL scheme] isEqualToString:@"http"] || [[request.URL scheme] isEqualToString:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
