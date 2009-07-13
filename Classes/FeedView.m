#import "FeedView.h"

@implementation FeedView

@synthesize tableView;
@synthesize markAsReadButton;
@synthesize prevButton;
@synthesize nextButton;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setOpaque:YES];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372.0f)];
		[tableView setOpaque:YES];
		
		[self addSubview:tableView];
		
		markAsReadButton = [[UIBarButtonItem alloc] 
							initWithTitle:NSLocalizedString(@"MarkAsRead", nil) 
							style:UIBarButtonItemStyleBordered 
							target:nil
							action:nil];
		
		prevButton = [[UIBarButtonItem alloc] 
					  initWithImage:[UIImage imageNamed:@"up.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		nextButton = [[UIBarButtonItem alloc] 
					  initWithImage:[UIImage imageNamed:@"down.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		
		UIBarButtonItem *fixedSpace1 = [[[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpace2 = [[[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		[fixedSpace1 setWidth:12.0f];
		[fixedSpace2 setWidth:12.0f];
		UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		
		UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 372.0f, 320.0f, 44.0f)];
		[toolBar setItems:[NSArray arrayWithObjects:markAsReadButton,
						   flexibleSpace,
						   prevButton, fixedSpace1, nextButton, fixedSpace2, nil]];
		
		[self addSubview:toolBar];
		[toolBar release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[nextButton release];
	[prevButton release];
	[markAsReadButton release];
	[tableView release];
	[super dealloc];
}

@end
