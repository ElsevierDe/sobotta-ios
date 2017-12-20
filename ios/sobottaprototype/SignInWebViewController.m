
#import "SignInWebViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface SignInWebViewController ()

@end

@implementation SignInWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.signInUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    NSLog(@"url: %@", [url absoluteString]);
    if ([[url absoluteString] hasPrefix:@"com.austrianapps.ios.elsevier."]
        && [[url absoluteString] containsString:@":/oauth2callback"]) {

        // Looks like we did log in (onhand of the url), we are logged in, the Google APi handles the rest
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}


@end
