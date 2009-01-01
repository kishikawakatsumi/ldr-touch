#import <UIKit/UIKit.h>
#import "UserSettings.h"


@interface UserSettingSheetController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate> {
	IBOutlet UITableView *userSettingSheet;
	UserSettingsSortOrder sortOrder;
	UserSettingsViewMode viewMode;
	NSMutableDictionary *cells;
}

@property (nonatomic, retain) UITableView *userSettingSheet;

- (IBAction)hideView:(id)sender;
	
@end
