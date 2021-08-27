LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	chat.c 

LOCAL_SHARED_LIBRARIES := \
	libcutils libc

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/include

LOCAL_CFLAGS := -DANDROID_CHANGES -DTERMIOS -DSIGTYPE=void -UNO_SLEEP -DFNDELAY=O_NDELAY -Wno-unused-parameter -Wno-unused-const-variable
LOCAL_MODULE_PATH := $(TARGET_OUT_EXECUTABLES)
LOCAL_MODULE:= chat

include $(BUILD_EXECUTABLE)
