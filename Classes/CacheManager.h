#import <UIKit/UIKit.h>

@interface CacheManager : NSObject {

}

+ (NSArray *)loadFeedList;
+ (void)saveFeedList:(NSArray *)listOfFeed;
+ (BOOL)saveEntries:(NSDictionary *)listOfEntry;
+ (NSDictionary *)loadEntries:(NSString *)subscribe_id;
+ (BOOL)containsEntriesOf:(NSString *)subscribe_id;

@end
