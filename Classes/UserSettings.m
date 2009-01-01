#import "UserSettings.h"
#import "Debug.h"

@implementation UserSettings

@synthesize version;
@synthesize userName;
@synthesize password;
@synthesize markAsReadAuto;
@synthesize sortOrder;
@synthesize viewMode;
@synthesize listOfRead;
@synthesize unfinishedOperations;
@synthesize requestedOperations;
@synthesize numberOfUnread;
@synthesize showBadgeFlag;
@synthesize useMobileProxy;
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
		listOfRead = [[NSMutableDictionary alloc] init];
		unfinishedOperations = [[NSMutableDictionary alloc] init];
		requestedOperations = [[NSMutableDictionary alloc] init];
		numberOfUnread = 0;
		showBadgeFlag = NO;
		useMobileProxy = NO;
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
	listOfRead = [[coder decodeObjectForKey:@"listOfRead"] retain];
	unfinishedOperations = [[coder decodeObjectForKey:@"unfinishedOperations"] retain];
	requestedOperations = [[NSMutableDictionary alloc] init];
	numberOfUnread = [coder decodeIntForKey:@"numberOfUnread"];
	showBadgeFlag = [coder decodeBoolForKey:@"showBadgeFlag"];
	useMobileProxy = [coder decodeBoolForKey:@"useMobileProxy"];
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
	[encoder encodeObject:listOfRead forKey:@"listOfRead"];
	[encoder encodeObject:unfinishedOperations forKey:@"unfinishedOperations"];
	[encoder encodeInt:numberOfUnread forKey:@"numberOfUnread"];
	[encoder encodeBool:showBadgeFlag forKey:@"showBadgeFlag"];
	[encoder encodeBool:useMobileProxy forKey:@"useMobileProxy"];
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

@end
