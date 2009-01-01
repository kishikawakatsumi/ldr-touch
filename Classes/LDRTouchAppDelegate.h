#import <UIKit/UIKit.h>
#import "SiteViewController.h"
#import "LoginManager.h"
#import "UserSettings.h"

@interface LDRTouchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	SiteViewController *sharedSiteViewController;
	
	UserSettings *userSettings;
	NSString *dataFilePath;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (retain, readonly) SiteViewController *sharedSiteViewController;

@property (nonatomic, retain) UserSettings *userSettings;
@property (nonatomic, retain) NSString *dataFilePath;

+ (LDRTouchAppDelegate *)sharedLDRTouchApp;
+ (LoginManager *)sharedLoginManager;
- (void)saveUserSettings;

@end
