#import "LDRTouchAppDelegate.h"
#import "RootViewController.h"
#import "Operation.h"
#import "Debug.h"

@implementation LDRTouchAppDelegate

static LoginManager *loginManager = NULL;

@synthesize window;
@synthesize navigationController;

@synthesize sharedSiteViewController;

@synthesize userSettings;
@synthesize dataFilePath;

+ (LDRTouchAppDelegate *)sharedLDRTouchApp {
	return [[UIApplication sharedApplication] delegate];
}

+ (LoginManager *)sharedLoginManager {
	if (!loginManager) {
		loginManager = [[LoginManager alloc] init];
	}
	
	return loginManager;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[dataFilePath release];
	[userSettings release];
	
	[loginManager release];
	
	[sharedSiteViewController release];
	
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)executeUnfinishedOperations {
	LOG_CURRENT_METHOD;
	NSDictionary *unfinishedOperations = userSettings.unfinishedOperations;
	if ([unfinishedOperations count] == 0) {
		return;
	}
		
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (!loginManager.api_key) {
		[loginManager setDelegate:self];
		[loginManager login];
		return;
	}
	
	for (id key in [unfinishedOperations allKeys]) {
		id <Operation> operation = [unfinishedOperations objectForKey:key];
		[operation executeAction];
	}
}

- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey {
	[sender setDelegate:nil];
	[self executeUnfinishedOperations];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
	[sender setDelegate:nil];
}

- (void)reachabilityChanged:(NSNotification *)note {
	LOG_CURRENT_METHOD;
	[loginManager updateStatus];
	if (loginManager.remoteHostStatus == NotReachable) {
		[[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackOpaque];
	} else {
		[[[self navigationController] navigationBar] setBarStyle:UIBarStyleDefault];
		[self executeUnfinishedOperations];
	}
}

- (void)saveUserSettings {
	LOG_CURRENT_METHOD;
	NSMutableData *theData = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:userSettings forKey:@"userSettings"];
	[encoder finishEncoding];
	
	[theData writeToFile:dataFilePath atomically:YES];
	[encoder release];
	
	if (userSettings.showBadgeFlag) {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:userSettings.numberOfUnread];
	} else {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	}
}

- (void)loadUserSettings {
	LOG_CURRENT_METHOD;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *path = [documentDirectory stringByAppendingPathComponent:@"UserSettings.dat"];
	self.dataFilePath = path;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		
		self.userSettings = [decoder decodeObjectForKey:@"userSettings"];
		
		[decoder finishDecoding];
		[decoder release];
		
		if (userSettings.version != CURRENT_VERSION) {
			LOG(@"migrate settings.");
			UserSettings *newSettings = [[UserSettings alloc] init];
			newSettings.version = CURRENT_VERSION;
			newSettings.userName = userSettings.userName;
			newSettings.password = userSettings.password;
			newSettings.markAsReadAuto = userSettings.markAsReadAuto;
			newSettings.sortOrder = userSettings.sortOrder;
			newSettings.viewMode = userSettings.viewMode;
			newSettings.listOfRead = userSettings.listOfRead;
			newSettings.unfinishedOperations = userSettings.unfinishedOperations;
			newSettings.requestedOperations = userSettings.requestedOperations;
			newSettings.numberOfUnread = userSettings.numberOfUnread;
			newSettings.showBadgeFlag = userSettings.showBadgeFlag;
			newSettings.useMobileProxy = userSettings.useMobileProxy;
			newSettings.lastModified = userSettings.lastModified;
			newSettings.pinList = userSettings.pinList;
			newSettings.shouldAutoRotation = userSettings.shouldAutoRotation;
			//newSettings.serviceURI = userSettings.serviceURI;
			self.userSettings = newSettings;
		}
	} else {
		self.userSettings = [[UserSettings alloc] init];
	}	
}

#pragma mark <UIApplicationDelegate> Methods

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	LOG_CURRENT_METHOD;
	
	[self loadUserSettings];
	
	[[Reachability sharedReachability] setHostName:userSettings.serviceURI];
	[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
												 name:@"kNetworkReachabilityChangedNotification" object:nil];
	
	loginManager = [LDRTouchAppDelegate sharedLoginManager];
	[loginManager updateStatus];
	
	sharedSiteViewController = [[SiteViewController alloc] initWithNibName:@"SiteView" bundle:nil];
	sharedSiteViewController.view.autoresizesSubviews = YES;
	sharedSiteViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//	[sharedSiteViewController.webView _setCheckeredPatternEnabled:YES];
//	[sharedSiteViewController.webView _setTileDrawingEnabled:YES];
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	LOG_CURRENT_METHOD;
	[self saveUserSettings];
}

@end
