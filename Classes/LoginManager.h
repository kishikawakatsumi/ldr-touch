#import <UIKit/UIKit.h>
#import "HttpClient.h"
#import "Reachability.h"

@interface LoginManager : NSObject {
	NSString *api_key;
	HttpClient *conn;
	id delegate;
	
	NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;
	
	NSLock *lock;
}

@property (nonatomic, retain) NSString *api_key;
@property (nonatomic, retain) id delegate;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

- (void)login;
- (void)invalidate;
- (void)updateStatus;

@end
