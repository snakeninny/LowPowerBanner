#import "TriggerViewController.h"
#import <sqlite3.h>
#import <notify.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

@implementation TriggerViewController
- (TriggerViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) 
	{
		self.title = NSLocalizedStringFromTableInBundle(@"Triggers", nil, BUNDLE, @"Triggers");
	}
	return self;
}

- (void)loadView
{
	[super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 0 ? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];

		switch (indexPath.section)
		{
			case 0: {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					UITextField *percentageField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 10.0f, cell.contentView.frame.size.width - 30.0f, 22.0f)];
					percentageField.delegate = self;
					percentageField.keyboardType = UIKeyboardTypeNumberPad;
					percentageField.placeholder = NSLocalizedStringFromTableInBundle(@"Actions at X%? Input X.", nil, BUNDLE, @"Actions at X%? Input X.");
					[cell.contentView addSubview:percentageField];
					[percentageField release];
					break;
				}
			case 1: {
					switch (indexPath.row)
					{
						case 0:
							{
								cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when unplugged", nil, BUNDLE, @"Actions when unplugged");
								if ([self shouldActWhenUnplugged])
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								break;
							}
						case 1:
							{
								cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when plugged in", nil, BUNDLE, @"Actions when plugged in");
								if ([self shouldActWhenPluggedIn])
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								break;
							}

					}
				}
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section == 1)
	{
		if (cell.accessoryType == UITableViewCellAccessoryNone)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			indexPath.row == 1 ? [self actWhenPluggedIn:YES] : [self actWhenUnplugged:YES];
		}
		else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
			indexPath.row == 1 ? [self actWhenPluggedIn:NO] : [self actWhenUnplugged:NO];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)actWhenPluggedIn:(BOOL)plugged
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = @"";
		if (plugged)
			sql = @"insert into lpb (level, upvib, downvib) values ('0', '0', '0')";
		else sql = @"delete from lpb where level = '0'";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@, %s", sql, error);

		sqlite3_close(database);
	}

	notify_post("com.naken.lowpowerbanner.loadsettings");
}

- (void)actWhenUnplugged:(BOOL)unplugged
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = @"";
		if (unplugged)
			sql = @"insert into lpb (level, upvib, downvib) values ('-1', '0', '0')";
		else sql = @"delete from lpb where level = '-1'";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@, %s", sql, error);

		sqlite3_close(database);
	}

	notify_post("com.naken.lowpowerbanner.loadsettings");
}

- (BOOL)shouldActWhenPluggedIn
{
	char *result = NULL;
	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select * from lpb where level = '0'"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				result = (char *)sqlite3_column_text(statement, 0);
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}
	if (result != NULL)
		return YES;
	return NO;
}

- (BOOL)shouldActWhenUnplugged
{
	char *result = NULL;
	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select * from lpb where level = '-1'"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				result = (char *)sqlite3_column_text(statement, 0);
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}
	if (result != NULL)
		return YES;
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		if ([textField.text length] != 0 && ([textField.text intValue] > 0 && [textField.text intValue] < 101))
		{
			NSString *sql = [NSString stringWithFormat:@"insert into lpb (level, upvib, downvib) values ('%d', '0', '0')", [textField.text intValue]];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
				NSLog(@"LPBERROR: %@, %s", sql, error);
		}
		sqlite3_close(database);
	}

	notify_post("com.naken.lowpowerbanner.loadsettings");
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.view.window endEditing:YES];

	for (UIViewController *viewController in self.navigationController.viewControllers)
	{
		if ([viewController isKindOfClass:[NSClassFromString(@"LowPowerBannerListController") class]])
			[(UITableView *)viewController.view reloadData];
	}
}

- (void)dealloc
{
	[super dealloc];
}
@end
