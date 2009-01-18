#import "FeedViewController.h"
#import "FeedCell.h";
#import "EntryViewController.h"
#import "LDRTouchAppDelegate.h"
#import "LoginManager.h"
#import "CacheManager.h"
#import "MarkAsReadOperation.h"
#import "JSON.h"
#import "NSString+XMLExtensions.h"
#import "Debug.h"

@interface FeedViewController (private)

- (void)loadEntries:(NSString *)subscribe_id;

@end

@implementation FeedViewController

static UIImage *unreadMark = NULL;

@synthesize feedView;
@synthesize feedList;
@synthesize feed;
@synthesize entries;
@synthesize items;

+ (void)initialize {
	LOG_CURRENT_METHOD;
	unreadMark = [[UIImage imageNamed:@"unread.png"] retain];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[items release];
	[entries release];
	[feed release];
	[feedList release];
	[feedView.tableView setDelegate:nil];
	[feedView release];
	[conn release];
    [super dealloc];
}

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

#pragma mark Utility Methods

NSInteger compareEntriesByDate(id arg1, id arg2, void *context) {
	id date1 = [arg1 objectForKey:@"created_on"];
	id date2 = [arg2 objectForKey:@"created_on"];
	
	return [date1 compare:date2] * -1;
}

- (void)enableButtons {
	NSInteger index = [feedList indexOfObject:feed];
	if ([feedList count] > 1) {
		[feedView.prevButton setEnabled:YES];
		[feedView.nextButton setEnabled:YES];
	}
	if (index == 0) {
		[feedView.prevButton setEnabled:NO];
	}
	if (index == [feedList count] - 1) {
		[feedView.nextButton setEnabled:NO];
	}
}

#pragma mark Action Methods

- (void)backToTop {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)markAsRead {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	
	MarkAsReadOperation *operation = [[[MarkAsReadOperation alloc] initWithSubscribeID:subscribe_id timestamps:nil] autorelease];
	[operation executeAction];
	
	NSMutableDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	[listOfRead setObject:subscribe_id forKey:subscribe_id];
	
	NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
	NSMutableDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
	sharedLDRTouchApp.userSettings.numberOfUnread -= [items count] - [listOfReadEachEntry count];
	
	[feedView.tableView reloadData];
}

- (IBAction)prevFeed:(id)sender {
	NSInteger index = [feedList indexOfObject:feed];
	if (index == 0) {
		return;
	}
	
	self.feed = [feedList objectAtIndex:index - 1];
	
	[self enableButtons];
	
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	[self loadEntries:subscribe_id];
	
	self.title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
}

- (IBAction)nextFeed:(id)sender {
	NSInteger index = [feedList indexOfObject:feed];
	if (index == [feedList count] - 1) {
		return;
	}
	
	self.feed = [feedList objectAtIndex:index + 1];
	
	[self enableButtons];
	
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	[self loadEntries:subscribe_id];
	
	self.title = [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
}

- (void)loadEntries:(NSString *)subscribe_id {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	[sharedLDRTouchApp saveUserSettings];
	
	NSDictionary *listofEntry = [CacheManager loadEntries:subscribe_id];
	if (listofEntry) {
		self.entries = listofEntry;
		self.items = [[entries objectForKey:@"items"] sortedArrayUsingFunction:compareEntriesByDate context:nil];
		[[self.feedView tableView] reloadData];
		return;
	}
	
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
	[conn post:[NSString stringWithFormat:@"%@%@%@", @"http://", userSettings.serviceURI, @"/api/unread"]
	parameters:[NSDictionary dictionaryWithObjectsAndKeys:
				subscribe_id, @"subscribe_id", 
				loginManager.api_key, @"ApiKey", nil]];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *listofEntry = [s JSONValue];
	[s release];
	if (!listofEntry) {
		return;
	}
	
	self.entries = listofEntry;
	self.items = [[entries objectForKey:@"items"] sortedArrayUsingFunction:compareEntriesByDate context:nil];
	[[self.feedView tableView] reloadData];
	
	[self reset];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self reset];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey {
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	[self loadEntries:subscribe_id];
	[sender setDelegate:nil];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
	[sender setDelegate:nil];
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString decodeXMLCharactersIn:[feed objectForKey:@"title"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.00;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"FeedCell";
	FeedCell *cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[FeedCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f) reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSDictionary *item = [items objectAtIndex:indexPath.row];
	NSString *title = [NSString decodeXMLCharactersIn:[item objectForKey:@"title"]];
	[cell.titleLabel setText:title];
	
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	NSString *entry_id = [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
	
	NSString *key = [NSString stringWithFormat:@"enties_%@", subscribe_id];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSMutableDictionary *listOfRead = [sharedLDRTouchApp.userSettings listOfRead];
	NSMutableDictionary *listOfReadEachEntry = [listOfRead objectForKey:key];
	if (![listOfRead objectForKey:subscribe_id] && ![listOfReadEachEntry objectForKey:entry_id]) {
		[cell.unreadMark setImage:unreadMark];
	} else {
		[cell.unreadMark setImage:nil];
	}
	
	return cell;
}

#pragma mark <UITableViewDelegate> Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!entries || [entries count] == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	
	EntryViewController *controller = [[EntryViewController alloc] init];
	controller.feedViewController = self;
	controller.feedList = feedList;
	controller.feed = feed;
	controller.items = items;
	NSDictionary *item = [items objectAtIndex:indexPath.row];
	controller.currentItem = item;
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	[sharedLDRTouchApp saveUserSettings];
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	feedView = [[FeedView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	[feedView.tableView setDelegate:self];
	[feedView.tableView setDataSource:self];
	[feedView.markAsReadButton setTarget:self];
	[feedView.markAsReadButton setAction:@selector(markAsRead)];
	[feedView.prevButton setTarget:self];
	[feedView.prevButton setAction:@selector(prevFeed:)];
	[feedView.nextButton setTarget:self];
	[feedView.nextButton setAction:@selector(nextFeed:)];
	[self setView:feedView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	[self loadEntries:subscribe_id];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Top" 
//																				style:UIBarButtonItemStyleBordered
//																			   target:self 
//																			   action:@selector(backToTop)] autorelease] animated:NO];
	[feedView.tableView deselectRowAtIndexPath:[feedView.tableView indexPathForSelectedRow] animated:YES];
	[feedView.tableView reloadData];
	[self enableButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	LOG_CURRENT_METHOD;
}

@end
