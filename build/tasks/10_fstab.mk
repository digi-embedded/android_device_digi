ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

INSTALLED_FSTABS_TARGET := \
	$(TARGET_ROOT_OUT)/fstab.digi \
	$(TARGET_ROOT_OUT)/fstab.digi.sd

ifeq ($(strip $(TF_FS_ENCRYPT_ENABLED:"%"=%)),1)
TF_ENCRYPT_SEDFILTER := \%^/dev/block%s/encryptable=/check,forceencrypt=/g
endif

.PHONY: fstabs
fstabs: $(INSTALLED_FSTABS_TARGET)

$(INSTALLED_FSTABS_TARGET): $(wildcard $(LOCALCONF_MK))
	sed -e '$(TF_ENCRYPT_SEDFILTER)' device/digi/$(TARGET_PRODUCT)/$(notdir $@) > $@

$(INSTALLED_RAMDISK_TARGET): $(INSTALLED_FSTABS_TARGET)

endif
