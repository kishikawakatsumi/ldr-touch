#import "EntryViewController.h"
#import "SiteViewController.h"
#import "HUDMessageView.h"
#import "LDRTouchAppDelegate.h"
#import "MarkAsReadOperation.h"
#import "AddPinOperation.h"
#import "NSString+XMLExtensions.h"
#import "Debug.h"

static 	NSString *css = @"*{margin:2px; padding:0;}"
@"div.LDR-title *{text-decoration: none; font-size: 16px; color: black; word-break:break-all;}"
@"span.LDR-created_on, span.LDR-modified_on, span.LDR-author, span.LDR-category{color: #666666; line-height:1.8; font-size:14px; font-family:Arial, san-serif;}"
@"div.LDR-article{}"
@"li{list-style-type:none;}"
@"body{line-height:1.8; font-size:14px; font-family:Arial, san-serif; word-break: break-all;}"
@"body img{max-width:280px;}"
@"hr {border-top:solid 1px #ccc; border-right:none; border-bottom:none; border-left:none; height:1px;}"
@"blockquote{margin:0; padding:2px; border:1px solid #999999;}";

static NSString *htmlBase = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
@"<html xmlns=\"http://www.w3.org/1999/xhtml\">"
@"<head>"
@"<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
@"<meta id=\"viewport\" name=\"viewport\" content=\"width=320, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" />"
@"<title>%@</title>"
@"<style>%@</style>"
@"</head>"
@"<body><div class=\"LDR-title\"><h1><a style=\"display:block;\" href=\"%@\">%@</a></h1></div><span class=\"LDR-created_on\">%@</span><span class=\"LDR-author\">by %@</span><span class=\"LDR-category\">%@</span><div class=\"LDR-article\">%@</div><hr /><span class=\"LDR-created_on\">%@</span><br /><span class=\"LDR-modified_on\">%@</span></body></html>";

@interface EntryViewController (private)

- (void)goWebSite:(id)sender;
- (void)addPin;
- (void)moveEntry:(id)sender;

@end

@implementation EntryViewController

@synthesize entryView;
@synthesize feedList;
@synthesize feed;
@synthesize items;
@synthesize currentItem;

@synthesize feedViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        ;
    }
    return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[feedViewController release];
	
	[formatter release];
	[currentItem release];
	[items release];
	[feed release];
	[feedList release];
	[entryView.webView setDelegate:nil];
	[entryView release];
    [super dealloc];
}

#pragma mark Utility Methods

- (void)hilightedClipedPage {
	[[self.entryView webView] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.backgroundColor = '#FFF0F0';"];
}

- (void)enableButtons {
	NSInteger index = [items indexOfObject:currentItem];
	if ([items count] > 1) {
		[entryView.prevEntryButton setEnabled:YES];
		[entryView.nextEntryButton setEnabled:YES];
	}
	if (index == 0) {
		[entryView.prevEntryButton setEnabled:NO];
	}
	if (index == [items count] - 1) {
		[entryView.nextEntryButton setEnabled:NO];
	}
	
	index = [feedList indexOfObject:feed];
	if ([feedList count] > 1) {
		[entryView.prevFeedButton setEnabled:YES];
		[entryView.nextFeedButton setEnabled:YES];
	}
	if (index == 0) {
		[entryView.prevFeedButton setEnabled:NO];
	}
	if (index == [feedList count] - 1) {
		[entryView.nextFeedButton setEnabled:NO];
	}
}

#pragma mark Action Methods

- (void)updateTitleText {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	
	NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
	
	NSMutableDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	NSMutableDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
	NSInteger unreadCount = [items count] - [listOfReadEachEntry count];
	
	[self setTitle:[NSString stringWithFormat:@"%d / %d(%d)", [items indexOfObject:currentItem] + 1, [items count], unreadCount]];
}

- (void)goWebSite:(id)sender {
	SiteViewController *controller = [[LDRTouchAppDelegate sharedLDRTouchApp] sharedSiteViewController];
	controller.pageURL = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"link"]];
	controller.title = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"title"]];
	[[self navigationController] pushViewController:controller animated:YES];
}

