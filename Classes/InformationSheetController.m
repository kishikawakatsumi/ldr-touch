#import "InformationSheetController.h"
#import "PageInformationCell.h"
#import "NSString+XMLExtensions.h"

@implementation InformationSheetController

@synthesize infoSheet;
@synthesize toolBar;
@synthesize userCount;
@synthesize hideButton;
@synthesize pageURL;
@synthesize pageInfo;
@synthesize bookmarks;

- (void)dealloc {
	[infoSheet setDelegate:nil];
	[infoSheet release];
	[toolBar release];
	[userCount release];
	[hideButton release];
	[pageURL release];
	[pageInfo release];
	[bookmarks release];
	[super dealloc];
}

- (IBAction)hideInfoSheet:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * comment = [[bookmarks objectAtIndex:indexPath.row] objectForKey:@"comment"];
	if ([comment length] > 0) {
		return 90.00;
	} else {
		return 20.00;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PageInformationCell";
	PageInformationCell *cell = (PageInformationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[PageInformationCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone]; 
    }
	
	NSString *comment = [NSString decodeXMLCharactersIn:[[bookmarks objectAtIndex:indexPath.row] objectForKey:@"comment"]];
	[cell.commentLabel setText:comment];
	if ([comment length] > 0) {
		if ([comment length] > 87) {
			[cell.commentLabel setFont:[UIFont systemFontOfSize:11]];
		} else {
			[cell.commentLabel setFont:[UIFont systemFontOfSize:12]];
		}
		[cell.commentLabel setHidden:NO];
		[cell.commentLabel setText:comment];
		[cell.commentLabel setFrame:CGRectMake(20.0f, 1.0f, 280.0f, 68.0f)];
		[cell.userLabel setFrame:CGRectMake(20.0f, 69.0f, 280.0f, 20.0f)];
		[cell.numberLabel setFrame:CGRectMake(0.0f, 35.0f, 16.0f, 21.0f)];
	} else {
		[cell.commentLabel setHidden:YES];
		[cell.commentLabel setFrame:CGRectZero];
		[cell.userLabel setFrame:CGRectMake(20.0, 1.0, 280.0f, 18.0f)];
		[cell.numberLabel setFrame:CGRectMake(0.0, 1.0, 16.0, 18.0)];
	}
	
	[cell.userLabel setText:[[bookmarks objectAtIndex:indexPath.row] objectForKey:@"user"]];
	[cell.numberLabel setText:[NSString stringWithFormat:@"%d", indexPath.row + 1]];
	
	return cell;
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
	[super viewDidLoad];
	id count = [pageInfo objectForKey:@"count"];
	[[toolBar.items objectAtIndex:0] setTitle:[NSString stringWithFormat:@"%@ users", count ? count : @"0" ]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
