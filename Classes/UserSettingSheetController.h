#import <UIKit/UIKit.h>
#import "UserSettings.h"


@interface UserSettingSheetController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate> {
	UITableView *userSettingSheet;
	UserSettingsSortOrder sortOrder;
	UserSettingsViewMode viewMode;
	NSMutableDictionary *cells;
	UITextField *nameField;
	UITextField *passwordField;
}
	
@end
