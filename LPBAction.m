#import "LPBAction.h"
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sqlite3.h>
#import "LowPowerBanner.h"

#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]
#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define RINGTONE [DOCUMENT stringByAppendingPathComponent:@"/Ringtones"]
#define ICON [DOCUMENT stringByAppendingPathComponent:@"/Icons"]

NSString *iconString;
BOOL shouldReplaceBannerIcon;

@implementation LPBAction
- (void)actionOfKind:(NSString *)kind atBatteryLevel:(NSInteger)batteryLevel
{
	NSString *toneString = @"";
	NSString *vibString = @"";
	NSString *titleString = @"";
	NSString *messageString = @"";

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select %@tone, %@vib, %@title, %@msg, %@icon from lpb where level = %d", kind, kind, kind, kind, kind, batteryLevel];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{             
				char *chTone = (char *)sqlite3_column_text(statement, 0);
				toneString = chTone ? [NSString stringWithUTF8String:chTone] : @"";

				char *chVib = (char *)sqlite3_column_text(statement, 1);
				vibString = chVib ? [NSString stringWithUTF8String:chVib] : @"";

				char *chTitle = (char *)sqlite3_column_text(statement, 2);
				titleString = chTitle ? [NSString stringWithUTF8String:chTitle] : @"";

				char *chMessage = (char *)sqlite3_column_text(statement, 3);
				messageString = chMessage ? [NSString stringWithUTF8String:chMessage] : @"";

				char *chIcon = (char *)sqlite3_column_text(statement, 4);
				iconString = chIcon ? [NSString stringWithUTF8String:chIcon] : @"";
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"LPBERROR: %@ , %s",sql,error);

		sqlite3_close(database);
	}

	/* Ringtone */
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:[[RINGTONE stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", toneString]] stringByAppendingPathExtension:@"caf"]];
	SystemSoundID lowPower;
	AudioServicesCreateSystemSoundID(url, &lowPower);
	AudioServicesPlaySystemSound(lowPower);

	/* Vibrate */
	if ([vibString isEqualToString:@"1"])
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

	if ([titleString length] == 0 && [messageString length] == 0) // Leave Title and Message empty to disable the banner
		return;

	SBAwayController *awayController = [objc_getClass("SBAwayController") sharedAwayController];
	if (![awayController isLocked])
	{
		BBBulletinRequest *bulletin = [[objc_getClass("BBBulletinRequest") alloc] init];
		bulletin.sectionID = @"com.naken.lowpowerbanner";
		bulletin.bulletinID = @"com.naken.lowpowerbanner";
		bulletin.publisherBulletinID = @"com.naken.lowpowerbanner";
		bulletin.recordID = @"com.naken.lowpowerbanner";
		bulletin.title = titleString;
		bulletin.message = messageString;
		bulletin.date = [NSDate date];
		bulletin.lastInterruptDate = [NSDate date];

		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
		{
			bulletin.primaryAttachmentType = 0;

			SBBulletinBannerItem *bannerItem = [objc_getClass("SBBulletinBannerItem") itemWithBulletin:bulletin];
			shouldReplaceBannerIcon = YES;
			[[objc_getClass("SBBulletinBannerController") sharedInstance] _presentBannerForItem:bannerItem];
		}
		else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1)
		{
			SBBulletinBannerItem *bannerItem = [objc_getClass("SBBulletinBannerItem") itemWithBulletin:bulletin andObserver:nil];
			shouldReplaceBannerIcon = YES;
			[[objc_getClass("SBBannerController") sharedInstance] _presentBannerView:[[objc_getClass("SBBulletinBannerController") sharedInstance] newBannerViewForItem:bannerItem]];
		}
		[bulletin release];

		/* Icon */
		// Done in Tweak.xm by hooking into - (UIImage *)iconImage
	}
}
@end
