#import <UIKit/UIKit.h>
#import "EntryView.h"
#import "FeedViewController.h"

@interface EntryViewController : UIViewController <UIWebViewDelegate> {
	EntryView *entryView;
	NSArray *feedList;
	NSDictionary *feed;
	NSArray *items;
	NSDictionary *currentItem;
	NSDateFormatter *formatter;
	
	FeedViewController *feedViewController;
	
	BOOL backedFromSiteView;
    BOOL shouldReload;
}

@property (nonatomic, retain) EntryView *entryView;
@property (retain) NSArray *feedList;
@property (retain) NSDictionary *feed;
@property (retain) NSArray *items;
@property (retain) NSDictionary *currentItem;

@property (nonatomic, retain) FeedViewController *feedViewController;

@end
