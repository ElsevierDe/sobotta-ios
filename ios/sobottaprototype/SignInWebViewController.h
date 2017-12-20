
#import <UIKit/UIKit.h>

@interface SignInWebViewController : UIViewController<UIWebViewDelegate>

@property NSURL *signInUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
