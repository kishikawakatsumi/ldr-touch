#import <UIKit/UIKit.h>


@interface FeedView : UIView {
	UITableView *tableView;
	UIBarButtonItem *markAsReadButton;
	UIBarButtonItem *prevButton;
	UIBarButtonItem *nextButton;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIBarButtonItem *markAsReadButton;
@property (nonatomic, retain) UIBarButtonItem *prevButton;
@property (nonatomic, retain) UIBarButtonItem *nextButton;

@end
