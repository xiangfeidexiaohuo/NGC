export TARGET = iphone:clang:16.5:16.0
export THEOS_DEVICE_IP = 192.168.86.47
export THEOS_PACKAGE_SCHEME=rootless
export FINALPACKAGE=1
INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotificationsGroupCount

NotificationsGroupCount_FILES = Tweak.xm NGCBadgeView.m
NotificationsGroupCount_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += notificationsgroupcount
include $(THEOS_MAKE_PATH)/aggregate.mk
