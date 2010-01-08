#import "EntryView.h"

@implementation EntryView

@synthesize webView;
@synthesize siteButton;
@synthesize pinButton;
@synthesize prevFeedButton;
@synthesize nextFeedButton;
@synthesize prevEntryButton;
@synthesize nextEntryButton;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setOpaque:YES];
		
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372.0f)];
		[webView setOpaque:YES];
		
		[self addSubview:webView];
		
		pinButton = [[UIBarButtonItem alloc]
					 initWithImage:[UIImage imageNamed:@"pin.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		
		siteButton = [[UIBarButtonItem alloc] 
					  initWithImage:[UIImage imageNamed:@"web.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		
		prevFeedButton = [[UIBarButtonItem alloc] 
						  initWithImage:[UIImage imageNamed:@"up2.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		nextFeedButton = [[UIBarButtonItem alloc] 
						  initWithImage:[UIImage imageNamed:@"down2.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		
		prevEntryButton = [[UIBarButtonItem alloc] 
						   initWithImage:[UIImage imageNamed:@"up.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		nextEntryButton = [[UIBarButtonItem alloc] 
						   initWithImage:[UIImage imageNamed:@"down.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
		
		UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 372.0f, 320.0f, 44.0f)];
		UIBarButtonItem *fixedSpace1 = [[[UIBarButtonItem alloc]
										 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpace2 = [[[UIBarButtonItem alloc]
										 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpace3 = [[[UIBarButtonItem alloc]
										 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpace4 = [[[UIBarButtonItem alloc]
										 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpace5 = [[[UIBarButtonItem alloc]
										 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		[fixedSpace1 setWidth:8.0f];
		[fixedSpace2 setWidth:12.0f];
		[fixedSpace3 setWidth:20.0f];
		[fixedSpace4 setWidth:8.0f];
		[fixedSpace5 setWidth:12.0f];
		UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		[toolBar setItems:[NSArray arrayWithObjects:
						   pinButton, fixedSpace1, siteButton, 
						   flexibleSpace,
						   prevFeedButton, fixedSpace2, nextFeedButton, 
						   fixedSpace3,
						   prevEntryButton, fixedSpace4, nextEntryButton, fixedSpace5, nil]];
		
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
	[nextEntryButton release];
	[prevEntryButton release];
	[nextFeedButton release];
	[prevFeedButton release];
	[pinButton release];
	[siteButton release];
	[webView setDelegate:nil];
	[webView release];
	[super dealloc];
}

@end