- (void)addPin {
	NSString *title = [NSString decodeXMLCharactersIn:[NSString stringWithFormat:@"%@", [currentItem objectForKey:@"title"]]];
	NSString *link = [NSString decodeXMLCharactersIn:[NSString stringWithFormat:@"%@", [currentItem objectForKey:@"link"]]];
	
	[self hilightedClipedPage];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	NSDictionary *pin = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", link, @"link", nil];
	if (![userSettings.pinList containsObject:pin]) {
		[userSettings.pinList addObject:pin];
	}
	
	AddPinOperation *operation = [[AddPinOperation alloc] initWithLink:link title:title];
	
	[operation executeAction];
	[operation release];
}

- (void)markAsRead {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	NSString *entry_id = [NSString stringWithFormat:@"%@", [currentItem objectForKey:@"id"]];
	
	NSMutableDictionary *requestedOperations = [sharedLDRTouchApp.userSettings requestedOperations];
	if ([requestedOperations objectForKey:subscribe_id]) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
	
	NSMutableDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	NSMutableDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
	if (!listOfReadEachEntry) {
		listOfReadEachEntry = [NSMutableDictionary dictionary];
		[listOfRead setObject:listOfReadEachEntry forKey:key];
	}
	
	if ([listOfReadEachEntry count] == [items count]) {
		return;
	}
	
	[listOfReadEachEntry setObject:entry_id forKey:entry_id];
	sharedLDRTouchApp.userSettings.numberOfUnread -= 1;
	
	if ([listOfReadEachEntry count] == [items count]) {
		[listOfRead setObject:subscribe_id forKey:subscribe_id];
		if ([sharedLDRTouchApp.userSettings markAsReadAuto]) {
			//NSArray *timestamps = [NSArray arrayWithObject:[feed objectForKey:@"modified_on"]];
			MarkAsReadOperation *operation = [[MarkAsReadOperation alloc] initWithSubscribeID:subscribe_id timestamps:nil];
			[operation executeAction];
			[operation release];
		}
	}
}

- (void)loadEntry {
	[self markAsRead];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	[sharedLDRTouchApp saveUserSettings];
	
	NSString *link = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"link"]];
	NSString *title = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"title"]];
	NSString *author = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"author"]];
	NSString *category = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"category"]];
	
	NSNumber *created_on = [currentItem objectForKey:@"created_on"];
	NSNumber *modified_on = [currentItem objectForKey:@"modified_on"];
	NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:[created_on integerValue]];
	NSDate *modifiedDate = [NSDate dateWithTimeIntervalSince1970:[modified_on integerValue]];
	
	NSString *creationDateText = [NSString stringWithFormat:NSLocalizedString(@"PublishDate" ,nil), [formatter stringFromDate:creationDate]];
	NSString *modifiedDateText = nil;
	if (![created_on isEqualToNumber:modified_on]) {
		modifiedDateText = [NSString stringWithFormat:NSLocalizedString(@"ModifiedDate" ,nil), [formatter stringFromDate:modifiedDate]];
	} else {
		modifiedDateText = @"";
	}
	
	NSDate *now = [NSDate date];
	NSTimeInterval timeInterval = [now timeIntervalSince1970] - [creationDate timeIntervalSince1970];
	NSString *relativeTime;
	NSInteger minutes = timeInterval / 60;
	relativeTime = [NSString stringWithFormat:NSLocalizedString(@"RelativeTimeMinutes", nil), minutes];
	if (minutes >= 60) {
		NSInteger hours = minutes / 60;
		relativeTime = [NSString stringWithFormat:NSLocalizedString(@"RelativeTimeHours", nil), hours];
		if (hours >= 24) {
			NSInteger days = hours / 24;
			relativeTime = [NSString stringWithFormat:NSLocalizedString(@"RelativeTimeDays", nil), days];
			if (days >= 30) {
				NSInteger months = days / 30;
				relativeTime = [NSString stringWithFormat:NSLocalizedString(@"RelativeTimeMonths", nil), months];
			}
		}
	}
	NSString *body = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"body"]];
	NSString *html = [NSString stringWithFormat:
					  htmlBase, title, css, link, title, relativeTime, author, category, body, creationDateText, modifiedDateText];
	
	[entryView.webView loadHTMLString:html baseURL:[NSURL URLWithString:link]];
}

