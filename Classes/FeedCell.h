#import <UIKit/UIKit.h>


@interface FeedCell : UITableViewCell {
	UILabel *titleLabel;
	UIImageView *unreadMark;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *unreadMark;

@end
