ifeq (,$(filter true, $(TARGET_NO_KERNEL) $(TARGET_NO_RECOVERY)))

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_URAMDISK_RECOVERY_TARGET := $(PRODUCT_OUT)/uramdisk-recovery.img

# 1KB blocks for mkfs.vfat
RECOVERYIMAGE_BLOCKS := $(shell expr $(BOARD_RECOVERYIMAGE_PARTITION_SIZE) / 1024)

# Recovery image included files
RECOVERYIMAGE_FILES := $(KERNEL_IMAGE_NAME)
RECOVERYIMAGE_FILES += $(shell echo $(TARGET_BOARD_DTS_CONFIG) | sed -e "s,[^: ]\+:,$(KERNEL_OUT)/,g")
RECOVERYIMAGE_FILES += $(INSTALLED_BOOTSCRIPT_TARGET)
RECOVERYIMAGE_FILES += $(INSTALLED_URAMDISK_RECOVERY_TARGET)

$(INSTALLED_RECOVERYIMAGE_TARGET): $(INSTALLED_BOOTSCRIPT_TARGET)
	$(call pretty,"Target DEA recovery image: $@")
	$(call build-recoveryimage-target, $@)
	# Remove android type recovery images
	rm -f $(patsubst %.img,%*.img,$@)
	$(MKIMAGE) -A $(TARGET_ARCH) -O linux -T ramdisk -n "Android U-Boot recovery ramdisk" -d $(recovery_ramdisk) $(INSTALLED_URAMDISK_RECOVERY_TARGET)
	rm -f $@ && mkfs.vfat -s 1 -n "RECOVERY" -S 512 -C $@ $(RECOVERYIMAGE_BLOCKS)
	$(FAT16COPY) $@ $(RECOVERYIMAGE_FILES)
	#
	# Truncate VFAT recovery image:
	#   - size of files + 10% extra space (in bytes)
	#   - u-boot writes 512 bytes sectors so truncate at a sector boundary
	#
	RECOVERYIMAGE_FILES_SIZE="$$(($$(du -bc $(RECOVERYIMAGE_FILES) | tail -n1 | cut -f1) * (100 + 10) / 100))"; \
	truncate -s $$((((RECOVERYIMAGE_FILES_SIZE + 511) / 512) * 512)) $@

endif
