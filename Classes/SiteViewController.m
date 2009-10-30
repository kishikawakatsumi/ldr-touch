#import "SiteViewController.h"
#import "LDRTouchAppDelegate.h"
#import "HUDMessageView.h"
#import "JSON.h"
#import <objc/runtime.h>

@implementation SiteViewController

@synthesize pageURL;
@synthesize lastPageURL;

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[lastPageURL release];
	[pageURL release];
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
	
	titleView.text = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
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

- (void)loadView {
	[super loadView];
	UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	self.view = rootView;
	[rootView release];
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(61.0f, 6.0f, 254.0f, 33.0f)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    titleView.font = [UIFont boldSystemFontOfSize:14.0f];
    titleView.shadowColor = [UIColor darkGrayColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.numberOfLines = 2;
    [self.navigationItem setTitleView:titleView];
    [titleView release];
	
	webView = [[UICWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	[webView setDelegate:self];
	[webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[webView setAutoresizesSubviews:YES];
	[webView setDetectsPhoneNumbers:YES];
	[webView setScalesPageToFit:YES];
	[self.view addSubview:webView];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 416.0f, 320.0f, 44.0f)];
	[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	[toolbar setAutoresizesSubviews:YES];
	[toolbar setBarStyle:UIBarStyleBlackTranslucent];
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBack.png"] style:UIBarButtonItemStylePlain target:webView action:@selector(goBack)];
	forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavForward.png"] style:UIBarButtonItemStylePlain target:webView action:@selector(goForward)];
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:webView action:@selector(reload)];
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:webView action:@selector(stopLoading)];
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPushed:)];
	[toolbar setItems:[NSArray arrayWithObjects:
					   space, backButton, space, forwardButton, space, reloadButton, space, 
					   stopButton, space, actionButton, space, nil]];
	[space release];
	[backButton release];
	[forwardButton release];
	[reloadButton release];
	[stopButton release];
	[actionButton release];
	[rootView addSubview:toolbar];
	[toolbar release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    titleView.text = self.title;
    
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
