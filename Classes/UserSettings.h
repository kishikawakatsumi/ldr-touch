#import <UIKit/UIKit.h>

#define CURRENT_VERSION 124

typedef enum {
    UserSettingsSortOrderDate,
    UserSettingsSortOrderNumberOfUnread,
    UserSettingsSortOrderNumberOfSubscribers,
    UserSettingsSortOrderTitle,
    UserSettingsSortOrderRate,
    UserSettingsSortOrderDateAsc,
    UserSettingsSortOrderNumberOfUnreadAsc,
    UserSettingsSortOrderNumberOfSubscribersAsc,
} UserSettingsSortOrder;

typedef enum {
    UserSettingsViewModeFlat,
    UserSettingsViewModeFolder,
    UserSettingsViewModeRate,
    UserSettingsViewModeSubscribers,
} UserSettingsViewMode;

@interface UserSettings : NSObject <NSCoding> {
	NSInteger version;
	NSString *userName;
	NSString *password;
	BOOL markAsReadAuto;
	UserSettingsSortOrder sortOrder;
	UserSettingsViewMode viewMode;
	BOOL showBadgeFlag;
	BOOL useMobileProxy;
	BOOL shouldAutoRotation;
	NSString *serviceURI;
	
	NSMutableDictionary *listOfRead;
	NSInteger numberOfUnread;
	NSMutableDictionary *unfinishedOperations;
	NSMutableDictionary *requestedOperations;
	
	NSDate *lastModified;
	NSMutableArray *pinList;
}

- (NSString *)serviceHostName;

@property (nonatomic) NSInteger version;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) BOOL markAsReadAuto;
@property (nonatomic) UserSettingsSortOrder sortOrder;
@property (nonatomic) UserSettingsViewMode viewMode;
@property (nonatomic) BOOL showBadgeFlag;
@property (nonatomic) BOOL useMobileProxy;
@property (nonatomic) BOOL shouldAutoRotation;
@property (nonatomic, retain) NSString *serviceURI;

@property (nonatomic, retain) NSMutableDictionary *listOfRead;
@property (nonatomic) NSInteger numberOfUnread;
@property (nonatomic, retain) NSMutableDictionary *unfinishedOperations;
@property (nonatomic, retain) NSMutableDictionary *requestedOperations;

@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain, setter=setPinList:) NSMutableArray *pinList;

@end
