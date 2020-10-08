ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)

# 1KB blocks for mkfs.vfat
BOOTIMAGE_BLOCKS := $(shell expr $(BOARD_BOOTIMAGE_PARTITION_SIZE) / 1024)

# Boot image included files
BOOTIMAGE_FILES := $(TARGET_PREBUILT_KERNEL_ZIMAGE)
BOOTIMAGE_FILES += $(shell echo $(TARGET_BOARD_DTS_CONFIG) | sed -e "s,[^: ]\+:,$(KERNEL_OUT)/,g")
BOOTIMAGE_FILES += $(INSTALLED_BOOTSCRIPT_TARGET)
BOOTIMAGE_FILES += $(INSTALLED_URAMDISK_TARGET)

$(INSTALLED_BOOTIMAGE_TARGET): $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_BOOTSCRIPT_TARGET) $(INSTALLED_URAMDISK_TARGET)
	$(call pretty,"Target DEA boot image: $@")
	rm -f $@ && mkfs.vfat -s 1 -n "BOOTIMAGE" -S 512 -C $@ $(BOOTIMAGE_BLOCKS)
	$(FAT16COPY) $@ $(BOOTIMAGE_FILES)
	#
	# Truncate VFAT boot image:
	#   - size of files + 10% extra space (in bytes)
	#   - u-boot writes 512 bytes sectors so truncate at a sector boundary
	#
	BOOTIMAGE_FILES_SIZE="$$(($$(du -bc $(BOOTIMAGE_FILES) | tail -n1 | cut -f1) * (100 + 10) / 100))"; \
	truncate -s $$((((BOOTIMAGE_FILES_SIZE + 511) / 512) * 512)) $@

endif

endif
