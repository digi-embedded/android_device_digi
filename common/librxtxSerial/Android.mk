#
# Copyright 2019, Digi International Inc.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

LOCAL_PATH:= $(call my-dir)

# Build the java code
# ============================================================
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := RXTXcomm
LOCAL_REQUIRED_MODULES := librxtxSerial
LOCAL_SRC_FILES := $(call all-java-files-under, java)

include $(BUILD_JAVA_LIBRARY)

# ========================================================
# librxtx
# ========================================================
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE:= librxtxSerial


LOCAL_SRC_FILES := \
	lib/fuserImp.c \
	lib/SerialImp.c

LOCAL_C_INCLUDES += \
	dalvik/libnativehelper/include/nativehelper \
	$(JNI_H_INCLUDE) \
	$(KERNEL_HEADERS) \
	$(LOCAL_PATH)/lib

LOCAL_CFLAGS += \
	-fPIC \
	-D_GNU_SOURCE \
	-Wno-unused-variable \
	-Wno-unused-parameter \
	-Wno-unused-function \
	-Wno-incompatible-pointer-types

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := libdl liblog

include $(BUILD_SHARED_LIBRARY)

