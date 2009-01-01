#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define	DEFAULT_HUD_HEIGHT					40

#define	DEFAULT_MESSAGE_WIDTH				220
#define	DEFAULT_MESSAGE_HEIGHT				40
#define	DEFAULT_MESSAGE_HORIZONTAL_MARGIN	30

#define	DEFAULT_MESSAGE_BOTTOM_MARGIN		20

#define	DEFAULT_MESSAGE_NUMBER_OF_LINES		2

@interface HUDMessageView : UIImageView {
	UILabel *messageLabel;
}

- (id)initWithMessage:(NSString*)message;
- (void)showInView:(UIView*)view;
- (void)dismiss;

@end
