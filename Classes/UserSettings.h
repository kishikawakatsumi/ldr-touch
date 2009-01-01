#import <UIKit/UIKit.h>

#define CURRENT_VERSION 122

typedef enum {
    UserSettingsSortOrderDate = 0,
    UserSettingsSortOrderNumberOfUnread = 1,
    UserSettingsSortOrderNumberOfSubscribers = 2,
    UserSettingsSortOrderTitle = 3,
    UserSettingsSortOrderRate = 4,
    UserSettingsSortOrderDateAsc = 5,
    UserSettingsSortOrderNumberOfUnreadAsc = 6,
    UserSettingsSortOrderNumberOfSubscribersAsc = 7,
} UserSettingsSortOrder;

typedef enum {
    UserSettingsViewModeFlat = 0,
    UserSettingsViewModeFolder = 1,
    UserSettingsViewModeRate = 2,
    UserSettingsViewModeSubscribers = 3,
} UserSettingsViewMode;

@interface UserSettings : NSObject <NSCoding> {
	NSInteger version;
	NSString *userName;
	NSString *password;
	BOOL markAsReadAuto;
	UserSettingsSortOrder sortOrder;
	UserSettingsViewMode viewMode;
	NSMutableDictionary *listOfRead;
	NSMutableDictionary *unfinishedOperations;
	NSMutableDictionary *requestedOperations;
	NSInteger numberOfUnread;
	BOOL showBadgeFlag;
	BOOL useMobileProxy;
	NSDate *lastModified;
	NSMutableArray *pinList;
}

@property (nonatomic) NSInteger version;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) BOOL markAsReadAuto;
@property (nonatomic) UserSettingsSortOrder sortOrder;
@property (nonatomic) UserSettingsViewMode viewMode;
@property (nonatomic, retain) NSMutableDictionary *listOfRead;
@property (nonatomic, retain) NSMutableDictionary *unfinishedOperations;
@property (nonatomic, retain) NSMutableDictionary *requestedOperations;
@property (nonatomic) NSInteger numberOfUnread;
@property (nonatomic) BOOL showBadgeFlag;
@property (nonatomic) BOOL useMobileProxy;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain, setter=setPinList:) NSMutableArray *pinList;

@end
