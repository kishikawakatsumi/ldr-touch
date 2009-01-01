#import <UIKit/UIKit.h>

@interface InformationSheetController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *infoSheet;
	IBOutlet UINavigationBar *toolBar;
	IBOutlet UIBarButtonItem *hideButton;
	IBOutlet UIBarButtonItem *userCount;
	NSString *pageURL;
	NSDictionary *pageInfo;
	NSArray *bookmarks;
}

@property (nonatomic, retain) UITableView *infoSheet;
@property (nonatomic, retain) UINavigationBar *toolBar;
@property (nonatomic, retain) UIBarButtonItem *hideButton;
@property (nonatomic, retain) UIBarButtonItem *userCount;
@property (nonatomic, retain) NSString *pageURL;
@property (nonatomic, retain) NSDictionary *pageInfo;
@property (nonatomic, retain) NSArray *bookmarks;

- (IBAction)hideInfoSheet:(id)sender;

@end
