#import <UIKit/UIKit.h>
#import "HttpClient.h"
#import "FeedDownloader.h"

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *feedListView;
	UIToolbar *toolbar;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *pinListButton;
	UILabel *modifiedDateLabel;
	UILabel *modifiedTimeLabel;
	
	HttpClient *conn;
	FeedDownloader *downloader;
	
	NSArray *feedList;
	NSMutableDictionary *organizedFeedList;
	NSArray *sectionHeaders;
}

@property (nonatomic, retain) UITableView *feedListView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *pinListButton;
@property (nonatomic, retain) UILabel *modifiedDateLabel;
@property (nonatomic, retain) UILabel *modifiedTimeLabel;

@property (retain) NSArray *feedList;
@property (retain) NSMutableDictionary *organizedFeedList;
@property (retain) NSArray *sectionHeaders;

- (IBAction)refreshData;
- (void)refreshDataIfNeeded;
- (IBAction)showSettingView:(id)sender;
- (IBAction)showPinList:(id)sender;

@end
