#import "PinListCell.h"
#import "Debug.h"

@implementation PinListCell

@synthesize titleLabel;
@synthesize linkLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self setOpaque:YES];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 1.0f, 287.0f, 21.0f)];
		[titleLabel setOpaque:YES];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
		[titleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:titleLabel];
		
		linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 22.0f, 287.0f, 21.0f)];
		[linkLabel setOpaque:YES];
		[linkLabel setFont:[UIFont systemFontOfSize:12.0f]];
		[linkLabel setTextColor:[UIColor grayColor]];
		[linkLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:linkLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[linkLabel release];
	[titleLabel release];
    [super dealloc];
}

@end
