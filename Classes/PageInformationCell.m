#import "PageInformationCell.h"
#import "Debug.h"

@implementation PageInformationCell

@synthesize commentLabel;
@synthesize userLabel;
@synthesize numberLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryNone];
		[self setOpaque:YES];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 1.0f, 280.0f, 68.0f)];
		[commentLabel setOpaque:YES];
		[commentLabel setNumberOfLines:5];
		[commentLabel setFont:[UIFont systemFontOfSize:12.0f]];
		[commentLabel setAdjustsFontSizeToFitWidth:YES];
		[self addSubview:commentLabel];
		
		userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 69.0f, 280.0f, 20.0f)];
		[userLabel setOpaque:YES];
		[userLabel setFont:[UIFont systemFontOfSize:12.0f]];
		[userLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:userLabel];
		
		numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 35.0f, 16.0f, 21.0f)];
		[numberLabel setOpaque:YES];
		[numberLabel setFont:[UIFont systemFontOfSize:9.0f]];
		[numberLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:numberLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[commentLabel release];
	[userLabel release];
	[numberLabel release];
	[super dealloc];
}

@end
