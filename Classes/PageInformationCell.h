#import <UIKit/UIKit.h>

@interface PageInformationCell : UITableViewCell {
	UILabel *commentLabel;
	UILabel *userLabel;
	UILabel *numberLabel;
}

@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UILabel *userLabel;
@property (nonatomic, retain) UILabel *numberLabel;

@end
