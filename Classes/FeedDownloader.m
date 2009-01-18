#import "FeedDownloader.h"
#import "LDRTouchAppDelegate.h"
#import "LoginManager.h"
#import "CacheManager.h"
#import "JSON.h"
#import "Debug.h"

@interface NSObject (FeedDownloaderDelegate)
- (void)feedDownloaderDidEntryDownloadSucceeded:(FeedDownloader *)sender;
- (void)feedDownloaderDidEntryDownloadFailed:(FeedDownloader *)sender error:(NSError *)error;
- (void)feedDownloaderSucceeded:(FeedDownloader *)sender;
- (void)feedDownloaderCanceled:(FeedDownloader *)sender;
- (void)feedDownloaderFailed:(FeedDownloader *)sender error:(NSError *)error;
@end

@implementation FeedDownloader

@synthesize feedList;
@synthesize delegate;

- (id)init {
	if (self = [super init]) {
		conn = nil;
		self.feedList = nil;
	}
	return self;
}

- (id)initWithFeedList:(NSArray *)aFeedList {
	if (self = [self init]) {
		self.feedList = aFeedList;
		numberOfFeeds = [feedList count];
		counter = 0;
	}
	return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[delegate release];
	[feedList release];
	[conn release];
    [super dealloc];
}

- (void)reset {
	[conn setDelegate:nil];
	[conn release];
	conn = nil;
}

- (void)cancel {
	[conn cancel];
	[self reset];
	if ([delegate respondsToSelector:@selector(feedDownloaderCanceled:)]) {
		[delegate feedDownloaderCanceled:self];
	}
}

- (void)start {
	if ([feedList count] <= counter) {
		if ([delegate respondsToSelector:@selector(feedDownloaderSucceeded:)]) {
			[delegate feedDownloaderSucceeded:self];
		}
		return;
	}
	
	NSDictionary *feed = [feedList objectAtIndex:counter];
	NSString *subscribe_id = [NSString stringWithFormat:@"%@", [feed objectForKey:@"subscribe_id"]];
	
	[self reset];
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	conn = [[HttpClient alloc] initWithDelegate:self];
	[conn post:[NSString stringWithFormat:@"%@%@%@", @"http://", userSettings.serviceURI, @"/api/unread"]
	parameters:[NSDictionary dictionaryWithObjectsAndKeys:
				subscribe_id, @"subscribe_id", 
				loginManager.api_key, @"ApiKey", nil]];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *entries = [s JSONValue];
	[s release];
	
	[CacheManager saveEntries:entries];
	counter++;
	if ([delegate respondsToSelector:@selector(feedDownloaderDidEntryDownloadSucceeded:)]) {
		[delegate feedDownloaderDidEntryDownloadSucceeded:self];
	}
	
	[self reset];
	
	[self start];
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error {
	[self reset];
	if ([delegate respondsToSelector:@selector(feedDownloaderFailed:error:)]) {
		[delegate feedDownloaderFailed:self error:error];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
