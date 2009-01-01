#import <UIKit/UIKit.h>

@interface EntryView : UIView {
	UIWebView *webView;
	UIBarButtonItem *pinButton;
	UIBarButtonItem *siteButton;
	UIBarButtonItem *prevFeedButton;
	UIBarButtonItem *nextFeedButton;
	UIBarButtonItem *prevEntryButton;
	UIBarButtonItem *nextEntryButton;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *siteButton;
@property (nonatomic, retain) UIBarButtonItem *pinButton;
@property (nonatomic, retain) UIBarButtonItem *prevFeedButton;
@property (nonatomic, retain) UIBarButtonItem *nextFeedButton;
@property (nonatomic, retain) UIBarButtonItem *prevEntryButton;
@property (nonatomic, retain) UIBarButtonItem *nextEntryButton;

@end
