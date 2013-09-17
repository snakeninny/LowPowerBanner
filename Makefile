export ARCHS = armv7
export TARGET = iphone:latest:4.3

include theos/makefiles/common.mk

TWEAK_NAME = LowPowerBanner
LowPowerBanner_FILES = Tweak.xm LPBAction.m 
LowPowerBanner_FRAMEWORKS = CoreFoundation UIKit  Foundation QuartzCore AVFoundation AudioToolbox
LowPowerBanner_PRIVATE_FRAMEWORKS = BulletinBoard
LowPowerBanner_LDFLAGS = -lz -lsqlite3.0

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)cp -r PreferenceBundles $(THEOS_STAGING_DIR)/Library$(ECHO_END)
	$(ECHO_NOTHING)cp -r PreferenceLoader $(THEOS_STAGING_DIR)/Library$(ECHO_END)
