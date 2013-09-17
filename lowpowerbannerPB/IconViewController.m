#import "IconViewController.h"
#import "PercentageViewController.h"
#import "LowPowerBannerListController.h"
#import <sqlite3.h>
#import <AudioToolbox/AudioToolbox.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define ICON [DOCUMENT stringByAppendingPathComponent:@"/Icons"]
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

@implementation IconViewController

@synthesize levelString;
@synthesize typeString;
@synthesize iconString;
@synthesize iconsArray;

- (IconViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
		self.title = NSLocalizedStringFromTableInBundle(@"Icon", nil, BUNDLE, @"Icon");
	return self;
}

- (void)loadView
{
	[self loadAllIcons];
	[super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.iconsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.textLabel.text = [self.iconsArray objectAtIndex:indexPath.row];
		cell.imageView.image = [self compressImage:[self loadImageAtIndex:indexPath.row]];
		if ([cell.textLabel.text isEqualToString:self.iconString])
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
		self.iconString = nil;
		self.iconString = [self.iconsArray objectAtIndex:indexPath.row];

		for (int i = 0; i < [self.iconsArray count]; i++)
		{
			if (![[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].textLabel.text isEqualToString:self.iconString])
			{
				[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}
	else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
	{
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
		self.iconString = nil;
		self.iconString = @"";
	}
	[self saveConfig];
}

- (void)saveConfig
{
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"update lpb set %@ = '%@' where level='%@'", self.typeString, self.iconString, self.levelString];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@ , %s",sql, error);

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

- (UIImage *)loadImageAtIndex:(NSUInteger)index
{
	UIImage *image = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingString:[NSString stringWithFormat:@"/%@", [self.iconsArray objectAtIndex:index]]] stringByAppendingPathExtension:@"png"]];
	return image;
}

- (UIImage *)compressImage:(UIImage *)image
{
	CGSize size = {36.0f, 36.0f};
	UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)loadAllIcons
{
	self.iconsArray = nil;
	self.iconsArray = [NSMutableArray arrayWithCapacity:66];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *contentsArray = [fileManager contentsOfDirectoryAtPath:ICON error:nil];
	for (NSString *file in contentsArray)
	{
		if ([[file pathExtension] isEqualToString:@"png"])
			[self.iconsArray addObject:[file stringByDeletingPathExtension]];
	}
}

- (void)dealloc
{
	[levelString release];
	[iconString release];
	[typeString release];
	[iconsArray release];
	[super dealloc];
}
@end
