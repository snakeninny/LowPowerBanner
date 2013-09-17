#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sqlite3.h>
#import "substrate.h"
#import "LPBAction.h"
#import "LowPowerBanner.h"

#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]
#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define RINGTONE [DOCUMENT stringByAppendingPathComponent:@"/Ringtones"]
#define ICON [DOCUMENT stringByAppendingPathComponent:@"/Icons"]

extern NSString *iconString;
extern BOOL shouldReplaceBannerIcon;

static NSInteger lastLevel = -60;
static NSMutableArray *levelArray = nil;
static void LoadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void (*original_AudioServicesPlaySystemSound)(int inSystemSoundID);
static void CopySettingsToLibrary();

static void LoadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[levelArray release];
	levelArray = nil;
	levelArray = [[NSMutableArray alloc] initWithCapacity:106];

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = @"select level from lpb";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{             
				char *chLevel = (char *)sqlite3_column_text(statement, 0);
				if (chLevel != nil)
				{
					NSNumber *levelNumber = [NSNumber numberWithInt:atoi(chLevel)];
					[levelArray addObject:levelNumber];
				}
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"LPBERROR: %@ , %s", sql, error);

		sqlite3_close(database);
	}
}

static void CopySettingsToLibrary()
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:RINGTONE] && ![fileManager fileExistsAtPath:ICON])
	{
		[fileManager removeItemAtPath:DOCUMENT error:nil];
		[fileManager createDirectoryAtPath:DOCUMENT withIntermediateDirectories:YES attributes:nil error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/lpb.db"] toPath:DATABASE error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Ringtones"] toPath:RINGTONE error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] toPath:ICON error:nil];
	}

	LoadSettings(nil, nil, nil, nil, nil);
}

static void replaced_AudioServicesPlaySystemSound(int inSystemSoundID)
{
	if (inSystemSoundID == 1006) // low_power.caf
	{
		// do nothing
	}
	else if (inSystemSoundID == 1106 && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound) // beep_beep.caf
	{
		// do nothing
	}
	else original_AudioServicesPlaySystemSound(inSystemSoundID);
}

%group iOS5Hook

%hook SBBulletinBannerItem
- (id)iconImage
{
	id result = %orig;

	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return bannerIconImage;
	}

	return result;
}
%end

%hook SBStatusBarDataManager
- (void)_updateBatteryPercentItem
{
	%orig;

	int level = MSHookIvar<_data>(self, "_data").batteryCapacity;

	if ([levelArray indexOfObject:[NSNumber numberWithInt:level]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		if (lastLevel + 1 == level) // Charging
			[action actionOfKind:@"up" atBatteryLevel:level];
		else if (lastLevel - 1 == level) // Draining
			[action actionOfKind:@"down" atBatteryLevel:level];
		[action release];			
	}

	lastLevel = level;
}
%end

%hook SBAlertItemsController
- (void)activateAlertItem:(id)item
{
	if ([item isKindOfClass:[objc_getClass("SBLowPowerAlertItem") class]])
		return;
	%orig;
}
%end

%hook SBUIController
- (void)ACPowerChanged
{
	%orig;

	if ([self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:0];
		[action release];	
	}
	else if (![self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:-1]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:-1];
		[action release];	
	}
}
%end

%end // end of iOS5Hook

%group iOS6Hook

%hook SBBulletinBannerItem
- (id)iconImage
{
	id result = %orig;

	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return bannerIconImage;
	}

	return result;
}
%end

%hook SBStatusBarDataManager
- (void)_updateBatteryItems
{
	%orig;

	int level = [[objc_getClass("SBUIController") sharedInstance] curvedBatteryCapacityAsPercentage];

	if ([levelArray indexOfObject:[NSNumber numberWithInt:level]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		if (lastLevel + 1 == level) // Charging
			[action actionOfKind:@"up" atBatteryLevel:level];
		else if (lastLevel - 1 == level) // Draining
			[action actionOfKind:@"down" atBatteryLevel:level];
		[action release];			
	}

	lastLevel = level;
}
%end

%hook SBAlertItemsController
- (void)activateAlertItem:(id)item
{
	if ([item isKindOfClass:[objc_getClass("SBLowPowerAlertItem") class]])
		return;
	%orig;
}
%end

%hook SBUIController
- (void)ACPowerChanged
{
	%orig;

	if ([self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:0];
		[action release];	
	}
	else if (![self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:-1]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:-1];
		[action release];	
	}
}
%end

%end // end of iOS6Hook

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	CopySettingsToLibrary();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, LoadSettings, CFSTR("com.naken.lowpowerbanner.loadsettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	MSHookFunction((void **)AudioServicesPlaySystemSound, (void **)replaced_AudioServicesPlaySystemSound, (void **)&original_AudioServicesPlaySystemSound);

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) %init(iOS5Hook);
	if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) %init(iOS6Hook);

	[pool drain];
}
