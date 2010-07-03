#import "RootViewController.h"
#import "FeedViewController.h"
#import "FeedListCell.h"
#import "PinListViewController.h"
#import "UserSettingSheetController.h"
#import "LDRTouchAppDelegate.h"
#import "LoginManager.h"
#import "CacheManager.h"
#import "NetworkActivityManager.h"
#import "Reachability.h";
#import "JSON.h"
#import "NSString+XMLExtensions.h"

#define INSETS 18

@interface RootViewController (private)

- (void)loadFeedList;
- (void)organize;
- (void)countUnreadItems;
- (NSString *)getStarsWithRate:(NSNumber *)rating;

@end

@implementation RootViewController

static NSDateFormatter *dateFormatter = NULL;
static NSDateFormatter *timeFormatter = NULL;
static UIImage *unreadMark1 = NULL;
static UIImage *unreadMark2 = NULL;
static NSString *star = NULL;
static NSString *starBlank = NULL;

@synthesize feedListView;
@synthesize toolbar;
@synthesize refreshButton;
@synthesize pinListButton;
@synthesize modifiedDateLabel;
@synthesize modifiedTimeLabel;

@synthesize feedList;
@synthesize organizedFeedList;
@synthesize sectionHeaders;

+ (void)initialize {
	LOG_CURRENT_METHOD;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
	unreadMark1 = [[UIImage imageNamed:@"unread.png"] retain];
	unreadMark2 = [[UIImage imageNamed:@"unread2.png"] retain];
	star = [[NSString stringWithUTF8String:"★"] retain];
	starBlank = [[NSString stringWithUTF8String:"☆"] retain];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[sectionHeaders release];
	[organizedFeedList release];
	[feedList release];
	
	[downloader setDelegate:nil];
	[downloader release];
	[conn setDelegate:nil];
	[conn release];
    
	[feedListView setDelegate:nil];
    
    [super dealloc];
}

#pragma mark <Data Loading>

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (IBAction)refreshData {
	LOG_CURRENT_METHOD;
	[self loadFeedList];	
}

- (void)refreshDataIfNeeded {
	LOG_CURRENT_METHOD;
	NSArray *listOfFeed = [CacheManager loadFeedList];
	if (!listOfFeed) {
		[self refreshData];
	} else {
		self.feedList = listOfFeed;
		[self organize];
		[self countUnreadItems];
		[self.feedListView reloadData];
	}
}

- (void)loadFeedList {
	LOG_CURRENT_METHOD;
	[refreshButton setEnabled:NO];
	
    [[NetworkActivityManager sharedInstance] pushActivity];
	
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (!loginManager.api_key) {
		[loginManager setDelegate:self];
		[loginManager login];
		return;
	}
	
	[conn cancel];
	[self reset];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	conn = [[HttpClient alloc] initWithDelegate:self];
	[conn post:[NSString stringWithFormat:@"%@%@", userSettings.serviceURI, @"/api/subs"]
	parameters:[NSDictionary dictionaryWithObjectsAndKeys:
				@"1", @"unread", 
				loginManager.api_key, @"ApiKey", nil]];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
    LOG_CURRENT_METHOD;
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSArray *listOfFeed = [s JSONValue];
	[s release];
	if (!listOfFeed) {
		return;
	}
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	[[userSettings listOfRead] removeAllObjects];
	[[userSettings unfinishedOperations] removeAllObjects];
	
	self.feedList = listOfFeed;
	[self organize];
	[self countUnreadItems];
	[self.feedListView reloadData];
	
	[self reset];
	
	[refreshButton setEnabled:YES];
	
    [[NetworkActivityManager sharedInstance] popActivity];
	
	[CacheManager saveFeedList:feedList];
	
	userSettings.lastModified = [NSDate date];
	[modifiedDateLabel setText:[dateFormatter stringFromDate:userSettings.lastModified]];
	[modifiedTimeLabel setText:[timeFormatter stringFromDate:userSettings.lastModified]];
	
	[downloader cancel];
	
    [[NetworkActivityManager sharedInstance] pushActivity];
    [[NetworkActivityManager sharedInstance] pushActivity];
    [[NetworkActivityManager sharedInstance] pushActivity];
    [[NetworkActivityManager sharedInstance] pushActivity];
    [[NetworkActivityManager sharedInstance] pushActivity];
    
	downloader = [[FeedDownloader alloc] initWithFeedList:feedList];
	[downloader setDelegate:self];
	[downloader start];
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self reset];
	[refreshButton setEnabled:YES];
    [[NetworkActivityManager sharedInstance] popActivity];
}