- (void)prevEntry:(id)sender {
	NSInteger index = [items indexOfObject:currentItem];
	if (index == 0) {
		return;
	}
	self.currentItem = [items objectAtIndex:index - 1];
	[self enableButtons];
	[self loadEntry];
	[self updateTitleText];
}

- (void)nextEntry:(id)sender {
	NSInteger index = [items indexOfObject:currentItem];
	if (index == [items count] - 1) {
		return;
	}
	self.currentItem = [items objectAtIndex:index + 1];
	[self enableButtons];
	[self loadEntry];
	[self updateTitleText];
}

- (void)prevFeed:(id)sender {
	[feedViewController prevFeed:sender];
	
	self.feedList = feedViewController.feedList;
	self.feed = feedViewController.feed;
	self.items = feedViewController.items;
	self.currentItem = [items lastObject];
	
	[self enableButtons];
	[self loadEntry];
	[self updateTitleText];
	
	NSString *title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
    HUDMessageView *messageView = [[HUDMessageView alloc] initWithMessage:title];
	[messageView showInView:self.view];
	[messageView performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
	[messageView release];
}

- (void)nextFeed:(id)sender {
	[feedViewController nextFeed:sender];
	
	self.feedList = feedViewController.feedList;
	self.feed = feedViewController.feed;
	self.items = feedViewController.items;
	self.currentItem = [items objectAtIndex:0];
	
	[self enableButtons];
	[self loadEntry];
	[self updateTitleText];
	
	NSString *title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
    HUDMessageView *messageView = [[HUDMessageView alloc] initWithMessage:title];
	[messageView showInView:self.view];
	[messageView performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
	[messageView release];
}

- (void)reachabilityChanged:(NSNotification *)note {
	LOG_CURRENT_METHOD;
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (loginManager.remoteHostStatus == NotReachable) {
		[[self.navigationItem rightBarButtonItem] setEnabled:NO];
	} else {
		[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	}
}

#pragma mark <UIWebViewDelegate> Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeOther) {
		return YES;
	}
	NSString *link = [NSString decodeXMLCharactersIn:[currentItem objectForKey:@"link"]];
	if (navigationType == UIWebViewNavigationTypeLinkClicked &&
		[link isEqualToString:[[request URL] absoluteString]]) {
		[self goWebSite:nil];
	}
	
	return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	if ([userSettings.pinList containsObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:[currentItem objectForKey:@"title"], @"title", [currentItem objectForKey:@"link"], @"link", nil]]) {
		[self hilightedClipedPage];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	if ([userSettings.pinList containsObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:[currentItem objectForKey:@"title"], @"title", [currentItem objectForKey:@"link"], @"link", nil]]) {
		[self hilightedClipedPage];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	entryView = [[EntryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	[entryView.webView setDelegate:self];
	[entryView.siteButton setTarget:self];
	[entryView.siteButton setAction:@selector(goWebSite:)];
	[entryView.pinButton setTarget:self];
	[entryView.pinButton setAction:@selector(addPin)];
	[entryView.prevFeedButton setTarget:self];
	[entryView.prevFeedButton setAction:@selector(prevFeed:)];
	[entryView.nextFeedButton setTarget:self];
	[entryView.nextFeedButton setAction:@selector(nextFeed:)];
	[entryView.prevEntryButton setTarget:self];
	[entryView.prevEntryButton setAction:@selector(prevEntry:)];
	[entryView.nextEntryButton setTarget:self];
	[entryView.nextEntryButton setAction:@selector(nextEntry:)];
	[self setView:entryView];
	
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
												 name:@"kNetworkReachabilityChangedNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (loginManager.remoteHostStatus == NotReachable) {
		self.navigationItem.rightBarButtonItem.enabled = NO; 
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self enableButtons];
	[self loadEntry];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self updateTitleText];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[entryView.webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	[entryView.webView stopLoading];
	
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
