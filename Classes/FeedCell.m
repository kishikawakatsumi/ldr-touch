#import "FeedCell.h"
#import "FeedBackgroundCell.h"
#import "TableCellDrawing.h"
#import "Colors.h"

static UIColor *whiteColor = NULL;
static UIColor *blackColor = NULL;

@implementation FeedCell

@synthesize titleText;
@synthesize unreadMarkImage;

- (void)setTitleText:(NSString *)text {
	if (titleText != text) {
		[titleText release];
		titleText = [text retain];
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
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		FeedBackgroundCell *selectedBackgroundView = [[FeedBackgroundCell alloc] initWithFrame:[self frame]];
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
	[blackColor set];
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 277.0f, 42.0f) withFont:[UIFont systemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGGradientRef gradientForSelected = createTwoColorsGradient(5, 140, 245, 1, 93, 230);
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	[whiteColor set];
	[titleText drawInRect:CGRectMake(18.0f, 5.0f, 277.0f, 42.0f) withFont:[UIFont systemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[unreadMarkImage release];
	[titleText release];
	[super dealloc];
}

@end
