LOCALCONF_MK := localconf.mk

-include $(LOCALCONF_MK)

# Some handy variables to be used in the rest of makefiles ('1' if enabled, empty otherwise)
export TF_SIGN_ENABLED := $(and $(findstring $(strip $(TRUSTFENCE_ENABLE:"%"=%)),1),$(findstring $(strip $(TRUSTFENCE_SIGN:"%"=%)),1))
export TF_ENCRYPT_ENABLED := $(and $(findstring $(strip $(TF_SIGN_ENABLED)),1),$(if $(findstring $(strip $(TRUSTFENCE_DEK_PATH:"%"=%))X,0X),,1))
export TF_FS_ENCRYPT_ENABLED := $(and $(findstring $(strip $(TRUSTFENCE_ENABLE:"%"=%)),1),$(findstring $(strip $(TRUSTFENCE_ENCRYPT_USERDATA:"%"=%)),1))

# Variables needed to sign/encrypt artifacts
ifeq ($(strip $(TF_SIGN_ENABLED)),1)
export CONFIG_SIGN_KEYS_PATH := $(TRUSTFENCE_SIGN_KEYS_PATH:"%"=%)
export CONFIG_KEY_INDEX := $(TRUSTFENCE_KEY_INDEX:"%"=%)
endif
ifeq ($(strip $(TF_ENCRYPT_ENABLED)),1)
export CONFIG_DEK_PATH := $(TRUSTFENCE_DEK_PATH:"%"=%)
endif

# Path definition of some tools used in other makefiles and scripts
export TF_SIGN_ARTIFACT := $(HOST_OUT_EXECUTABLES)/trustfence-sign-artifact.sh
export TF_SIGN_UBOOT := $(HOST_OUT_EXECUTABLES)/trustfence-sign-uboot.sh

# Rule to build and deploy TF tools regardless on TF configuration in the config makefile
.PHONY: trustfence-sign-tools
trustfence-sign-tools: $(TF_SIGN_ARTIFACT) $(TF_SIGN_UBOOT)
