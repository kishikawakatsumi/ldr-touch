#import "UserSettingSheetController.h"
#import "LDRTouchAppDelegate.h"
#import "LoginManager.h"
#import "UserSettings.h"
#import "RootViewController.h"
#import "Constants.h"
#import "Debug.h"

@implementation UserSettingSheetController

@synthesize userSettingSheet;

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[cells release];
	[userSettingSheet setDelegate:nil];
	[userSettingSheet release];
	[super dealloc];
}

#pragma mark Utility Methods

- (void)saveSettings {
	UserSettings *newSettings = [[UserSettings alloc] init]; 
	newSettings.userName = [[cells objectForKey:@"userName"] text];
	newSettings.password = [[cells objectForKey:@"password"] text];
	
	newSettings.serviceURI = [[cells objectForKey:@"serviceURI"] text];

	newSettings.sortOrder = sortOrder;
	newSettings.viewMode = viewMode;
	
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	
	BOOL shouldRefleshData = 
	(![newSettings.serviceURI isEqualToString:userSettings.serviceURI])
	|| (![newSettings.userName isEqualToString:userSettings.userName] || ![newSettings.password isEqualToString:userSettings.password])
	&& ([newSettings.userName length] != 0 && [newSettings.password length] != 0);
	
	BOOL shouldOrganizeData = newSettings.sortOrder != userSettings.sortOrder || newSettings.viewMode != userSettings.viewMode;
	
	userSettings.userName = newSettings.userName;
	userSettings.password = newSettings.password;
	userSettings.serviceURI = newSettings.serviceURI;
	userSettings.sortOrder = newSettings.sortOrder;
	userSettings.viewMode = newSettings.viewMode;
	
	LoginManager *loginManager = [LDRTouchAppDelegate sharedLoginManager];
	if (shouldRefleshData) {
		[loginManager invalidate];
		RootViewController *controller = (RootViewController *)[sharedLDRTouchApp.navigationController topViewController];
		[controller refreshData];
	}
	
	if (shouldOrganizeData) {
		RootViewController *controller = (RootViewController *)[sharedLDRTouchApp.navigationController topViewController];
		[controller refreshDataIfNeeded];
	}
	
	[newSettings release];
	
	[sharedLDRTouchApp saveUserSettings];
}

#pragma mark Action Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([actionSheet.title isEqualToString:NSLocalizedString(@"SortOrder", nil)]) {
		UILabel *sortOrderLabel = [cells objectForKey:@"SortOrder"];
		
		if (buttonIndex == 0) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderDate", nil)];
			sortOrder = UserSettingsSortOrderDate;
		} else if (buttonIndex == 1) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderDateAsc", nil)];
			sortOrder = UserSettingsSortOrderDateAsc;
		} else if (buttonIndex == 2) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfUnread", nil)];
			sortOrder = UserSettingsSortOrderNumberOfUnread;
		} else if (buttonIndex == 3) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfUnreadAsc", nil)];
			sortOrder = UserSettingsSortOrderNumberOfUnreadAsc;
		} else if (buttonIndex == 4) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderTitle", nil)];
			sortOrder = UserSettingsSortOrderTitle;
		} else if (buttonIndex == 5) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderRate", nil)];
			sortOrder = UserSettingsSortOrderRate;
		} else if (buttonIndex == 6) {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfSubscribers", nil)];
			sortOrder = UserSettingsSortOrderNumberOfSubscribers;
		} else {
			[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfSubscribersAsc", nil)];
			sortOrder = UserSettingsSortOrderNumberOfSubscribersAsc;
		}
	} else {
		UILabel *viewModeLabel = [cells objectForKey:@"ViewMode"];
		
		if (buttonIndex == 0) {
			[viewModeLabel setText:NSLocalizedString(@"ViewModeFlat", nil)];
			viewMode = UserSettingsViewModeFlat;
		} else if (buttonIndex == 1) {
			[viewModeLabel setText:NSLocalizedString(@"ViewModeFolder", nil)];
			viewMode = UserSettingsViewModeFolder;
		} else if (buttonIndex == 2) {
			[viewModeLabel setText:NSLocalizedString(@"ViewModeRate", nil)];
			viewMode = UserSettingsViewModeRate;
		} else {
			[viewModeLabel setText:NSLocalizedString(@"ViewModeSubscribers", nil)];
			viewMode = UserSettingsViewModeSubscribers;
		}
	}

	[userSettingSheet deselectRowAtIndexPath:[userSettingSheet indexPathForSelectedRow] animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	UILabel *serviceURIInput = [cells objectForKey:@"serviceURI"];
	if ([[serviceURIInput text] length] == 0) {
		serviceURIInput.text = SERVICE_URI_DEFAULT;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)hideView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)readFlagValueChanged:(id)sender {
	UISwitch *sw = (UISwitch *)sender;
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	userSettings.markAsReadAuto = sw.on;
}

