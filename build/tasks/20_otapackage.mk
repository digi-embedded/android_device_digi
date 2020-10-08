ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

# Copy boot.img into OTA generation folder, so that it gets used for the OTA
# package
OTA_BOOT_IMAGE := $(patsubst %.zip,%,$(BUILT_TARGET_FILES_PACKAGE))/IMAGES/boot.img
$(OTA_BOOT_IMAGE) : $(INSTALLED_BOOTIMAGE_TARGET) $(BUILT_TARGET_FILES_PACKAGE) | $(ACP)
	@echo "Copying: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(ACP) -fp $< $@

$(INTERNAL_OTA_PACKAGE_TARGET): $(OTA_BOOT_IMAGE)

endif