- (void)feedDownloaderDidEntryDownloadSucceeded:(FeedDownloader *)sender {
    LOG_CURRENT_METHOD;
	[feedListView reloadData];
}

- (void)feedDownloaderSucceeded:(FeedDownloader *)sender {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
    
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
}

- (void)feedDownloaderCanceled:(FeedDownloader *)sender {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
    
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
}

- (void)feedDownloaderFailed:(FeedDownloader *)sender error:error {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
    
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
    [[NetworkActivityManager sharedInstance] popActivity];
}

- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey {
    LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[self loadFeedList];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
    LOG_CURRENT_METHOD;
	[refreshButton setEnabled:YES];
	
	[sender setDelegate:nil];
	
	NSString *message = NSLocalizedString(@"LoginFailure", nil);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) message:message
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

#pragma mark <Sort Feed List>

NSInteger compareFeedListByDateAsc(id arg1, id arg2, void *context) {
	id date1 = [arg1 objectForKey:@"modified_on"];
	id date2 = [arg2 objectForKey:@"modified_on"];
	return [date1 compare:date2];
}

NSInteger compareFeedListByDate(id arg1, id arg2, void *context) {
	return compareFeedListByDateAsc(arg1, arg2, context) * -1;
}

NSInteger compareFeedListByNumberOfUnreadAsc(id arg1, id arg2, void *context) {
	id unread_count1 = [arg1 objectForKey:@"unread_count"];
	id unread_count2 = [arg2 objectForKey:@"unread_count"];
	return [unread_count1 compare:unread_count2];
}

NSInteger compareFeedListByNumberOfUnread(id arg1, id arg2, void *context) {
	return compareFeedListByNumberOfUnreadAsc(arg1, arg2, context) * -1;
}

NSInteger compareFeedListByTitle(id arg1, id arg2, void *context) {
	id title1 = [arg1 objectForKey:@"title"];
	id title2 = [arg2 objectForKey:@"title"];
	return [title1 compare:title2];
}

NSInteger compareFeedListByRating(id arg1, id arg2, void *context) {
	id rate1 = [arg1 objectForKey:@"rate"];
	id rate2 = [arg2 objectForKey:@"rate"];
	return [rate1 compare:rate2] * -1;
}

NSInteger compareFeedListByNumberOfSubscribersAsc(id arg1, id arg2, void *context) {
	id subscribers_count1 = [arg1 objectForKey:@"subscribers_count"];
	id subscribers_count2 = [arg2 objectForKey:@"subscribers_count"];
	return [subscribers_count1 compare:subscribers_count2];
}

NSInteger compareFeedListByNumberOfSubscribers(id arg1, id arg2, void *context) {
	return compareFeedListByNumberOfSubscribersAsc(arg1, arg2, context) * -1;
}

NSInteger compareFeedListBySubscribeIDAsc(id arg1, id arg2, void *context) {
	id subscribe_id1 = [arg1 objectForKey:@"subscribe_id"];
	id subscribe_id2 = [arg2 objectForKey:@"subscribe_id"];
	return [subscribe_id1 compare:subscribe_id2];
}

NSInteger compareFeedListBySubscribeID(id arg1, id arg2, void *context) {
	return compareFeedListBySubscribeIDAsc(arg1, arg2, context) * -1;
}

- (NSArray *)sortFeedList:(NSArray *)aFeedList sortOrder:(UserSettingsSortOrder)sortOrder {
	NSArray *sortedFeedList = nil;
	if (sortOrder == UserSettingsSortOrderDate) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByDate context:nil];
	} else if (sortOrder == UserSettingsSortOrderNumberOfUnread) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByNumberOfUnread context:nil];
	} else if (sortOrder == UserSettingsSortOrderNumberOfSubscribers) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByNumberOfSubscribers context:nil];
	} else if (sortOrder == UserSettingsSortOrderTitle) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByTitle context:nil];
	} else if (sortOrder == UserSettingsSortOrderRate) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByRating context:nil];
	} else if (sortOrder == UserSettingsSortOrderDateAsc) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByDateAsc context:nil];
	} else if (sortOrder == UserSettingsSortOrderNumberOfUnreadAsc) {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByNumberOfUnreadAsc context:nil];
	} else {
		sortedFeedList = [aFeedList sortedArrayUsingFunction:compareFeedListByNumberOfSubscribersAsc context:nil];
	}
	
	return sortedFeedList;
}

