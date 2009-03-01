#import <UIKit/UIKit.h>


@interface FeedCell : UITableViewCell {
	NSString *titleText;
	UIImage *unreadMarkImage;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) UIImage *unreadMarkImage;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
