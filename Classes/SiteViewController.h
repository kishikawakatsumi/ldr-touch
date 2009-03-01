#import <UIKit/UIKit.h>
#import "UICWebView.h"
#import "HttpClient.h"

@interface SiteViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	IBOutlet UICWebView *webView;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;
	
	NSString *pageURL;
	NSString *lastPageURL;
	BOOL loadFinishedSuccesefully;
}

@property (nonatomic, retain, readonly) UICWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, retain) NSString *pageURL;
@property (nonatomic, retain) NSString *lastPageURL;

- (IBAction)actionButtonPushed:(id)sender;

@end
