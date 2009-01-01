#import "FeedCell.h"
#import "Debug.h"

@implementation FeedCell

@synthesize titleLabel;
@synthesize unreadMark;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self setOpaque:YES];
		
		unreadMark = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 17.0f, 10.0f, 10.0f)];
		[unreadMark setOpaque:YES];
		[self addSubview:unreadMark];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 1.0f, 277.0f, 42.0f)];
		[titleLabel setOpaque:YES];
		[titleLabel setNumberOfLines:2];
		[titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
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
	[titleLabel release];
	[super dealloc];
}

@end
