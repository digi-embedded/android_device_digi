LOCAL_PATH := $(call my-dir)

include $(CONFIG_REPO_PATH)/common/build/dtbo.mk
include device/nxp/common/build/imx-recovery.mk
include device/nxp/common/build/gpt.mk
include $(CONFIG_REPO_PATH)/common/media-profile/media-profile.mk

-include $(IMX_MEDIA_CODEC_XML_PATH)/mediacodec-profile/mediacodec-profile.mk
