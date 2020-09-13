LOCAL_PATH := $(call my-dir)

# Handy CST paths
CST_TOPDIR := cst-3.1.0
CST_BASEDIR := $(LOCAL_PATH)/$(CST_TOPDIR)
CST_LIBDIR := $(CST_BASEDIR)/linux64/lib
CST_SRCDIR := $(CST_BASEDIR)/code/back_end/src
CST_INCDIR := $(CST_BASEDIR)/code/back_end/hdr

# As of Android Oreo openssl is not included anymore, so we need to use host's
# compiler and openssl's crypto library to relink the binary.
$(CST_SRCDIR)/cst:
	gcc -o $@ -I $(CST_INCDIR) -L $(CST_LIBDIR) $(CST_SRCDIR)/*.c -lfrontend -lcrypto

# cst binary
# ============================================================
include $(CLEAR_VARS)
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE := cst
LOCAL_SRC_FILES := $(CST_TOPDIR)/code/back_end/src/cst
include $(BUILD_PREBUILT)

# srktool binary
# ============================================================
include $(CLEAR_VARS)
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE := srktool
LOCAL_SRC_FILES := $(CST_TOPDIR)/linux64/bin/srktool
include $(BUILD_PREBUILT)

# trustfence-gen-pki.sh script
# ============================================================
$(HOST_OUT_EXECUTABLES)/trustfence-gen-pki.sh: | \
	$(HOST_OUT_EXECUTABLES)/openssl.cnf \
	$(HOST_OUT_EXECUTABLES)/v3_ca.cnf \
	$(HOST_OUT_EXECUTABLES)/v3_usr.cnf

include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES := \
	trustfence-gen-pki:$(CST_TOPDIR)/keys/hab4_pki_tree.sh
include $(BUILD_HOST_PREBUILT)

# openssl config files
# ============================================================
include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES :=  \
	openssl:$(CST_TOPDIR)/ca/openssl.cnf \
	v3_ca:$(CST_TOPDIR)/ca/v3_ca.cnf \
	v3_usr:$(CST_TOPDIR)/ca/v3_usr.cnf
include $(BUILD_HOST_PREBUILT)
