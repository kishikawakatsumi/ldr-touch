#import <UIKit/UIKit.h>

@interface FeedListCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *unreadCountLabel;
	UILabel *readCountLabel;
	UIImageView *unreadMark;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *unreadCountLabel;
@property (nonatomic, retain) UILabel *readCountLabel;
@property (nonatomic, retain) UIImageView *unreadMark;

@end
