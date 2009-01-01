#import <UIKit/UIKit.h>
#import "Operation.h"
#import "HttpClient.h"

@interface MarkAsReadOperation : NSObject <Operation> {
	NSString *subscribe_id;
	NSArray *timestamps;
	HttpClient *conn;
}

@property (nonatomic, retain) NSString *subscribe_id;
@property (nonatomic, retain) NSArray *timestamps;

- (id)initWithSubscribeID:(NSString *)theSubscribeID timestamps:(NSArray *)ts;

@end
