#import "HUDMessageView.h"
#import <QuartzCore/QuartzCore.h>

#define kFadeInAnimationDuration 0.3f
#define kFadeOutAnimationDuration 0.3f
#define kHUDDefaultWidth 210.0f
#define kHUDDefaultHeight 70.0f
#define kHUDConstrainedWidth 210.0f
#define kHUDConstrainedHeight 460.0f

CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius) {
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius);
	
	CGPathAddArcToPoint(path, NULL, rect.origin.x, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y, cornerRadius);
	CGPathAddArcToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, cornerRadius);
	CGPathAddArcToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height, cornerRadius);
	CGPathAddArcToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y, cornerRadius);
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation HUDMessageView

static UIFont *messageFont = NULL;
static UIColor *whiteColor = NULL;

+ (void)initialize {
	messageFont = [[UIFont boldSystemFontOfSize:18.0f] retain];
	whiteColor = [[UIColor whiteColor] retain];
}

- (id) initWithMessage:(NSString*)aMessage {
	if( self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
		message = [aMessage retain];;
		
		self.alpha = 1.0f;
		self.opaque = NO;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
	
	const CGFloat RECT_PADDING = 8.0f;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 8.0f;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat BACKGROUND_OPACITY = 0.5f;
	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
	
	const CGFloat STROKE_OPACITY = 0.25f;
	CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
	
	[whiteColor set];
	CGSize messageSize = [message sizeWithFont:messageFont constrainedToSize:CGSizeMake(kHUDDefaultWidth, kHUDConstrainedHeight) lineBreakMode:UILineBreakModeCharacterWrap];
	[message drawInRect:CGRectMake((rect.size.width - messageSize.width) / 2 + 8.0f, (rect.size.height - messageSize.height) / 2 + 9.0f, rect.size.width - 18.0f, rect.size.height) withFont:messageFont lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
}

- (void)showInView:(UIView*)view {
	CGRect superview_rect = view.frame;
	
	CGSize messageSize = [message sizeWithFont:messageFont constrainedToSize:CGSizeMake(kHUDDefaultWidth, kHUDConstrainedHeight) lineBreakMode:UILineBreakModeCharacterWrap];
	
	CGRect self_rect = self.frame;
	self_rect.size.width = messageSize.width + 40.0f;
	self_rect.size.height = MAX(messageSize.height + 40.0f, kHUDDefaultHeight);
	self_rect.origin.x = (superview_rect.size.width - self_rect.size.width) / 2;
	self_rect.origin.y = (superview_rect.size.height - self_rect.size.height) / 2  - 44.0f;
	
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
		[UIView setAnimationDuration:kFadeOutAnimationDuration];
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
	[message release];
    [super dealloc];
}

@end
