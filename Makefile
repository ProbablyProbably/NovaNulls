THEOS ?= $(HOME)/theos
TARGET := iphone:clang:latest:15.5
ARCHS := arm64
INSTALL_TARGET_PROCESSES := Nulls Brawl

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NovaModMenu
NovaModMenu_FILES = Sources/NovaMenu.mm
NovaModMenu_FRAMEWORKS = UIKit UniformTypeIdentifiers
NovaModMenu_LIBRARIES = z
NovaModMenu_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
NovaModMenu_CCFLAGS = -std=c++17
NovaModMenu_LDFLAGS = -Wl,-undefined,dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk
