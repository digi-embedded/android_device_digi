ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)

# Process "boot.img" to generate a FAT image suitable for the OTA package
OTA_BOOT_IMAGE := $(patsubst %.zip,%,$(BUILT_TARGET_FILES_PACKAGE))/IMAGES/boot.img
$(OTA_BOOT_IMAGE): $(INSTALLED_BOOTIMAGE_TARGET) $(BUILT_TARGET_FILES_PACKAGE) | $(ACP) $(SIMG2IMG)
	@echo "Copying: $@"
	$(hide) mkdir -p $(dir $@)
ifeq ($(strip $(TARGET_DEA_SPARSE_VFAT_IMAGES)),true)
	$(hide) $(SIMG2IMG) $< $@
else
	$(hide) $(ACP) -fp $< $@
endif
	#
	# Truncate VFAT boot image for OTA:
	#
	# The OTA package generation script has some checks to error out if the size
	# of the image is >= 99% of the partition size of warn if the image is >=95%
	# (see build/make/tools/releasetools/common.py)
	#
	# BOOTIMAGE_FILES is defined in '20_bootimage.mk'
	#   - size of files + 10% extra space (in bytes)
	#   - u-boot writes 512 bytes sectors so truncate at a sector boundary
	#
	BOOTIMAGE_FILES_SIZE="$$(($$(du -bc $(BOOTIMAGE_FILES) | tail -n1 | cut -f1) * (100 + 10) / 100))"; \
	truncate -s $$((((BOOTIMAGE_FILES_SIZE + 511) / 512) * 512)) $@

$(INTERNAL_OTA_PACKAGE_TARGET): $(OTA_BOOT_IMAGE)

endif
