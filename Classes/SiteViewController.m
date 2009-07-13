#import "SiteViewController.h"
#import "LDRTouchAppDelegate.h"
#import "HUDMessageView.h"
#import "JSON.h"
#import <objc/runtime.h>

@implementation SiteViewController

@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize pageURL;
@synthesize lastPageURL;

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[lastPageURL release];
	[pageURL release];
	[forwardButton release];
	[backButton release];
	[webView setDelegate:nil];
	[webView release];
    [super dealloc];
}

- (IBAction)actionButtonPushed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:nil
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
								  destructiveButtonTitle:nil
								  otherButtonTitles:
								  NSLocalizedString(@"DirectAccess", nil),
								  NSLocalizedString(@"WithMobileProxy", nil),
								  NSLocalizedString(@"OpenSafari", nil), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark <UIActionSheetDelegate> Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	LOG(@"action button pushed: %d", buttonIndex);
	if (buttonIndex == 0) {
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pageURL]]];
	} else if (buttonIndex == 1) {
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.co.jp/gwt/n?u=%@", pageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
	} else if (buttonIndex == 2) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:pageURL]];
	}
}

#pragma mark <UIWebViewDelegate> Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *aURL = [[request URL] absoluteString];
	NSString *mainDocumentURL = [request.mainDocumentURL absoluteString];
	if (mainDocumentURL == nil || ![mainDocumentURL isEqualToString:aURL]) {
		return NO;
	}
	
	LOG(@"<%@>", [request URL]);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
	
	LOG_CURRENT_METHOD;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = YES;
	
	backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
	
	self.title = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
	NSString *aURL = [[[aWebView request] mainDocumentURL] absoluteString];
	self.lastPageURL = aURL;
	
	LOG_CURRENT_METHOD;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = NO;
	
	backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
	
	LOG_CURRENT_METHOD;
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
	
	if (![pageURL isEqualToString:lastPageURL] || !loadFinishedSuccesefully) {
		LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
		UserSettings *userSettings = sharedLDRTouchApp.userSettings;
		NSURL *url;
		if (userSettings.useMobileProxy) {
			url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.co.jp/gwt/n?u=%@", pageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		} else {
			url = [NSURL URLWithString:pageURL];
		}
		[webView loadRequest:[NSURLRequest requestWithURL:url]];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (fromInterfaceOrientation == UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	} else {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
    return userSettings.shouldAutoRotation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	/*
	[webView stopLoading];
	
	BOOL isOnTop = ([self.navigationController topViewController] == self);
	if (isOnTop) {
		HUDMessageView *messageView = [[HUDMessageView alloc] initWithMessage:NSLocalizedString(@"MemoryWarning", nil)];
		[messageView showInView:self.view];
		[messageView performSelector:@selector(dismiss) withObject:nil afterDelay:2.0f];
		[messageView release];
	}
	*/
	LOG_CURRENT_METHOD;
}

@end
