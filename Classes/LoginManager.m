#import "LoginManager.h"
#import "LDRTouchAppDelegate.h"
#import "Constants.h"

@interface NSObject (LoginManagerDelegate)
- (void)loginManagerSucceeded:(LoginManager *)sender apiKey:(NSString *)apiKey;
- (void)loginManagerFailed:(LoginManager *)sender error:(NSError *)error;
@end

@implementation LoginManager

@synthesize api_key;
@synthesize delegate;

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;
@synthesize localWiFiConnectionStatus;

- (id)init {
	if (self = [super init]) {
		api_key = nil;
		lock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[delegate release];
	[conn release];
	[api_key release];
	[super dealloc];
}

- (void)invalidate {
	self.api_key = nil;
}

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (void)failed:(NSError *)error {
	LOG(@"login failed.");
	if ([delegate respondsToSelector:@selector(loginManagerFailed:error:)]) {
		[delegate loginManagerFailed:self error:error];
	}
}

- (void)login {
	if (![lock tryLock]) {
		return;
	}
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	NSString *userName = userSettings.userName;
	NSString *password = userSettings.password;
	
	LOG(@"user name: %@, password: %@", userName, password);
	
	if ([userName length] == 0 || [password length] == 0) {
        [self failed:nil];
        [lock unlock];
		return;
	}
	
	NSHTTPCookieStorage *cookieStotage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[cookieStotage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]; 
	NSArray *cookies = [cookieStotage cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userSettings.serviceURI]]];
	
	for (NSHTTPCookie *cookie in cookies) {
		[cookieStotage deleteCookie:cookie];
	}
	
	[self reset];
	
	conn = [[HttpClient alloc] initWithDelegate:self];
    NSString *serviceURI = userSettings.serviceURI;
    LOG(@"%@", serviceURI);
	if ([serviceURI rangeOfString:SERVICE_URI_LIVEDOOR options:NSCaseInsensitiveSearch].location != NSNotFound) {
		[conn post:@"https://member.livedoor.com/login/index" parameters:[NSDictionary dictionaryWithObjectsAndKeys:
																	@"http://reader.livedoor.com/reader/", @".next",
																	@"reader", @".sv",
																	userName, @"livedoor_id",
																	password, @"password", nil]];
	} else if ([serviceURI rangeOfString:SERVICE_URI_FASTLADDER options:NSCaseInsensitiveSearch].location != NSNotFound) {
		[conn post:@"http://fastladder.com/login" parameters:[NSDictionary dictionaryWithObjectsAndKeys:
															  @"Sign+in", @"commit",
															  userName, @"username",
															  password, @"password", nil]];
	} else {
        [conn post:@"%@/login" parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"Sign+in", @"commit",
                                           userName, @"username",
                                           password, @"password", nil]];
	}
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	NSHTTPCookieStorage *cookieStotage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStotage cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userSettings.serviceURI]]];
	
	for (NSHTTPCookie *cookie in cookies) {
		if ([cookie.name isEqualToString:@"reader_sid"]) {
			self.api_key = cookie.value;
			LOG(@"login: %@", api_key);
			if ([delegate respondsToSelector:@selector(loginManagerSucceeded:apiKey:)]) {
				[delegate loginManagerSucceeded:self apiKey:api_key];
			}
			break;
		}
	}
	
	if (!api_key) {
		[self failed:nil];
	}
	
	[self reset];
	
	[lock unlock];
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self failed:error];
	[self reset];
	
	[lock unlock];
}

- (void)updateStatus {
	self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
//	self.internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
//	self.localWiFiConnectionStatus = [[Reachability sharedReachability] localWiFiConnectionStatus];
}

@end
