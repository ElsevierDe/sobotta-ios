//
//  SignInViewController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 27/08/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import "SignInViewController.h"

#import <GoogleSignIn/GoogleSignIn.h>

#import "SignInSync.h"
#import "ASIHTTPRequest.h"
#import "SOBApplication.h"
#import "SignInWebViewController.h"

@interface SignInViewController ()

@property id<NSObject> googleAuthNotificationObserver;

@end

@implementation SignInViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        __weak SignInViewController *weakSelf = self;
        _googleAuthNotificationObserver = \
        [[NSNotificationCenter defaultCenter] addObserverForName:ApplicationOpenGoogleAuthNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [weakSelf performSegueWithIdentifier:@"showSignInWebViewController" sender:note.object];
                                                      }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.googleAuthNotificationObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    //configure "load google+ app" button
    _gpAppStoreButton.hidden = YES;
//    _gpAppStoreButton.titleLabel.textAlignment=NSTextAlignmentCenter;
//    [_gpAppStoreButton setTitle:NSLocalizedString(@"Load Google+ App", nil) forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    // initialize google+ sign in
    GIDSignIn *signIn = [GIDSignIn sharedInstance];

    
    signIn.clientID = SOB_GOOGLEPLUS_ID;
    signIn.shouldFetchBasicProfile = YES;
    signIn.scopes = @[@"profile", @"email"];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    [signIn signInSilently];
    [self switchToLogin:[[GIDSignIn sharedInstance] hasAuthInKeychain]];

    _signInTitle.text = NSLocalizedString(@"Social Sign In Title", nil);
    _signInMessage.text = NSLocalizedString(@"Social Sign In Message", nil);
    //[_signOutButton setTitle:NSLocalizedString(@"Sign Out", nil) forState:UIControlStateNormal];
    _signOutButton.sobLabel.text = NSLocalizedString(@"Sign Out", nil);
    [_helpButton setTitle:NSLocalizedString(@"Social Sign In: Help", nil) forState:UIControlStateNormal];
}

- (void) switchToLogin:(BOOL) isLoggedIn {

    _signInButton.hidden = isLoggedIn;
    _signOutButton.hidden = !isLoggedIn;
}

- (IBAction)helpPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sobottaapp.com/help/restore"]];
}

- (IBAction)signOutPressed:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    [self switchToLogin:NO];
}

- (IBAction)openAppStore:(id)sender {
    //not used at the moment (problems with apple app store guidelines?)
    //open google+ app in app store
    NSString *iTunesLink = @"itms://itunes.apple.com/at/app/google+/id447119634?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSignInWebViewController"]) {
        SignInWebViewController *webViewController = segue.destinationViewController;
        webViewController.signInUrl = sender;
    }
}

#pragma mark - GPSSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [self switchToLogin:[[GIDSignIn sharedInstance] hasAuthInKeychain]];

    NSLog(@"starting receipt refresh request.");
    SKReceiptRefreshRequest* receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] init];
    receiptRefreshRequest.delegate = self;
    [receiptRefreshRequest start];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {

}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"SKRequest finished. %@", request);
    [[SignInSync instance] syncReceipt];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    //TFLog(@"SKRequest failed with error: %@", error);
    [[SignInSync instance] syncReceipt];
}


@end
