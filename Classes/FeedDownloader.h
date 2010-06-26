#import <UIKit/UIKit.h>
#import "HttpClient.h"

@interface FeedDownloader : NSObject {
	HttpClient *conn;
	NSArray *feedList;
	NSInteger numberOfFeeds;
	NSInteger counter;
	id delegate;
}

@property (nonatomic, retain) NSArray *feedList;
@property (nonatomic, assign) id delegate;

- (id)initWithFeedList:(NSArray *)aFeedList;
- (void)start;
- (void)cancel;

@end
