#import "RingtoneViewController.h"
#import "PercentageViewController.h"
#import "LowPowerBannerListController.h"
#import <sqlite3.h>
#import <AudioToolbox/AudioToolbox.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define RINGTONE [DOCUMENT stringByAppendingPathComponent:@"/Ringtones"]
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

@implementation RingtoneViewController

@synthesize levelString;
@synthesize typeString;
@synthesize toneString;
@synthesize ringtonesArray;

- (RingtoneViewController *)init
{
	if((self = [super initWithStyle:UITableViewStyleGrouped]))
		self.title = NSLocalizedStringFromTableInBundle(@"Ringtone", nil, BUNDLE, @"Ringtone");
	return self;
}

- (void)loadView
{
	[self loadAllRingtones];
	[super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.ringtonesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.textLabel.text = [self.ringtonesArray objectAtIndex:indexPath.row];
		if ([cell.textLabel.text isEqualToString:self.toneString])
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone)
	{
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		self.toneString = nil;
		self.toneString = [self.ringtonesArray objectAtIndex:indexPath.row];
		CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:[[RINGTONE stringByAppendingString:[NSString stringWithFormat:@"/%@", self.toneString]] stringByAppendingPathExtension:@"caf"]];
		SystemSoundID lowPower;
		AudioServicesCreateSystemSoundID(url, &lowPower);
		AudioServicesPlaySystemSound(lowPower);

		for (int i = 0; i < [self.ringtonesArray count]; i++)
		{
			if (![[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].textLabel.text isEqualToString:self.toneString])
			{
				[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}
	else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
	{
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
		self.toneString = nil;
		self.toneString = @"";
	}
	[self saveConfig];
}

- (void)saveConfig
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"update lpb set %@ = '%@' where level='%@'", self.typeString, self.toneString, self.levelString];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@ , %s", sql, error);

		sqlite3_close(database);
	}

	for (UITableViewController *controller in self.navigationController.viewControllers)
	{
		if([controller isKindOfClass:[PercentageViewController class]])
		{
			[controller loadView];
			[controller.tableView reloadData];
		}
	}
}

- (void)loadAllRingtones
{
	self.ringtonesArray = nil;
	self.ringtonesArray = [NSMutableArray arrayWithCapacity:66];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *contentsArray = [fileManager contentsOfDirectoryAtPath:RINGTONE error:nil];
	for (NSString *file in contentsArray)
	{
		if ([[file pathExtension] isEqualToString:@"caf"])
			[self.ringtonesArray addObject:[file stringByDeletingPathExtension]];
	}
}

- (void)dealloc
{
	[levelString release];
	[toneString release];
	[typeString release];
	[ringtonesArray release];
	[super dealloc];
}
@end
