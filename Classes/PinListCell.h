#import <UIKit/UIKit.h>

@interface PinListCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *linkLabel;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *linkLabel;

@end
