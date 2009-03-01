#import "FeedListCell.h"
#import "FeedListBackgroundCell.h"
#import "Colors.h"
#import "Debug.h"

static UIColor *whiteColor = NULL;
static UIColor *blackColor = NULL;
static UIColor *grayColor = NULL;
static UIColor *blueColor = NULL;
static UIColor *redColor = NULL;

@implementation FeedListCell

@synthesize titleText;
@synthesize unreadCountText;
@synthesize readCountText;
@synthesize unreadMarkImage;
@synthesize cached;

- (void)setTitleText:(NSString *)text {
	if (titleText != text) {
		[titleText release];
		titleText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setUnreadCountText:(NSString *)text {
	if (unreadCountText != text) {
		[unreadCountText release];
		unreadCountText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setReadCountText:(NSString *)text {
	if (readCountText != text) {
		[readCountText release];
		readCountText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setUnreadMarkImage:(UIImage *)image{
	if (unreadMarkImage != image) {
		[unreadMarkImage release];
		unreadMarkImage = [image retain];
		[self setNeedsDisplay];
	}
}

static void drawRoundedRectPath(CGRect rect, BOOL topRound, BOOL bottomRound, BOOL topTriangle) {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat roundSize = 8.0;
	
	CGFloat x = rect.origin.x - 0.5;
	CGFloat y = rect.origin.y - 0.5;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	
	CGContextBeginPath (context);
	
	CGContextMoveToPoint(context,   x + w/2, y + 0);
	if (topRound) {
		CGContextAddArcToPoint(context, x + w, y + 0, x + w,   y + h/2, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + w, y + 0);
	}
	if (bottomRound) {
		CGContextAddArcToPoint(context, x + w, y + h, x + w/2, y + h, roundSize);
		CGContextAddArcToPoint(context, x + 0, y + h, x + 0,   y + h/2, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + w, y + h);
		CGContextAddLineToPoint(context, x + 0, y + h);
	}
	if (topRound) {
		CGContextAddArcToPoint(context, x + 0, y + 0, x + w/2, y + 0, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + 0, y + 0);
	}
	
	if (topTriangle) {
		CGContextAddLineToPoint(context, x + 27, y);
		CGContextAddLineToPoint(context, x + 32, y - 4);
		CGContextAddLineToPoint(context, x + 37, y);
	}
	
	CGContextClosePath(context);
}

static void drawRoundedRectBackgroundGradient(CGRect rect, CGGradientRef gradient, BOOL topRound, BOOL bottomRound, BOOL topTriangle)  {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBStrokeColor(context, 0.5f, 0.5f, 0.5f, 1.0f);
	CGContextSetLineWidth(context, 0.5f);
	
	drawRoundedRectPath(rect, topRound, bottomRound, topTriangle);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,rect.size.height), 
								kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
	
	drawRoundedRectPath(rect, topRound, bottomRound, topTriangle);
	CGContextStrokePath(context);
}

+ (void)initialize {
	whiteColor = [Colors whiteColor];
	blackColor = [Colors blackColor];
	grayColor = [Colors grayColor];
	redColor = [Colors redColor];
	blueColor = [Colors blueColor];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		FeedListBackgroundCell *selectedBackgroundView = [[FeedListBackgroundCell alloc] initWithFrame:[self frame]];
		[selectedBackgroundView setCell:self];
		[self setSelectedBackgroundView:selectedBackgroundView];
		[selectedBackgroundView release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[unreadMarkImage drawInRect:CGRectMake(4.0f, 17.0f, 10.0f, 10.0f)];
	[redColor set];
	[readCountText drawInRect:CGRectMake(265.0f, 5.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[blueColor set];
	[unreadCountText drawInRect:CGRectMake(265.0f, 23.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	if (cached) {
		[blackColor set];
	} else {
		[grayColor set];
	}
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 252.0f, 42.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] =
	{
		0.3f, 0.3f, 1.0f, 1.f,
		0.2f, 0.2f, 0.7f, 1.f,
	};
	CGGradientRef gradientForSelected = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
	
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	
	[whiteColor set];
	[readCountText drawInRect:CGRectMake(265.0f, 5.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[unreadCountText drawInRect:CGRectMake(265.0f, 23.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 252.0f, 42.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[titleText release];
	[unreadCountText release];
	[readCountText release];
	[unreadMarkImage release];
    [super dealloc];
}

@end
