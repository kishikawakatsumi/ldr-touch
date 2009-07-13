#import <UIKit/UIKit.h>
#import "HttpClient.h"

@interface PinListViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource> {
	UITableView *pinListView;
	HttpClient *conn;
	NSMutableArray *pinList;
}

@property (retain) NSMutableArray *pinList;

@end
