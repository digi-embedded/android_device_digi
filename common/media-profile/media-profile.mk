LOCAL_PATH := $(call my-dir)


#for video recoder profile setting
include $(CLEAR_VARS)

ifeq ($(BOARD_HAVE_VPU), true)

ifeq ($(BOARD_HAVE_USB_CAMERA),true)
LOCAL_SRC_FILES := media_profiles_480p.xml
endif

ifeq ($(BOARD_SOC_TYPE),IMX8Q)
LOCAL_SRC_FILES :=  media_profiles_720p.xml
endif

ifeq ($(BOARD_SOC_TYPE),IMX8MM)
LOCAL_SRC_FILES :=  media_profiles_8mm.xml
endif

else
LOCAL_SRC_FILES := media_profiles_qvga.xml
endif

LOCAL_MODULE := media_profiles_V1_0.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)

