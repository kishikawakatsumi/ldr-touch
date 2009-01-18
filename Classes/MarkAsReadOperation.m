#import "MarkAsReadOperation.h"
#import "LDRTouchAppDelegate.h"

@implementation MarkAsReadOperation

@synthesize subscribe_id;
@synthesize timestamps;

- (id)init {
	if (self = [super init]) {
		subscribe_id = [[NSString alloc] init];
		timestamps = [[NSString alloc] init];
	}
	return self;
}

- (id)initWithSubscribeID:(NSString *)theSubscribeID timestamps:(NSArray *)ts {
	if (self = [super init]) {
		self.subscribe_id = theSubscribeID;
		self.timestamps = ts;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	subscribe_id = [[coder decodeObjectForKey:@"subscribe_id"] retain];
	timestamps = [[coder decodeObjectForKey:@"timestamps"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:subscribe_id forKey:@"subscribe_id"];
	[encoder encodeObject:timestamps forKey:@"timestamps"];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[conn release];
	[timestamps release];
	[subscribe_id release];
	[super dealloc];
}

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (void)failed {
	LOG_CURRENT_METHOD;
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSMutableDictionary *unfinishedOperations = [sharedLDRTouchApp.userSettings unfinishedOperations];
	[unfinishedOperations setObject:self forKey:subscribe_id];
}

- (void)markAsRead {
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (!loginManager.api_key) {
		[loginManager setDelegate:self];
		[loginManager login];
		return;
	}
	
	[self reset];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	conn = [[HttpClient alloc] initWithDelegate:self];
	NSString *apiURI;
	NSDictionary *params;
	if (timestamps) {
		apiURI = [NSString stringWithFormat:@"%@%@%@", @"http://", userSettings.serviceURI, @"/api/touch"];
		params = [NSDictionary dictionaryWithObjectsAndKeys:
				  subscribe_id, @"subscribe_id",
				  [timestamps componentsJoinedByString:@","], @"timestamp",
				  loginManager.api_key, @"ApiKey", nil];
	} else {
		apiURI = [NSString stringWithFormat:@"%@%@%@", @"http://", userSettings.serviceURI, @"/api/touch_all"];
		params = [NSDictionary dictionaryWithObjectsAndKeys:subscribe_id, @"subscribe_id", loginManager.api_key, @"ApiKey", nil];
	}
	
	[conn post:apiURI parameters:params];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	LOG(@"mark as read: %@, status = %d", subscribe_id, [response statusCode]);
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSMutableDictionary *requestedOperations = [sharedLDRTouchApp.userSettings requestedOperations];
	[requestedOperations setObject:subscribe_id forKey:subscribe_id];
	NSMutableDictionary *unfinishedOperations = [sharedLDRTouchApp.userSettings unfinishedOperations];
	[unfinishedOperations removeObjectForKey:subscribe_id];
	
	[self reset];
	[self release];
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self failed];
	[self reset];
	[self release];
}

- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey {
	[sender setDelegate:nil];
	[self markAsRead];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
	[sender setDelegate:nil];
	[self failed];
}

- (void)executeAction {
	[[self retain] markAsRead];
}

@end
