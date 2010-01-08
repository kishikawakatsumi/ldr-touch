#import "UserSettings.h"
#import "Constants.h"

@implementation UserSettings

@synthesize version;
@synthesize userName;
@synthesize password;
@synthesize markAsReadAuto;
@synthesize sortOrder;
@synthesize viewMode;
@synthesize showBadgeFlag;
@synthesize useMobileProxy;
@synthesize shouldAutoRotation;
@synthesize serviceURI;

@synthesize listOfRead;
@synthesize numberOfUnread;
@synthesize unfinishedOperations;
@synthesize requestedOperations;

@synthesize lastModified;
@synthesize pinList;

- (id)init {
	if (self = [super init]) {
		version = CURRENT_VERSION;
		userName = [[NSString alloc] init];
		password = [[NSString alloc] init];
		markAsReadAuto = NO;
		sortOrder = UserSettingsSortOrderDate;
		viewMode = UserSettingsViewModeFlat;
		showBadgeFlag = NO;
		useMobileProxy = NO;
		shouldAutoRotation = YES;
		serviceURI = SERVICE_URI_DEFAULT;
		
		listOfRead = [[NSMutableDictionary alloc] init];
		numberOfUnread = 0;
		unfinishedOperations = [[NSMutableDictionary alloc] init];
		requestedOperations = [[NSMutableDictionary alloc] init];
		
		lastModified = nil;
		pinList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	version = [coder decodeIntForKey:@"version"];
	userName = [[coder decodeObjectForKey:@"userName"] retain];
	password = [[coder decodeObjectForKey:@"password"] retain];
	markAsReadAuto = [coder decodeBoolForKey:@"markAsReadAuto"];
	sortOrder = [coder decodeIntForKey:@"sortOrder"];
	viewMode = [coder decodeIntForKey:@"viewMode"];
	showBadgeFlag = [coder decodeBoolForKey:@"showBadgeFlag"];
	useMobileProxy = [coder decodeBoolForKey:@"useMobileProxy"];
	shouldAutoRotation = [coder decodeBoolForKey:@"shouldAutoRotation"];
	serviceURI = [[coder decodeObjectForKey:@"serviceURI"] retain];
	
	listOfRead = [[coder decodeObjectForKey:@"listOfRead"] retain];
	numberOfUnread = [coder decodeIntForKey:@"numberOfUnread"];
	unfinishedOperations = [[coder decodeObjectForKey:@"unfinishedOperations"] retain];
	requestedOperations = [[NSMutableDictionary alloc] init];
	
	lastModified = [[coder decodeObjectForKey:@"lastModified"] retain];
	pinList = [[coder decodeObjectForKey:@"pinList"] retain];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInt:version forKey:@"version"];
	[encoder encodeObject:userName forKey:@"userName"];
	[encoder encodeObject:password forKey:@"password"];
	[encoder encodeBool:markAsReadAuto forKey:@"markAsReadAuto"];
	[encoder encodeInt:sortOrder forKey:@"sortOrder"];
	[encoder encodeInt:viewMode forKey:@"viewMode"];
	[encoder encodeBool:showBadgeFlag forKey:@"showBadgeFlag"];
	[encoder encodeBool:useMobileProxy forKey:@"useMobileProxy"];
	[encoder encodeBool:shouldAutoRotation forKey:@"shouldAutoRotation"];
	[encoder encodeObject:serviceURI forKey:@"serviceURI"];
	
	[encoder encodeObject:listOfRead forKey:@"listOfRead"];
	[encoder encodeInt:numberOfUnread forKey:@"numberOfUnread"];
	[encoder encodeObject:unfinishedOperations forKey:@"unfinishedOperations"];
	
	[encoder encodeObject:lastModified forKey:@"lastModified"];
	[encoder encodeObject:pinList forKey:@"pinList"];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[pinList release];
	[lastModified release];
	[requestedOperations release];
	[unfinishedOperations release];
	[listOfRead release];
	[serviceURI release];
	[userName release];
	[password release];
	[super dealloc];
}

- (void)setPinList:(NSMutableArray *)list {
	[pinList removeAllObjects];
	for (NSDictionary *pin in list) {
		[pinList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[pin objectForKey:@"link"], @"link", [pin objectForKey:@"title"], @"title", nil]];
	}
}

- (NSString *)serviceURI {
    NSString *normalized = serviceURI;
    if ([normalized hasSuffix:@"/"]) {
        normalized = [normalized substringToIndex:[normalized length] - 1];
    }
    if (![normalized hasPrefix:@"http://"] && ![normalized hasPrefix:@"https://"]) {
        normalized = [NSString stringWithFormat:@"http://%@", normalized];
    } 
    return normalized;
}

- (NSString *)serviceHostName {
    NSString *hostName = serviceURI;
    if ([hostName hasSuffix:@"/"]) {
        hostName = [hostName substringToIndex:[hostName length] - 1];
    }
    if ([hostName hasPrefix:@"https://"]) {
        hostName = [hostName substringFromIndex:8];
    } else if ([hostName hasPrefix:@"http://"]) {
        hostName = [hostName substringFromIndex:7];
    }
    LOG(@"%@", hostName);
    return hostName;
}

@end
