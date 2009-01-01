#import "RootViewController.h"
#import "FeedViewController.h"
#import "FeedListCell.h"
#import "PinListViewController.h"
#import "UserSettingSheetController.h"
#import "LDRTouchAppDelegate.h"
#import "LoginManager.h"
#import "CacheManager.h"
#import "Reachability.h";
#import "JSON.h"
#import "NSString+XMLExtensions.h"
#import "Debug.h"

#define INSETS 18

@interface RootViewController (private)

- (void)loadFeedList;
- (void)organize;
- (void)countUnreadItems;
- (NSString *)getStarsWithRate:(NSNumber *)rating;

@end

@implementation RootViewController

static NSDateFormatter *dateFormatter = NULL;

@synthesize feedListView;
@synthesize toolBar;
@synthesize refleshButton;
@synthesize pinListButton;
@synthesize modifiedDateLabel;

@synthesize feedList;
@synthesize organizedFeedList;
@synthesize sectionHeaders;

@synthesize unreadMark1;
@synthesize unreadMark2;
@synthesize star;
@synthesize starBlank;

+ (void)initialize {
	LOG_CURRENT_METHOD;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[starBlank release];
	[star release];
	[unreadMark2 release];
	[unreadMark1 release];
	
	[sectionHeaders release];
	[organizedFeedList release];
	[feedList release];
	
	[downloader setDelegate:nil];
	[downloader release];
	[conn setDelegate:nil];
	[conn release];
	
	[modifiedDateLabel release];
	[pinListButton release];
	[refleshButton release];
	[toolBar release];
	[feedListView setDelegate:nil];
	[feedListView release];
    [super dealloc];
}

#pragma mark <Data Loading>

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (IBAction)refreshData {
	[self loadFeedList];	
}

- (void)refreshDataIfNeeded {
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
	[refleshButton setEnabled:NO];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (!loginManager.api_key) {
		[loginManager setDelegate:self];
		[loginManager login];
		return;
	}
	
	[conn cancel];
	[self reset];
	
	conn = [[HttpClient alloc] initWithDelegate:self];
	[conn post:@"http://reader.livedoor.com/api/subs" parameters:[NSDictionary dictionaryWithObjectsAndKeys:
																  @"1", @"unread", 
																  loginManager.api_key, @"ApiKey", nil]];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
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
	
	[refleshButton setEnabled:YES];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[CacheManager saveFeedList:feedList];
	
	userSettings.lastModified = [NSDate date];
	[modifiedDateLabel setText:[dateFormatter stringFromDate:userSettings.lastModified]];
	
	[downloader cancel];
	
	downloader = [[FeedDownloader alloc] initWithFeedList:feedList];
	[downloader setDelegate:self];
	[downloader start];
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self reset];
	[refleshButton setEnabled:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)feedDownloaderDidEntryDownloadSucceeded:(FeedDownloader *)sender {
	[feedListView reloadData];
}

- (void)feedDownloaderSucceeded:(FeedDownloader *)sender {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
}

- (void)feedDownloaderCanceled:(FeedDownloader *)sender {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
}

- (void)feedDownloaderFailed:(FeedDownloader *)sender error:error {
	LOG_CURRENT_METHOD;
	[sender setDelegate:nil];
	[sender release];
	downloader = nil;
}

- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey {
	[sender setDelegate:nil];
	[self loadFeedList];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
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
	LOG(@"unread items count: %d", numberOfUnread);
}

- (NSString *)getStarsWithRate:(NSNumber *)rating {
	if (!star) {
		self.star = [NSString stringWithUTF8String:"★"];
	}
	if (!starBlank) {
		self.starBlank = [NSString stringWithUTF8String:"☆"];
	}
	
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
	UserSettingSheetController *controller = [[UserSettingSheetController alloc]
											  initWithNibName:@"UserSettingSheet" bundle:nil];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction)showPinList:(id)sender {
	PinListViewController *controller = [[PinListViewController alloc] initWithNibName:@"PinListView" bundle:nil];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)reachabilityChanged:(NSNotification *)note {
	LOG_CURRENT_METHOD;
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (loginManager.remoteHostStatus == NotReachable) {
		[refleshButton setEnabled:NO];
		[pinListButton setEnabled:NO];
		[toolBar setBarStyle:UIBarStyleBlackOpaque];
	} else {
		[refleshButton setEnabled:YES];
		[pinListButton setEnabled:YES];
		[toolBar setBarStyle:UIBarStyleDefault];
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
		cell = [[[FeedListCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f) reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (!unreadMark1) {
		self.unreadMark1 = [UIImage imageNamed:@"unread.png"];
	}
	if (!unreadMark2) {
		self.unreadMark2 = [UIImage imageNamed:@"unread2.png"];
	}
	
	NSDictionary *feed = [[organizedFeedList objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	
	[cell.titleLabel setText:[NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]]];
	
	if ([CacheManager containsEntriesOf:subscribe_id]) {
		[cell.titleLabel setTextColor:[UIColor blackColor]];
	} else {
		[cell.titleLabel setTextColor:[UIColor grayColor]];
	}
	
	NSNumber *unread_count = [feed objectForKey:@"unread_count"];
	NSDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	if (![listOfRead objectForKey:subscribe_id]) {
		NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
		NSDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
		if (listOfReadEachEntry) {
			[cell.unreadMark setImage:unreadMark2];
			[cell.readCountLabel setText:[NSString stringWithFormat:@"%d", [unread_count intValue] - [listOfReadEachEntry count]]];
			[cell.unreadCountLabel setText:[NSString stringWithFormat:@"%@", unread_count]];
		} else {
			[cell.unreadMark setImage:unreadMark1];
			[cell.readCountLabel setText:nil];
			[cell.unreadCountLabel setText:[NSString stringWithFormat:@"%@", unread_count]];
		}
	} else {
		[cell.unreadMark setImage:nil];
		[cell.readCountLabel setText:nil];
		[cell.unreadCountLabel setText:nil];
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
	
	FeedViewController *controller = [[FeedViewController alloc] init];
	NSDictionary *feed = [[organizedFeedList objectForKey:[sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	controller.feedList = feedList;
	controller.feed = feed;
	controller.title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	modifiedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0f, 11.0f, 156.0f, 21.0f)];
	if (userSettings.lastModified) {
		[modifiedDateLabel setText:[dateFormatter stringFromDate:userSettings.lastModified]];
	}
	[modifiedDateLabel setFont:[UIFont systemFontOfSize:12.0f]];
	[modifiedDateLabel setTextColor:[UIColor whiteColor]];
	[modifiedDateLabel setBackgroundColor:[UIColor clearColor]];
	[toolBar addSubview:modifiedDateLabel];
	
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
	[self.feedListView deselectRowAtIndexPath:[self.feedListView indexPathForSelectedRow] animated:YES];
	[self.feedListView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	LOG_CURRENT_METHOD;
}

@end
