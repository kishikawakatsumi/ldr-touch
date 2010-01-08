#import "AddPinOperation.h"
#import "LDRTouchAppDelegate.h"


@implementation AddPinOperation

@synthesize link;
@synthesize title;

- (id)init {
	if (self = [super init]) {
		link = [[NSString alloc] init];
		title = [[NSString alloc] init];
	}
	return self;
}

- (id)initWithLink:(NSString *)aLink title:aTitle {
	if (self = [super init]) {
		self.link = aLink;
		self.title = aTitle;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	link = [[coder decodeObjectForKey:@"link"] retain];
	title = [[coder decodeObjectForKey:@"title"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:link forKey:@"link"];
	[encoder encodeObject:title forKey:@"title"];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[conn release];
	[link release];
	[title release];
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
	[unfinishedOperations setObject:self forKey:link];
}

- (void)addPin {
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
	[conn post:[NSString stringWithFormat:@"%@%@", userSettings.serviceURI, @"/api/pin/add"]
	parameters:[NSDictionary dictionaryWithObjectsAndKeys:
				link, @"link",
				title, @"title",
				loginManager.api_key, @"ApiKey", nil]];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	LOG(@"add pin: %@ <%@>, status = %d", title, link, [response statusCode]);
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	NSMutableDictionary *unfinishedOperations = [sharedLDRTouchApp.userSettings unfinishedOperations];
	[unfinishedOperations removeObjectForKey:link];
	
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
	[self addPin];
}

- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error {
	[sender setDelegate:nil];
	[self failed];
}

- (void)executeAction {
	[[self retain] addPin];
}

@end
