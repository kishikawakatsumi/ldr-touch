#import <UIKit/UIKit.h>
#import "Operation.h"
#import "HttpClient.h"

@interface AddPinOperation : NSObject <Operation> {
	NSString *link;
	NSString *title;
	HttpClient *conn;
}

@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *title;

- (id)initWithLink:(NSString *)aLink title:aTitle;

@end
