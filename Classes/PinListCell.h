#import <UIKit/UIKit.h>

@interface PinListCell : UITableViewCell {
	NSString *titleText;
	NSString *linkText;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *linkText;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
