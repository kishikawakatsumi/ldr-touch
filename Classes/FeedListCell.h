#import <UIKit/UIKit.h>

@interface FeedListCell : UITableViewCell {
	NSString *titleText;
	NSString *unreadCountText;
	NSString *readCountText;
	UIImage *unreadMarkImage;
	BOOL cached;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *unreadCountText;
@property (nonatomic, retain) NSString *readCountText;
@property (nonatomic, retain) UIImage *unreadMarkImage;
@property (nonatomic) BOOL cached;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
