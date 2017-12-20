//
//  SignInViewController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 27/08/14.
//  Copyright (c) 2014 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <StoreKit/StoreKit.h>
#import "SOBButtonImage.h"

@interface SignInViewController : UIViewController<GIDSignInDelegate, GIDSignInUIDelegate, SKRequestDelegate>

@property (weak, nonatomic) IBOutlet UILabel *signInTitle;
@property (weak, nonatomic) IBOutlet UILabel *signInMessage;

@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet SOBButtonImage *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *gpAppStoreButton;

@end
