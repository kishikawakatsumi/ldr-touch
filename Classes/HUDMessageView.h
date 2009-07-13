#import <UIKit/UIKit.h>

@interface HUDMessageView : UIView {
	NSString *message;
}

- (id)initWithMessage:(NSString*)message;
- (void)showInView:(UIView*)view;
- (void)dismiss;

@end
