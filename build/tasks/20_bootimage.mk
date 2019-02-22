ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)

# KERNEL_NAME is defined in device's BoardConfig.mk
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_BIN := $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/$(KERNEL_NAME)

# 1KB blocks for mkfs.vfat
BOOTIMAGE_BLOCKS := $(shell expr $(BOARD_BOOTIMAGE_PARTITION_SIZE) / 1024)

# Boot image included files
BOOTIMAGE_FILES := $(KERNEL_BIN)
BOOTIMAGE_FILES += $(KERNEL_DTBS)
BOOTIMAGE_FILES += $(INSTALLED_BOOTSCRIPT_TARGET)
BOOTIMAGE_FILES += $(INSTALLED_URAMDISK_TARGET)

$(INSTALLED_BOOTIMAGE_TARGET): $(INTERNAL_BOOTIMAGE_FILES) $(KERNEL_DTBS_MAKETARGET) $(INSTALLED_BOOTSCRIPT_TARGET) $(INSTALLED_URAMDISK_TARGET)
	$(call pretty,"Target DEA boot image: $@")
	rm -f $@ && mkfs.vfat -n "BOOTIMAGE" -S 512 -C $@ $(BOOTIMAGE_BLOCKS)
	$(FAT16COPY) $@ $(BOOTIMAGE_FILES)
	#
	# Truncate VFAT boot image:
	#   - size of files + 10% extra space (in bytes)
	#   - u-boot writes 512 bytes sectors so truncate at a sector boundary
	#
	BOOTIMAGE_FILES_SIZE="$$(($$(du -bc $(BOOTIMAGE_FILES) | tail -n1 | cut -f1) * (100 + 10) / 100))"; \
	truncate -s $$((((BOOTIMAGE_FILES_SIZE + 511) / 512) * 512)) $@

endif
