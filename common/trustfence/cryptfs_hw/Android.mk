-include $(TOPDIR)vendor/digi/trustfence/src_available.mk

ifneq ($(TRUSTFENCE_SRC_AVAILABLE),true)

LOCAL_PATH := $(call my-dir)

# Copy libcryptfs_hw to /vendor/lib/
include $(CLEAR_VARS)
LOCAL_MODULE := libcryptfs_hw
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)

endif
