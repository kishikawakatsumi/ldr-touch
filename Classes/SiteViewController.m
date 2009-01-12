#import "SiteViewController.h"
#import "InformationSheetController.h"
#import "HUDMessageView.h"
#import "LDRTouchAppDelegate.h"
#import "JSON.h"
#import "Debug.h"

@implementation SiteViewController

@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize pageURL;
@synthesize lastPageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Comment.png"]
																		  style:UIBarButtonItemStyleBordered target:self action:@selector(showInfoMenu)];
		[[self navigationItem] setRightBarButtonItem:commentButton];
		[commentButton release];
    }
    return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[conn release];
	[lastPageURL release];
	[pageURL release];
	[forwardButton release];
	[backButton release];
	[webView setDelegate:nil];
	[webView release];
    [super dealloc];
}

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (void)loadPageInfo {
	[conn cancel];
	[self reset];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	conn = [[HttpClient alloc] initWithDelegate:self];
	[conn get:[NSString stringWithFormat:@"http://b.hatena.ne.jp/entry/json/%@", [[webView.request mainDocumentURL] absoluteString]] parameters:nil];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *json = [[s substringFromIndex:1] substringToIndex:[s length] -2];
	pageInfo = [json JSONValue];
	[s release];
	
	if ((NSNull *)pageInfo != [NSNull null] && [pageInfo count] > 0) {
		[pageInfo retain];
		[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	} else {
		pageInfo = nil;
	}
	
	[self reset];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self reset];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showInfoMenu {
	isInfoMenuPresent = YES;
	InformationSheetController *controller = [[[InformationSheetController alloc]
											   initWithNibName:@"InformationSheet" bundle:nil] autorelease];
	
	controller.pageInfo = pageInfo;
	controller.bookmarks = [pageInfo objectForKey:@"bookmarks"];
	
	[self presentModalViewController:controller animated:YES];
}

- (IBAction)actionButtonPushed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:NSLocalizedString(@"ReloadThisPage", nil)
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
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	LOG_CURRENT_METHOD;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = YES;
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	self.title = [aWebView stringByEvaluatingJavaScriptFromString:
				  @"try {var a = document.getElementsByTagName('a'); for (var i = 0; i < a.length; ++i) { a[i].setAttribute('target', '');}}catch (e){}; document.title"];
	NSString *aURL = [[[aWebView request] mainDocumentURL] absoluteString];
	self.lastPageURL = aURL;
	
	[self loadPageInfo];
	
	LOG_CURRENT_METHOD;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = NO;
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	LOG_CURRENT_METHOD;
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
	if (isInfoMenuPresent) {
		isInfoMenuPresent = NO;
		return;
	}
    [super viewWillAppear:animated];
	[[[self navigationItem] rightBarButtonItem] setEnabled:NO];
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
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
	} else {
		[self loadPageInfo];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if (isInfoMenuPresent) {
		return;
	}
	[super viewWillDisappear:animated];
	[webView stopLoading];
	[pageInfo release];
	pageInfo = nil;
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
	
	[webView stopLoading];
	
	BOOL isOnTop = ([self.navigationController topViewController] == self);
	if (isOnTop) {
		HUDMessageView *messageView = [[HUDMessageView alloc] initWithMessage:NSLocalizedString(@"MemoryWarning", nil)];
		[messageView showInView:self.view];
		[messageView performSelector:@selector(dismiss) withObject:nil afterDelay:2.0f];
		[messageView release];
	}
	
	LOG_CURRENT_METHOD;
}

@end
