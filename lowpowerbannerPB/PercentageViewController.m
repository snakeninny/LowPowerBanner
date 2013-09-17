#import "LowPowerBannerListController.h"
#import "PercentageViewController.h"
#import "RingtoneViewController.h"
#import "IconViewController.h"
#import <sqlite3.h>
#import <notify.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

@implementation PercentageViewController

@synthesize levelString;
@synthesize downToneString;
@synthesize downVibrateString;
@synthesize downTitleString;
@synthesize downMessageString;
@synthesize downIconString;
@synthesize upToneString;
@synthesize upVibrateString;
@synthesize upTitleString;
@synthesize upMessageString;
@synthesize upIconString;

- (PercentageViewController *)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

- (void)loadView
{
	[self loadSettings];
	if ([self.levelString isEqualToString:@"-1"])
		self.title = NSLocalizedStringFromTableInBundle(@"Unplugged", nil, BUNDLE, @"Unplugged");
	else if ([self.levelString isEqualToString:@"0"])
		self.title = NSLocalizedStringFromTableInBundle(@"Plugged in", nil, BUNDLE, @"Plugged in");
	else self.title = [NSString stringWithFormat:@"%@%%", self.levelString];
	[super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([self.levelString isEqualToString:@"100"] || [self.levelString isEqualToString:@"0"]  || [self.levelString isEqualToString:@"-1"])
		return 1;
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self.levelString isEqualToString:@"0"]  || [self.levelString isEqualToString:@"-1"])
		return @"";

	if (section == 0)
		return NSLocalizedStringFromTableInBundle(@"Charging", nil, BUNDLE, @"Charging");
	return NSLocalizedStringFromTableInBundle(@"Draining", nil, BUNDLE, @"Draining");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-fucking-cell"] autorelease];

		switch (indexPath.row)
		{
			case 0:
				{
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Ringtone", nil, BUNDLE, @"Ringtone");
					if (indexPath.section == 0)
						cell.detailTextLabel.text = self.upToneString;
					else cell.detailTextLabel.text = self.downToneString;
					break;
				}
			case 1:
				{
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Icon", nil, BUNDLE, @"Icon");
					if (indexPath.section == 0)
						cell.detailTextLabel.text = self.upIconString;
					else cell.detailTextLabel.text = self.downIconString;
					break;
				}
			case 2:
				{
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Vibrate", nil, BUNDLE, @"Vibrate");
					UISwitch *vibSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					cell.accessoryView = vibSwitch;
					[vibSwitch addTarget:self action:@selector(saveConfig) forControlEvents:UIControlEventValueChanged];
					if (indexPath.section == 0)
					{
						[upVibrateSwitch release];
						upVibrateSwitch = nil;
						upVibrateSwitch = vibSwitch;
						upVibrateSwitch.on = [self.upVibrateString isEqualToString:@"0"] ? NO : YES;
					}
					else
					{
						[downVibrateSwitch release];
						downVibrateSwitch = nil;
						downVibrateSwitch = vibSwitch;
						downVibrateSwitch.on = [self.downVibrateString isEqualToString:@"0"] ? NO : YES;
					}
					break;
				}
			case 3:
				{
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					UITextField *titleField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 10.0f, cell.contentView.frame.size.width - 30.0f, 22.0f)];
					titleField.delegate = self;
					titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
					titleField.placeholder = NSLocalizedStringFromTableInBundle(@"Title", nil, BUNDLE, @"Title");
					if (indexPath.section == 0)
					{
						[upTitleField release];
						upTitleField = nil;
						upTitleField = titleField;
						upTitleField.text = self.upTitleString;
						[cell.contentView addSubview:upTitleField];
					}
					else
					{
						[downTitleField release];
						downTitleField = nil;
						downTitleField = titleField;
						downTitleField.text = self.downTitleString;
						[cell.contentView addSubview:downTitleField];
					}
					break;
				}
			case 4:
				{
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					UITextField *messageField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 10.0f, cell.contentView.frame.size.width - 30.0f, 22.0f)];
					messageField.delegate = self;
					messageField.clearButtonMode = UITextFieldViewModeWhileEditing;
					messageField.placeholder = NSLocalizedStringFromTableInBundle(@"Message", nil, BUNDLE, @"Message");
					if (indexPath.section == 0)
					{
						[upMessageField release];
						upMessageField = nil;
						upMessageField = messageField;
						upMessageField.text = self.upMessageString;
						[cell.contentView addSubview:upMessageField];
					}
					else
					{
						[downMessageField release];
						downMessageField = nil;
						downMessageField = messageField;
						downMessageField.text = self.downMessageString;
						[cell.contentView addSubview:downMessageField];
					}
					break;
				}
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		RingtoneViewController *controller = [[RingtoneViewController alloc] init];
		controller.levelString = self.levelString;
		if (indexPath.section == 0)
		{
			controller.toneString = self.upToneString;
			controller.typeString = @"uptone";
		}
		else
		{
			controller.toneString = self.downToneString;
			controller.typeString = @"downtone";
		}
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	else if (indexPath.row == 1)
	{
		IconViewController *controller=[[IconViewController alloc] init];
		controller.levelString = self.levelString;
		if (indexPath.section == 0)
		{
			controller.iconString = self.upIconString;
			controller.typeString = @"upicon";
		}
		else
		{
			controller.iconString = self.downIconString;
			controller.typeString = @"downicon";
		}
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (![[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
		[self animateTextField:textField up:NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (![[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
		[self animateTextField:textField up:YES];
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
{
	const int movementDistance = 150;
	const float movementDuration = 0.3f;
	int movement = (up ? -movementDistance : movementDistance);
	[UIView beginAnimations:@"com.naken.lowpowerbanner" context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration: movementDuration];
	self.view.frame = CGRectOffset(self.view.frame, 0, movement);
	[UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self saveConfig];
}

- (void)saveConfig
{
	[downTitleField resignFirstResponder];
	[downMessageField resignFirstResponder];
	[upTitleField resignFirstResponder];
	[upMessageField resignFirstResponder];

	if (downVibrateSwitch != nil)
	{
		self.downVibrateString = nil;
		self.downVibrateString = downVibrateSwitch.on ? @"1" : @"0";
	}

	if (downTitleField != nil)
	{
		self.downTitleString = nil;
		self.downTitleString = [([downTitleField.text length] != 0 ? downTitleField.text : @"") stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	}

	if (downMessageField != nil)
	{
		self.downMessageString = nil;
		self.downMessageString = [([downMessageField.text length] != 0 ? downMessageField.text : @"") stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	}

	self.upVibrateString = nil;
	self.upVibrateString = upVibrateSwitch.on ? @"1" : @"0";

	self.upTitleString = nil;
	self.upTitleString = [([upTitleField.text length] != 0 ? upTitleField.text : @"") stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

	self.upMessageString = nil;
	self.upMessageString = [([upMessageField.text length] != 0 ? upMessageField.text : @"") stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"update lpb set upvib = '%@', uptitle = '%@', upmsg = '%@', downvib = '%@', downtitle = '%@', downmsg = '%@' where level = '%@'", self.upVibrateString, self.upTitleString, self.upMessageString, self.downVibrateString, self.downTitleString, self.downMessageString, self.levelString];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@, %s",sql,error);

		sqlite3_close(database);
	}

	for (UITableViewController *controller in self.navigationController.viewControllers)
	{
		if ([controller isKindOfClass:[NSClassFromString(@"LowPowerBannerListController") class]])
		{
			[controller loadView];
			[(UITableView *)controller.view reloadData];
		}
	}
}

- (void)loadSettings
{
	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select uptone, upvib, uptitle, upmsg, upicon, downtone, downvib, downtitle, downmsg, downicon from lpb where level = '%@'", self.levelString];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				char *upTone = (char *)sqlite3_column_text(statement, 0);
				self.upToneString = nil;
				self.upToneString = upTone ? [NSString stringWithUTF8String:upTone] : @"";

				char *upVib = (char *)sqlite3_column_text(statement, 1);
				self.upVibrateString = nil;
				self.upVibrateString = upVib ? [NSString stringWithUTF8String:upVib] : @"";

				char *upTitle = (char *)sqlite3_column_text(statement, 2);
				self.upTitleString = nil;
				self.upTitleString = upTitle ? [NSString stringWithUTF8String:upTitle] : @"";

				char *upMsg = (char *)sqlite3_column_text(statement, 3);
				self.upMessageString = nil;
				self.upMessageString = upMsg ? [NSString stringWithUTF8String:upMsg] : @"";

				char *upIcon = (char *)sqlite3_column_text(statement, 4);
				self.upIconString = nil;
				self.upIconString = upIcon ? [NSString stringWithUTF8String:upIcon] : @"";

				char *downTone = (char *)sqlite3_column_text(statement, 5);
				self.downToneString = nil;
				self.downToneString = downTone ? [NSString stringWithUTF8String:downTone] : @"";

				char *downVib = (char *)sqlite3_column_text(statement, 6);
				self.downVibrateString = nil;
				self.downVibrateString = downVib ? [NSString stringWithUTF8String:downVib] : @"";

				char *downTitle = (char *)sqlite3_column_text(statement, 7);
				self.downTitleString = nil;
				self.downTitleString = downTitle ? [NSString stringWithUTF8String:downTitle] : @"";

				char *downMsg = (char *)sqlite3_column_text(statement, 8);
				self.downMessageString = nil;
				self.downMessageString = downMsg ? [NSString stringWithUTF8String:downMsg] : @"";

				char *downIcon = (char *)sqlite3_column_text(statement, 9);
				self.downIconString = nil;
				self.downIconString = downIcon ? [NSString stringWithUTF8String:downIcon] : @"";
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"LPBERROR: %@, %s", sql, error);

		sqlite3_close(database);
	}
}

- (void)dealloc
{
	[levelString release];
	[downToneString release];
	[downVibrateString release];
	[downTitleString release];
	[downMessageString release];
	[downIconString release];
	[upToneString release];
	[upVibrateString release];
	[upTitleString release];
	[upMessageString release];
	[upIconString release];
	[downVibrateSwitch release];
	[downTitleField release];
	[downMessageField release];
	[upVibrateSwitch release];
	[upTitleField release];
	[upMessageField release];

	[super dealloc];
}
@end
