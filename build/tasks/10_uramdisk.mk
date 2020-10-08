ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_URAMDISK_TARGET := $(PRODUCT_OUT)/uramdisk.img

.PHONY: uramdisk
uramdisk: $(INSTALLED_URAMDISK_TARGET)

$(INSTALLED_URAMDISK_TARGET): $(INSTALLED_RAMDISK_TARGET) $(wildcard $(LOCALCONF_MK)) | $(MKIMAGE) $(if $(TF_SIGN_ENABLED),$(TF_SIGN_ARTIFACT))
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A arm -O linux -T ramdisk -n "Android U-Boot ramdisk" -d $< $@
	$(hide) if [ "$$TF_SIGN_ENABLED" = "1" ]; then \
		$(TF_SIGN_ARTIFACT) -p ccimx6 -i $@ $(basename $@)-signed$(suffix $@); \
		mv $(basename $@)-signed$(suffix $@) $@; \
	fi

endif
