#import "FeedListCell.h"
#import "FeedListBackgroundCell.h"
#import "TableCellDrawing.h"
#import "Colors.h"

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
	[self setNeedsDisplay];
	[self.selectedBackgroundView setNeedsDisplay];
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
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 252.0f, 42.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGGradientRef gradientForSelected = createTwoColorsGradient(5, 140, 245, 1, 93, 230);
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	[whiteColor set];
	[readCountText drawInRect:CGRectMake(265.0f, 5.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[unreadCountText drawInRect:CGRectMake(265.0f, 23.0f, 30.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 252.0f, 42.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
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