- (void)organize {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettingsViewMode viewMode = sharedLDRTouchApp.userSettings.viewMode;
	
	self.feedList = [self sortFeedList:feedList sortOrder:sharedLDRTouchApp.userSettings.sortOrder];
	
	id sectionKey;
	if (viewMode == UserSettingsViewModeFlat) {
		self.organizedFeedList = [NSMutableDictionary dictionary];
		[organizedFeedList setObject:feedList forKey:@""];
		self.sectionHeaders = [NSArray arrayWithObject:@""];
	} else {
		self.organizedFeedList = [NSMutableDictionary dictionary];
		
		if (viewMode == UserSettingsViewModeFolder) {
			sectionKey = @"folder";
		} else if (viewMode == UserSettingsViewModeRate) {
			sectionKey = @"rate";
		} else {
			sectionKey = @"subscribers_count";
		}
		
		for (NSDictionary *original in feedList) {
			id section = [original objectForKey:sectionKey];
			if (viewMode == UserSettingsViewModeRate) {
				section = [self getStarsWithRate:section];
			}
			NSMutableArray *listInSection = [organizedFeedList objectForKey:section];
			if (!listInSection) {
				listInSection = [NSMutableArray array];
				[organizedFeedList setObject:listInSection forKey:section];
			}
			[listInSection addObject:original];
		}
	}
}

- (void)countUnreadItems {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	NSInteger numberOfUnread = 0;
	for (id feed in feedList) {
		numberOfUnread += [[feed objectForKey:@"unread_count"] integerValue];
		
		NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]]; 
		NSDictionary *listOfRead = [userSettings listOfRead];
		if (![listOfRead objectForKey:subscribe_id]) {
			NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
			NSDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
			if (listOfReadEachEntry) {
				numberOfUnread -= [listOfReadEachEntry count];
			}
		}
	}
	
	self.sectionHeaders = [[organizedFeedList allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *sortedFeedList = [NSMutableArray arrayWithCapacity:[feedList count]];
	for (id sectionHeader in sectionHeaders) {
		NSArray *listInSection = [organizedFeedList objectForKey:sectionHeader];
		for (id feed in listInSection) {
			[sortedFeedList addObject:feed];
		}
	}
	self.feedList = sortedFeedList;
	
	userSettings.numberOfUnread = numberOfUnread;
	self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"AppName", nil), numberOfUnread];
	LOG(@"unread items count: %d", numberOfUnread);
}

- (NSString *)getStarsWithRate:(NSNumber *)rating {
	NSMutableString *stars = [NSMutableString stringWithString:@""];
	int i = 0;
	for (; i < [rating intValue]; i++) {
		[stars appendString:star];
	}
	for (; i < 5; i++) {
		[stars appendString:starBlank];
	}
	return stars;
}

#pragma mark <UI Methods>