- (void)showBadgeFlagValueChanged:(id)sender {
	UISwitch *sw = (UISwitch *)sender;
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	userSettings.showBadgeFlag = sw.on;
}

- (void)useMobileProxyFlagValueChanged:(id)sender {
	UISwitch *sw = (UISwitch *)sender;
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	userSettings.useMobileProxy = sw.on;
}

- (void)shouldAutoRotationFlagValueChanged:(id)sender {
	UISwitch *sw = (UISwitch *)sender;
	LDRTouchAppDelegate *sharedLDRTouchApp = [LDRTouchAppDelegate sharedLDRTouchApp];
	UserSettings *userSettings = sharedLDRTouchApp.userSettings;
	userSettings.shouldAutoRotation = sw.on;
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 3;
	} else if (section == 1) {
		return 3;
	} else if (section == 2) {
		return 1;
	} else {
		return 2;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Account", nil);
	} else if (section == 1) {
		return NSLocalizedString(@"Feed", nil);
	} else if (section == 2) {
		return NSLocalizedString(@"UnreadCount", nil);
	} else {
		return NSLocalizedString(@"WebView", nil);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 40.0;
	} else {
		return 26.0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	LDRTouchAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	UserSettings *userSettings = delegate.userSettings;
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserNameCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserNameCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 0.0, 282.0, 44.0)];
			inputField.delegate = self;
			[cell addSubview:inputField];
			
			[inputField setAdjustsFontSizeToFitWidth:NO];
			[inputField setBorderStyle:UITextBorderStyleNone];
			[inputField setClearButtonMode:UITextFieldViewModeAlways];
			[inputField setClearsOnBeginEditing:NO];
			[inputField setPlaceholder:NSLocalizedString(@"UserName", nil)];
			[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[inputField setEnablesReturnKeyAutomatically:YES];
			[inputField setKeyboardType:UIKeyboardTypeASCIICapable];
			[inputField setReturnKeyType:UIReturnKeyDone];
			
			[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			
			[inputField setText:userSettings.userName];
			
			[cells setObject:inputField forKey:@"userName"];
			
			[inputField release];
		}
		
		return cell;
	} else if (indexPath.section == 0 && indexPath.row == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PassewordCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"PassewordCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 0.0, 282.0, 44.0)];
			inputField.delegate = self;
			[cell addSubview:inputField];
			
			[inputField setAdjustsFontSizeToFitWidth:NO];
			[inputField setBorderStyle:UITextBorderStyleNone];
			[inputField setClearButtonMode:UITextFieldViewModeAlways];
			[inputField setClearsOnBeginEditing:YES];
			[inputField setPlaceholder:NSLocalizedString(@"Password", nil)];
			[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[inputField setEnablesReturnKeyAutomatically:YES];
			[inputField setKeyboardType:UIKeyboardTypeASCIICapable];
			[inputField setReturnKeyType:UIReturnKeyDone];
			[inputField setSecureTextEntry:YES];
			
			[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			
			[inputField setText:userSettings.password];
			
			[cells setObject:inputField forKey:@"password"];
			
			[inputField release];
		}
		
		return cell;
	} else if (indexPath.section == 0 && indexPath.row == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceURICell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ServiceURICell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 0.0, 282.0, 44.0)];
			inputField.delegate = self;
			[cell addSubview:inputField];
			
			[inputField setAdjustsFontSizeToFitWidth:NO];
			[inputField setBorderStyle:UITextBorderStyleNone];
			[inputField setClearButtonMode:UITextFieldViewModeAlways];
			[inputField setClearsOnBeginEditing:NO];
			[inputField setPlaceholder:NSLocalizedString(@"ServiceURI", nil)];
			[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[inputField setEnablesReturnKeyAutomatically:YES];
			[inputField setKeyboardType:UIKeyboardTypeURL];
			[inputField setReturnKeyType:UIReturnKeyDone];
			
			[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			
			[inputField setText:userSettings.serviceURI];
			
			[cells setObject:inputField forKey:@"serviceURI"];
			
			[inputField release];
		}
		
		return cell;
	} else if (indexPath.section == 1 && indexPath.row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReadFlagCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ReadFlagCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:14]];
			[description setText:NSLocalizedString(@"ReadFlagAuto", nil)];
			
			[description release];
			
			UISwitch *readFlagSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)];
			[readFlagSwitch addTarget:self action:@selector(readFlagValueChanged:) forControlEvents:UIControlEventValueChanged];
			readFlagSwitch.on = userSettings.markAsReadAuto;
			[cell addSubview:readFlagSwitch];
			[readFlagSwitch release];
		}
		
		return cell;
	} else if (indexPath.section == 1 && indexPath.row == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortOrderCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SortOrderCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 110.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:14]];
			[description setText:NSLocalizedString(@"SortOrder", nil)];
			[description setHighlightedTextColor:[UIColor whiteColor]];
			
			[description release];
			
			UILabel *sortOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(144.0, 12.0, 156.0, 21.0)];
			[sortOrderLabel setTextAlignment:UITextAlignmentRight];
			[sortOrderLabel setHighlightedTextColor:[UIColor whiteColor]];
			[sortOrderLabel setAdjustsFontSizeToFitWidth:NO];
			[sortOrderLabel setFont:[UIFont systemFontOfSize:16]];
			[sortOrderLabel setTextColor:[UIColor colorWithRed:0.20 green:0.30 blue:0.49 alpha:1.0]];
			
			[cell addSubview:sortOrderLabel];
			
			sortOrder = userSettings.sortOrder;
			if (sortOrder == UserSettingsSortOrderDate) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderDate", nil)];
			} else if (sortOrder == UserSettingsSortOrderNumberOfUnread) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfUnread", nil)];
			} else if (sortOrder == UserSettingsSortOrderNumberOfSubscribers) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfSubscribers", nil)];
			} else if (sortOrder == UserSettingsSortOrderTitle) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderTitle", nil)];
			} else if (sortOrder == UserSettingsSortOrderRate) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderRate", nil)];
			} else if (sortOrder == UserSettingsSortOrderDateAsc) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderDateAsc", nil)];
			} else if (sortOrder == UserSettingsSortOrderNumberOfUnreadAsc) {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfUnreadAsc", nil)];
			} else {
				[sortOrderLabel setText:NSLocalizedString(@"SortOrderNumberOfSubscribersAsc", nil)];
			}
			
			[cells setObject:sortOrderLabel forKey:@"SortOrder"];
			
			[sortOrderLabel release];
		}
		
		return cell;
	} else if (indexPath.section == 1 && indexPath.row == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ViewModeCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ViewModeCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 110.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:14]];
			[description setText:NSLocalizedString(@"ViewMode", nil)];
			[description setHighlightedTextColor:[UIColor whiteColor]];
			
			[description release];
			
			UILabel *viewModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(144.0, 12.0, 156.0, 21.0)];
			[viewModeLabel setTextAlignment:UITextAlignmentRight];
			[viewModeLabel setHighlightedTextColor:[UIColor whiteColor]];
			[viewModeLabel setAdjustsFontSizeToFitWidth:NO];
			[viewModeLabel setFont:[UIFont systemFontOfSize:16]];
			[viewModeLabel setTextColor:[UIColor colorWithRed:0.20 green:0.30 blue:0.49 alpha:1.0]];
			
			[cell addSubview:viewModeLabel];
			
			viewMode = userSettings.viewMode;
			if (viewMode == UserSettingsViewModeFlat) {
				[viewModeLabel setText:NSLocalizedString(@"ViewModeFlat", nil)];
			} else if (viewMode == UserSettingsViewModeFolder) {
				[viewModeLabel setText:NSLocalizedString(@"ViewModeFolder", nil)];
			} else if (viewMode == UserSettingsViewModeRate) {
				[viewModeLabel setText:NSLocalizedString(@"ViewModeRate", nil)];
			} else {
				[viewModeLabel setText:NSLocalizedString(@"ViewModeSubscribers", nil)];
			}
			
			[cells setObject:viewModeLabel forKey:@"ViewMode"];
			
			[viewModeLabel release];
		}
		
		return cell;
	} else if (indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnreadCountCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UnreadCountCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:13]];
			[description setText:NSLocalizedString(@"ShowBadge", nil)];
			
			[description release];
			
			UISwitch *showBadgeFlagSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)];
			[showBadgeFlagSwitch addTarget:self action:@selector(showBadgeFlagValueChanged:) forControlEvents:UIControlEventValueChanged];
			showBadgeFlagSwitch.on = userSettings.showBadgeFlag;
			[cell addSubview:showBadgeFlagSwitch];
			[showBadgeFlagSwitch release];
		}
		
		return cell;
	} else if (indexPath.section == 3 && indexPath.row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UseMobileProxyCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UseMobileProxyCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:13]];
			[description setText:NSLocalizedString(@"UseMobileProxy", nil)];
			
			[description release];
			
			UISwitch *useMobileProxy = [[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)];
			[useMobileProxy addTarget:self action:@selector(useMobileProxyFlagValueChanged:) forControlEvents:UIControlEventValueChanged];
			[useMobileProxy setOn:userSettings.useMobileProxy];
			[cell addSubview:useMobileProxy];
			[useMobileProxy release];
		}
		
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoRotationCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AutoRotationCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:13]];
			[description setText:NSLocalizedString(@"AutoRotation", nil)];
			
			[description release];
			
			UISwitch *shouldAutoRotation = [[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)];
			[shouldAutoRotation addTarget:self action:@selector(shouldAutoRotationFlagValueChanged:) forControlEvents:UIControlEventValueChanged];
			[shouldAutoRotation setOn:userSettings.shouldAutoRotation];
			[cell addSubview:shouldAutoRotation];
			[shouldAutoRotation release];
		}
		
		return cell;
	}
}

