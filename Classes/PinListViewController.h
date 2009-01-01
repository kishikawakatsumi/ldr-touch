#import <UIKit/UIKit.h>
#import "HttpClient.h"

@interface PinListViewController : UIViewController {
	IBOutlet UITableView *pinListView;
	HttpClient *conn;
	NSMutableArray *pinList;
}

@property (nonatomic, retain) UITableView *pinListView;
@property (retain) NSMutableArray *pinList;

- (IBAction)hidePinList;

@end
