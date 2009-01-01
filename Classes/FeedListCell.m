#import "FeedListCell.h"
#import "Debug.h"

@implementation FeedListCell

@synthesize titleLabel;
@synthesize unreadCountLabel;
@synthesize readCountLabel;
@synthesize unreadMark;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self setOpaque:YES];
		
		unreadMark = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 17.0f, 10.0f, 10.0f)];
		[unreadMark setOpaque:YES];
		[self addSubview:unreadMark];
		
		readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(265.0f, 3.0f, 30.0f, 21.0f)];
		[readCountLabel setOpaque:YES];
		[readCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
		[readCountLabel setTextColor:[UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0f]];
		[readCountLabel setHighlightedTextColor:[UIColor whiteColor]];
		[readCountLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:readCountLabel];
		
		unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(265.0f, 20.0f, 30.0f, 21.0f)];
		[unreadCountLabel setOpaque:YES];
		[unreadCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
		[unreadCountLabel setTextColor:[UIColor colorWithRed:0.2f green:0.4f blue:0.8f alpha:1.0f]];
		[unreadCountLabel setHighlightedTextColor:[UIColor whiteColor]];
		[unreadCountLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:unreadCountLabel];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 1.0f, 252.0f, 42.0f)];
		[titleLabel setOpaque:YES];
		[titleLabel setNumberOfLines:2];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
		[titleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:titleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[unreadMark release];
	[readCountLabel release];
	[unreadCountLabel release];
	[titleLabel release];
    [super dealloc];
}

@end
