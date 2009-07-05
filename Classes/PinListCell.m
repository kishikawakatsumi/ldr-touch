#import "PinListCell.h"
#import "PinListBackgroundCell.h"
#import "TableCellDrawing.h"
#import "Colors.h"
#import "Debug.h"

static UIColor *whiteColor = NULL;
static UIColor *blackColor = NULL;
static UIColor *grayColor = NULL;

@implementation PinListCell

@synthesize titleText;
@synthesize linkText;

- (void)setTitleText:(NSString *)text {
	if (titleText != text) {
		[titleText release];
		titleText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setLinkText:(NSString *)text {
	if (linkText != text) {
		[linkText release];
		linkText = [text retain];
		[self setNeedsDisplay];
	}
}

+ (void)initialize {
	whiteColor = [Colors whiteColor];
	blackColor = [Colors blackColor];
	grayColor = [Colors grayColor];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		PinListBackgroundCell *selectedBackgroundView = [[PinListBackgroundCell alloc] initWithFrame:[self frame]];
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
	[blackColor set];
	[titleText drawInRect:CGRectMake(10.0f, 5.0f, 287.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	[grayColor set];
	[linkText drawInRect:CGRectMake(10.0f, 22.0f, 287.0f, 21.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGGradientRef gradientForSelected = createTwoColorsGradient(5, 140, 245, 1, 93, 230);
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	[whiteColor set];
	[titleText drawInRect:CGRectMake(10.0f, 5.0f, 287.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	[linkText drawInRect:CGRectMake(10.0f, 22.0f, 287.0f, 21.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[linkText release];
	[titleText release];
    [super dealloc];
}

@end
