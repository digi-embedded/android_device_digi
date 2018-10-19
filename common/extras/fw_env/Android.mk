#
# Copyright (C) 2018 Digi International Inc., All Rights Reserved
#
# This software contains proprietary and confidential information of Digi.
# International Inc. By accepting transfer of this copy, Recipient agrees
# to retain this software in confidence, to prevent disclosure to others,
# and to make no use of this software other than that for which it was
# delivered. This is an unpublished copyrighted work of Digi International
# Inc. Except as permitted by federal law, 17 USC 117, copying is strictly
# prohibited.
#
# Restricted Rights Legend
#
# Use, duplication, or disclosure by the Government is subject to restrictions
# set forth in sub-paragraph (c)(1)(ii) of The Rights in Technical Data and
# Computer Software clause at DFARS 252.227-7031 or subparagraphs (c)(1) and
# (2) of the Commercial Computer Software - Restricted Rights at 48 CFR
# 52.227-19, as applicable.
#
# Digi International Inc. 11001 Bren Road East, Minnetonka, MN 55343
#

LOCAL_PATH:= $(call my-dir)

#
# fw_printenv
#
include $(CLEAR_VARS)
LOCAL_MODULE := fw_printenv
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_SYMLINKS:= fw_setenv
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

#
# fw_env.config
#
include $(CLEAR_VARS)
LOCAL_MODULE := fw_env.config
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)