#pragma mark <UITableViewDelegate> Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 1) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:NSLocalizedString(@"SortOrder", nil)
									  delegate:self
									  cancelButtonTitle:nil 
									  destructiveButtonTitle:nil
									  otherButtonTitles:
									  NSLocalizedString(@"SortOrderDate", nil),
									  NSLocalizedString(@"SortOrderDateAsc", nil),
									  NSLocalizedString(@"SortOrderNumberOfUnread", nil),
									  NSLocalizedString(@"SortOrderNumberOfUnreadAsc", nil),
									  NSLocalizedString(@"SortOrderTitle", nil),
									  NSLocalizedString(@"SortOrderRate", nil),
									  NSLocalizedString(@"SortOrderNumberOfSubscribers", nil),
									  NSLocalizedString(@"SortOrderNumberOfSubscribersAsc", nil), nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showInView:self.view];
		[actionSheet release];
	} else if (indexPath.section == 1 && indexPath.row == 2) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:NSLocalizedString(@"ViewMode", nil)
									  delegate:self
									  cancelButtonTitle:nil 
									  destructiveButtonTitle:nil
									  otherButtonTitles:
									  NSLocalizedString(@"ViewModeFlat", nil),
									  NSLocalizedString(@"ViewModeFolder", nil),
									  NSLocalizedString(@"ViewModeRate", nil),
									  /*NSLocalizedString(@"ViewModeSubscribers", nil),*/ nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showInView:self.view];
		[actionSheet release];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Settings", nil);
	cells = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self saveSettings];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end

