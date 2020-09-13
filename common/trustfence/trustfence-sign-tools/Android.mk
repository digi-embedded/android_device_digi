LOCAL_PATH := $(call my-dir)

# trustfence-sign-artifact.sh script
# ============================================================
$(HOST_OUT_EXECUTABLES)/trustfence-sign-artifact.sh: | \
	$(HOST_OUT_EXECUTABLES)/trustfence-gen-pki.sh \
	$(HOST_OUT_EXECUTABLES)/srktool \
	$(HOST_OUT_EXECUTABLES)/cst \
	$(HOST_OUT_EXECUTABLES)/csf_templates/encrypt_hab \
	$(HOST_OUT_EXECUTABLES)/csf_templates/sign_hab

include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES := trustfence-sign-artifact.sh
include $(BUILD_HOST_PREBUILT)

# CSF kernel sign and encrypt templates
# ============================================================
include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES :=  \
	csf_templates/encrypt_hab:csf_templates/encrypt_hab \
	csf_templates/sign_hab:csf_templates/sign_hab
include $(BUILD_HOST_PREBUILT)