- (IBAction)showSettingView:(id)sender {
	UserSettingSheetController *controller = [[UserSettingSheetController alloc] init];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction)showPinList:(id)sender {
	PinListViewController *controller = [[PinListViewController alloc] init];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)reachabilityChanged:(NSNotification *)note {
	LOG_CURRENT_METHOD;
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (loginManager.remoteHostStatus == NotReachable) {
		[refreshButton setEnabled:NO];
		[pinListButton setEnabled:NO];
	} else {
		[refreshButton setEnabled:YES];
		[pinListButton setEnabled:YES];
	}
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger count = [sectionHeaders count];
	if (count == 0) {
		return 1;
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([sectionHeaders count] == 0) {
		return nil;
	}
	id titleForHeader = [sectionHeaders objectAtIndex:section];
	return [NSString stringWithFormat:@"%@", titleForHeader];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if ([sectionHeaders count] == 0) {
		return nil;
	}
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettingsViewMode viewMode = sharedLDRTouchApp.userSettings.viewMode;
	
	NSMutableArray *sectionIndex = [NSMutableArray arrayWithCapacity:[sectionHeaders count]];
	if (viewMode == UserSettingsViewModeRate) {
		for (NSString *sectionHeader in sectionHeaders) {
			[sectionIndex addObject:[NSString stringWithFormat:@"%d", [[sectionHeader stringByReplacingOccurrencesOfString:starBlank withString:@""] length]]];
		}
	} else if (viewMode == UserSettingsViewModeFolder) {
		for (NSString *sectionHeader in sectionHeaders) {
			if ([sectionHeader length] > 0) {
				[sectionIndex addObject:[sectionHeader substringToIndex:1]];
			} else {
				[sectionIndex addObject:@"-"];
			}
		}
	} else {
		return nil;
	}
	
	return sectionIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([sectionHeaders count] == 0) {
		return 0;
	}
	return [[organizedFeedList objectForKey:[sectionHeaders objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.00;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FeedListCell";
	FeedListCell *cell = (FeedListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FeedListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDictionary *feed = [[organizedFeedList objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	
	[cell setTitleText:[NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]]];
	
	if ([CacheManager containsEntriesOf:subscribe_id]) {
		[cell setCached:YES];
	} else {
		[cell setCached:NO];
	}
	
	NSNumber *unread_count = [feed objectForKey:@"unread_count"];
	NSDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	if (![listOfRead objectForKey:subscribe_id]) {
		NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
		NSDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
		if (listOfReadEachEntry) {
			[cell setUnreadMarkImage:unreadMark2];
			[cell setReadCountText:[NSString stringWithFormat:@"%d", [unread_count intValue] - [listOfReadEachEntry count]]];
			[cell setUnreadCountText:[NSString stringWithFormat:@"%@", unread_count]];
		} else {
			[cell setUnreadMarkImage:unreadMark1];
			[cell setReadCountText:nil];
			[cell setUnreadCountText:[NSString stringWithFormat:@"%@", unread_count]];
		}
	} else {
		[cell setUnreadMarkImage:nil];
		[cell setReadCountText:nil];
		[cell setUnreadCountText:nil];
	}
    
	if ([self sectionIndexTitlesForTableView:tableView] ) {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	} else {
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
    return cell;
}

#pragma mark <UITableViewDelegate> Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!feedList || [feedList count] == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	
    UIBarButtonItem *backBarButtonItem = 
    [[UIBarButtonItem alloc] initWithImage:
     [UIImage imageNamed:@"backBarButtonImage.png"] 
                                     style:UIBarButtonItemStyleBordered
                                    target:nil 
                                    action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    [backBarButtonItem release];
	
	FeedViewController *controller = [[FeedViewController alloc] init];
	NSDictionary *feed = [[organizedFeedList objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	controller.feedList = feedList;
	controller.feed = feed;
	controller.title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	[super loadView];
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	self.view = contentView;
	[contentView release];
    
    feedListView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372.0f)];
    feedListView.delegate = self;
    feedListView.dataSource = self;
    [contentView addSubview:feedListView];
    [feedListView release];
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 372.0f, 320.0f, 44.0f)];
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 24.0f;
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshData)];
	pinListButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showPinList:)];
	UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingView:)];
	[toolbar setItems:[NSArray arrayWithObjects:
					   refreshButton, flexibleSpace, pinListButton, fixedSpace, settingButton, nil]];
	[fixedSpace release];
    [flexibleSpace release];
	[refreshButton release];
	[pinListButton release];
	[settingButton release];
	[contentView addSubview:toolbar];
	[toolbar release];
	
	modifiedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0f, 11.0f, 60.0f, 21.0f)];
	[modifiedDateLabel setFont:[UIFont systemFontOfSize:12.0f]];
	[modifiedDateLabel setTextColor:[UIColor whiteColor]];
	[modifiedDateLabel setBackgroundColor:[UIColor clearColor]];
	[toolbar addSubview:modifiedDateLabel];
    [modifiedDateLabel release];
	
	modifiedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(101.0f, 11.0f, 100.0f, 21.0f)];
	[modifiedTimeLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
	[modifiedTimeLabel setTextColor:[UIColor whiteColor]];
	[modifiedTimeLabel setBackgroundColor:[UIColor clearColor]];
	[toolbar addSubview:modifiedTimeLabel];
    [modifiedTimeLabel release];
    
    Class clazz = NSClassFromString(@"ADBannerView");
    if (clazz) {
        adView = [[clazz alloc] initWithFrame:CGRectZero];
        adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
        adView.delegate = self;
        
        feedListView.tableFooterView = adView;
        bannerIsVisible = YES;
        
        [adView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	if (userSettings.lastModified) {
		[modifiedDateLabel setText:[dateFormatter stringFromDate:userSettings.lastModified]];
		[modifiedTimeLabel setText:[timeFormatter stringFromDate:userSettings.lastModified]];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
												 name:@"kNetworkReachabilityChangedNotification" object:nil];

	if ([[userSettings userName] length] == 0 || [[sharedLDRTouchApp.userSettings password] length] == 0) {
		[self showSettingView:nil];
	} else {
		[self refreshDataIfNeeded];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"AppName", nil), userSettings.numberOfUnread];
	
    [feedListView flashScrollIndicators];
	[feedListView deselectRowAtIndexPath:[self.feedListView indexPathForSelectedRow] animated:YES];
	[feedListView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	LOG_CURRENT_METHOD;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    feedListView = nil;
}

#pragma mark <ADBannerViewDelegate> Methods

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    LOG_CURRENT_METHOD;
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    LOG_CURRENT_METHOD;
}    

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (bannerIsVisible) {
        [UIView beginAnimations:nil context:NULL];
        adView.delegate = nil;
        feedListView.tableFooterView = nil;
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

@end
