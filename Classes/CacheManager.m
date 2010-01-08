#import "CacheManager.h"
#import "LDRTouchAppDelegate.h"
#import "RootViewController.h"

@implementation CacheManager

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[super dealloc];
}

+ (NSString *)documentDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return documentDirectory;
}

+ (NSString *)cacheDirectory {
	NSString *cacheDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"cache"];
	return cacheDirectory;
}

+ (NSString *)entriesDirectory {
	NSString *cacheDirectory = [self cacheDirectory];
	NSString *pathToTextFile = [cacheDirectory stringByAppendingPathComponent:@"path.txt"];
	NSString *directoryName = [NSString stringWithContentsOfFile:pathToTextFile encoding:NSUTF8StringEncoding error:nil];
	NSString *entriesDirectoryPath = [cacheDirectory stringByAppendingPathComponent:directoryName];
	return entriesDirectoryPath;
}

+ (BOOL)containsEntriesOf:(NSString *)subscribe_id {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *cacheDirectory = [CacheManager cacheDirectory];
	if (![fileManager fileExistsAtPath:cacheDirectory]) {
		return NO;
	}
	
	NSString *entriesDirectoryPath = [CacheManager entriesDirectory];
	if (![fileManager fileExistsAtPath:entriesDirectoryPath]) {
		return NO;
	}
	
	NSString *dataPath = [entriesDirectoryPath stringByAppendingPathComponent:[subscribe_id stringByAppendingPathExtension:@"dat"]];
	if ([fileManager fileExistsAtPath:dataPath]) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark Load Methods

+ (NSArray *)loadFeedList {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *cacheDirectory = [CacheManager cacheDirectory];
	if (![fileManager fileExistsAtPath:cacheDirectory]) {
		return nil;
	}
	
	NSString *path = [cacheDirectory stringByAppendingPathComponent:@"FeedList.dat"];
	
	if ([fileManager fileExistsAtPath:path]) {
		NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		
		NSArray *listOfFeed = [decoder decodeObjectForKey:@"feedList"];
		
		[decoder finishDecoding];
		[decoder release];
		
		return listOfFeed;
	}
	return nil;
}

+ (NSDictionary *)loadEntries:(NSString *)subscribe_id {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *cacheDirectory = [CacheManager cacheDirectory];
	if (![fileManager fileExistsAtPath:cacheDirectory]) {
		return nil;
	}
	
	NSString *entriesDirectoryPath = [CacheManager entriesDirectory];
	if (![fileManager fileExistsAtPath:entriesDirectoryPath]) {
		return nil;
	}
	
	NSString *entryFileName = [subscribe_id stringByAppendingPathExtension:@"dat"];
	NSString *entryFilePath = [entriesDirectoryPath stringByAppendingPathComponent:entryFileName];
	
	if ([fileManager fileExistsAtPath:entryFilePath]) {
		NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:entryFilePath];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		
		NSDictionary *listOfEntry = [decoder decodeObjectForKey:@"entries"];
		
		[decoder finishDecoding];
		[decoder release];
		
		return listOfEntry;
	}
	return nil;
}

#pragma mark Save Methods

+ (void)saveFeedList:(NSArray *)listOfFeed {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *cacheDirectory = [CacheManager cacheDirectory];
	if ([fileManager fileExistsAtPath:cacheDirectory]) {
		if (![fileManager removeItemAtPath:cacheDirectory error:nil]) {
			return;
		}
	}
	if (![fileManager createDirectoryAtPath:cacheDirectory attributes:nil]) {
		return;
	}
	
	srand(time(nil));
	NSString *entriesDirectory = [NSString stringWithFormat:@"%d%d", time(nil), rand()];
	NSString *entriesDirectoryPath = [cacheDirectory stringByAppendingPathComponent:entriesDirectory];
	if (![fileManager createDirectoryAtPath:entriesDirectoryPath attributes:nil]) {
		return;
	}
	
	NSString *newPathTextFile = [cacheDirectory stringByAppendingPathComponent:@"path.txt"];
	if (![entriesDirectory writeToFile:newPathTextFile atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
		return;
	}
	
	NSString *dataPath = [cacheDirectory stringByAppendingPathComponent:@"FeedList.dat"];
	NSMutableData *theData = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:listOfFeed forKey:@"feedList"];
	[encoder finishEncoding];
	
	[theData writeToFile:dataPath atomically:YES];
	
	[encoder release];
}

+ (BOOL)saveEntries:(NSDictionary *)listOfEntry {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *cacheDirectory = [CacheManager cacheDirectory];
	if (![fileManager fileExistsAtPath:cacheDirectory]) {
		return NO;
	}
	
	NSString *entriesDirectoryPath = [CacheManager entriesDirectory];
	if (![fileManager fileExistsAtPath:entriesDirectoryPath]) {
		return NO;
	}
	
	NSString *subscribe_id = [listOfEntry objectForKey:@"subscribe_id"];
	NSString *entryFilePath = [entriesDirectoryPath stringByAppendingPathComponent:[subscribe_id stringByAppendingPathExtension:@"dat"]];
	if ([fileManager fileExistsAtPath:entryFilePath]) {
		return NO;
	}
	
	NSMutableData *theData = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:listOfEntry forKey:@"entries"];
	[encoder finishEncoding];
	
	[theData writeToFile:entryFilePath atomically:YES];
	[encoder release];
	
	return YES;
}

@end
