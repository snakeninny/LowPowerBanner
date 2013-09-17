#import "LowPowerBannerListController.h"
#import "TriggerViewController.h"
#import "PercentageViewController.h"
#import <sqlite3.h>
#import <notify.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

@implementation LowPowerBannerListController
- (id)init
{
	if ((self = [super init]))
	{
		self.title = @"LowPowerBanner";
		tbView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStyleGrouped];
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		[tbView setDelegate:self];
		[tbView setDataSource:self];
	}
	return self;
}

- (id)view
{
	return tbView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 1;
	else if (section == 2)
		return 3;
	return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		switch (indexPath.section)
		{
			case 0:
				{
					cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions' trigger", nil, BUNDLE, @"Actions' trigger");
					break;
				}
			case 1:
				{
					if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"-1"])
						cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when unplugged", nil, BUNDLE, @"Actions when unplugged");
					else if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"0"])
						cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when plugged in", nil, BUNDLE, @"Actions when plugged in");
					else cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Actions at %@%%", nil, BUNDLE, @"Actions at %@%%"), [[self levels] objectAtIndex:indexPath.row]];
					break;
				}
			case 2:
				{
					switch (indexPath.row)
					{
						case 0:
							{
								cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Readme", nil, BUNDLE, @"Readme");
								cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Take a look at me before customizing!", nil, BUNDLE, @"Take a look at me before customizing!");								
								break;
							}
						case 1:
							{
								cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Share ideas and credits", nil, BUNDLE, @"Share ideas and credits");
								cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Email me if you have tweak ideas!", nil, BUNDLE, @"Email me if you have tweak ideas!");
								break;
							}
						case 2:
							{
								cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Donate via PayPal", nil, BUNDLE, @"Donate via PayPal");
								cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Help improve LowPowerBanner!", nil, BUNDLE, @"Help improve LowPowerBanner!");
								break;
							}
					}
				}
		}
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 2)
		return NSLocalizedStringFromTableInBundle(@"By snakeninny & PrimeCode", nil, BUNDLE, @"By snakeninny & PrimeCode");
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 0)
	{
		TriggerViewController *triggerController = [[TriggerViewController alloc] init];
		[self.navigationController pushViewController:triggerController animated:YES];
		[triggerController release];
	}
	else if (indexPath.section == 1)
	{
		PercentageViewController *percentController = [[PercentageViewController alloc] init];
		percentController.levelString = [[self levels] objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:percentController animated:YES];
		[percentController release];
	}
	else if (indexPath.section == 2)
	{
		switch (indexPath.row)
		{
			case 0:
				{
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.", nil, BUNDLE, @"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
					break;
				}
			case 1:
				{
					NSString *url = @"mailto:snakeninny@gmail.com?subject=LowPowerBanner";
					url = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, (CFStringRef)@" ", kCFStringEncodingUTF8);
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
					[url release];
					break;
				}
			case 2:
				{
					NSString *url = @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=DUBPJH667VZYA";
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
					break;
				}
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
		return YES;
	return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [tbView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"delete from lpb where level = '%@'", [[self levels] objectAtIndex:indexPath.row]];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@, %s", sql, error);

		sqlite3_close(database);
	}

	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];

	[(UITableView *)self.view reloadData];

	notify_post("com.naken.lowpowerbanner.loadsettings");
}

- (int)numberOfRows
{
	int number = 0;

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select count (*) from lpb"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				number = atoi((char *)sqlite3_column_text(statement, 0));
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}

	return number;
}

- (NSMutableArray *)levels
{
	NSMutableArray *levelArray = [NSMutableArray arrayWithCapacity:[self numberOfRows]];

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select level from lpb order by (cast(level as integer)) asc"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				char *levelChar = (char *)sqlite3_column_text(statement, 0);
				NSString *levelString = levelChar ? [NSString stringWithUTF8String:levelChar] : @"";
				if ([levelString length] != 0)
					[levelArray addObject:levelString];
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}

	return levelArray;
}

- (void)dealloc
{	
	tbView.delegate = nil;
	[tbView release];
	[super dealloc];
}
@end
