export ARCHS = armv7
export TARGET = iphone:latest:4.3

include theos/makefiles/common.mk

BUNDLE_NAME = LowPowerBanner
LowPowerBanner_FILES = LowPowerBannerListController.mm IconViewController.m PercentageViewController.m RingtoneViewController.m TriggerViewController.m
LowPowerBanner_INSTALL_PATH = /Library/PreferenceBundles
LowPowerBanner_FRAMEWORKS = UIKit CoreGraphics AudioToolBox QuartzCore Foundation
LowPowerBanner_PRIVATE_FRAMEWORKS = Preferences
LowPowerBanner_LDFLAGS = -lz -lsqlite3.0

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LowPowerBanner.plist$(ECHO_END)
