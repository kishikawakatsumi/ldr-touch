#import <UIKit/UIKit.h>
#import "FeedView.h"
#import "HttpClient.h"

@interface FeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet FeedView *feedView;
	HttpClient *conn;
	NSArray *feedList;
	NSDictionary *feed;
	NSDictionary *entries;
	NSArray *items;
}

@property (nonatomic, retain) FeedView *feedView;
@property (retain) NSArray *feedList;
@property (retain) NSDictionary *feed;
@property (retain) NSDictionary *entries;
@property (retain) NSArray *items;

- (IBAction)markAsRead;
- (IBAction)prevFeed:(id)sender;
- (IBAction)nextFeed:(id)sender;

@end
