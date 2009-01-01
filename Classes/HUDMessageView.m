#import "HUDMessageView.h"
#import "Debug.h"

@implementation HUDMessageView

- (void) initializeMessageLabelWithString:(NSString*)message {
	messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.textColor = [UIColor whiteColor];
	messageLabel.font = [UIFont boldSystemFontOfSize:18];
	messageLabel.textAlignment = UITextAlignmentCenter;
	messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
	messageLabel.numberOfLines = DEFAULT_MESSAGE_NUMBER_OF_LINES;
	messageLabel.text = message;
	[self addSubview:messageLabel];
	[messageLabel release];
}

- (id) initWithMessage:(NSString*)message {
	UIImage *base =  [UIImage imageNamed:@"dialogue.png"];
	UIImage *newImage = [base stretchableImageWithLeftCapWidth:11.0 topCapHeight:11.0];
	
	if( self = [super initWithImage:newImage] ) {
		[self initializeMessageLabelWithString:message];
		
		CGRect messageLabel_arranged_rect;
		CGRect hud_arranged_rect;
		
		messageLabel_arranged_rect = [messageLabel textRectForBounds:CGRectMake(0.0f, 0.0f, DEFAULT_MESSAGE_WIDTH, DEFAULT_MESSAGE_HEIGHT) limitedToNumberOfLines:DEFAULT_MESSAGE_NUMBER_OF_LINES];
		hud_arranged_rect = CGRectMake(0.0f, 0.0f, messageLabel_arranged_rect.size.width + DEFAULT_MESSAGE_HORIZONTAL_MARGIN, DEFAULT_HUD_HEIGHT);
		
		messageLabel_arranged_rect.origin.x = hud_arranged_rect.size.width / 2 - messageLabel_arranged_rect.size.width / 2;
		messageLabel_arranged_rect.origin.y = hud_arranged_rect.size.height / 2;
		messageLabel.frame = messageLabel_arranged_rect;
		
		hud_arranged_rect.size.height = messageLabel_arranged_rect.origin.y + messageLabel_arranged_rect.size.height + DEFAULT_MESSAGE_BOTTOM_MARGIN;
		
		self.frame = hud_arranged_rect;
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)showInView:(UIView*)view {
	CGRect superview_rect = view.frame;
	CGRect self_rect = self.frame;
	self_rect.origin.x = superview_rect.size.width / 2 - self.frame.size.width / 2;
	self_rect.origin.y = superview_rect.size.height / 2 - self.frame.size.height / 2  - 44.0f;
	self.frame = self_rect;
	[view addSubview:self];
}

- (void)dismiss {
	@synchronized(self) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3f];
		[self setAlpha:0.0f];
		[UIView commitAnimations];
	}
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[UIView setAnimationDelegate:nil];
	[self removeFromSuperview];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
    [super dealloc];
}

@end
