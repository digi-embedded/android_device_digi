# Copy dtb files from kernel output dir to the provided destination.
# $(1) - Destination directory
define copy-dtb-files
$(foreach dtb,$(KERNEL_DTBS), \
  cp -fp $(dtb) $(1)/$(notdir $(dtb));)
endef

# $(1) - Image to copy
# $(2) - List of files that includes the image to copy
define copy-vfat-image
  $(if $(filter true,$(strip $(TARGET_DEA_SPARSE_VFAT_IMAGES))), \
      $(hide) $(SIMG2IMG) $(1) $(zip_root)/IMAGES/$(notdir $(1)),
      $(hide) cp -fp $(1) $(zip_root)/IMAGES/$(notdir $(1)))
  #
  # Truncate VFAT boot/recovery image for OTA
  #
  # The OTA package generation script has some checks to error out if the size
  # of the image is >= 99% of the partition size of warn if the image is >=95%
  # (see build/make/tools/releasetools/common.py)
  #
  # BOOTIMAGE_FILES is defined in '20_bootimage.mk'
  # RECOVERYIMAGE_FILES is defined in '20_recoveryimage.mk'
  #   - size of files + 10% extra space (in bytes)
  #   - u-boot writes 512 bytes sectors so truncate at a sector boundary
  #
  IMAGE_FILES_SIZE="$$(($$(du -bc $(2) | tail -n1 | cut -f1) * (100 + 10) / 100))"; \
  truncate -s $$((((IMAGE_FILES_SIZE + 511) / 512) * 512)) $(zip_root)/IMAGES/$(notdir $(1))
endef

OTATOOLS += build/tools/fat16copy.py
OTATOOLS += $(HOST_OUT_EXECUTABLES)/mkimage

# Depending on the various images guarantees that the underlying
# directories are up-to-date.
$(BUILT_TARGET_FILES_PACKAGE): \
		$(INSTALLED_BOOTIMAGE_TARGET) \
		$(INSTALLED_RADIOIMAGE_TARGET) \
		$(INSTALLED_RECOVERYIMAGE_TARGET) \
		$(FULL_SYSTEMIMAGE_DEPS) \
		$(INSTALLED_USERDATAIMAGE_TARGET) \
		$(INSTALLED_CACHEIMAGE_TARGET) \
		$(INSTALLED_VENDORIMAGE_TARGET) \
		$(INSTALLED_PRODUCTIMAGE_TARGET) \
		$(INSTALLED_VBMETAIMAGE_TARGET) \
		$(INSTALLED_DTBOIMAGE_TARGET) \
		$(INTERNAL_SYSTEMOTHERIMAGE_FILES) \
		$(INSTALLED_ANDROID_INFO_TXT_TARGET) \
		$(INSTALLED_KERNEL_TARGET) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SYSTEM_BASE_FS_PATH) \
		$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VENDOR_BASE_FS_PATH) \
		$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PRODUCT_BASE_FS_PATH) \
		$(SELINUX_FC) \
		$(APKCERTS_FILE) \
		$(SOONG_ZIP) \
		$(HOST_OUT_EXECUTABLES)/fs_config \
		$(HOST_OUT_EXECUTABLES)/imgdiff \
		$(HOST_OUT_EXECUTABLES)/bsdiff \
		$(BUILD_IMAGE_SRCS) \
		$(BUILT_VENDOR_MANIFEST) \
		$(BUILT_VENDOR_MATRIX) \
		| $(ACP)
	@echo "Package target files: $@"
	$(call create-system-vendor-symlink)
	$(call create-system-product-symlink)
	$(hide) rm -rf $@ $@.list $(zip_root)
	$(hide) mkdir -p $(dir $@) $(zip_root)
ifneq (,$(INSTALLED_RECOVERYIMAGE_TARGET)$(filter true,$(BOARD_USES_RECOVERY_AS_BOOT)))
	@# Components of the recovery image
	$(hide) mkdir -p $(zip_root)/$(PRIVATE_RECOVERY_OUT)
	$(hide) $(call package_files-copy-root, \
		$(TARGET_RECOVERY_ROOT_OUT),$(zip_root)/$(PRIVATE_RECOVERY_OUT)/RAMDISK)
ifdef INSTALLED_KERNEL_TARGET
	$(hide) cp $(INSTALLED_KERNEL_TARGET) $(zip_root)/$(PRIVATE_RECOVERY_OUT)/kernel
######### Copy device trees and boot script as components of the recovery image #############
ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)
	@# Copy device trees and boot script to RECOVERY
	$(hide) $(call copy-dtb-files, $(zip_root)/$(PRIVATE_RECOVERY_OUT))
	$(hide) cp $(PRODUCT_OUT)/boot.scr $(zip_root)/$(PRIVATE_RECOVERY_OUT)/boot.scr
endif
######################
endif
ifdef INSTALLED_2NDBOOTLOADER_TARGET
	$(hide) cp $(INSTALLED_2NDBOOTLOADER_TARGET) $(zip_root)/$(PRIVATE_RECOVERY_OUT)/second
endif
ifdef BOARD_INCLUDE_RECOVERY_DTBO
	$(hide) cp $(INSTALLED_DTBOIMAGE_TARGET) $(zip_root)/$(PRIVATE_RECOVERY_OUT)/recovery_dtbo
endif
ifdef INTERNAL_KERNEL_CMDLINE
	$(hide) echo "$(INTERNAL_KERNEL_CMDLINE)" > $(zip_root)/$(PRIVATE_RECOVERY_OUT)/cmdline
endif
ifdef BOARD_KERNEL_BASE
	$(hide) echo "$(BOARD_KERNEL_BASE)" > $(zip_root)/$(PRIVATE_RECOVERY_OUT)/base
endif
ifdef BOARD_KERNEL_PAGESIZE
	$(hide) echo "$(BOARD_KERNEL_PAGESIZE)" > $(zip_root)/$(PRIVATE_RECOVERY_OUT)/pagesize
endif
endif # INSTALLED_RECOVERYIMAGE_TARGET defined or BOARD_USES_RECOVERY_AS_BOOT is true
	@# Components of the boot image
	$(hide) mkdir -p $(zip_root)/BOOT
ifeq ($(BOARD_BUILD_SYSTEM_ROOT_IMAGE),true)
	$(hide) mkdir -p $(zip_root)/ROOT
	$(hide) $(call package_files-copy-root, \
		$(TARGET_ROOT_OUT),$(zip_root)/ROOT)
else
	$(hide) $(call package_files-copy-root, \
		$(TARGET_ROOT_OUT),$(zip_root)/BOOT/RAMDISK)
endif
	@# If we are using recovery as boot, this is already done when processing recovery.
ifneq ($(BOARD_USES_RECOVERY_AS_BOOT),true)
ifdef INSTALLED_KERNEL_TARGET
	$(hide) cp $(INSTALLED_KERNEL_TARGET) $(zip_root)/BOOT/kernel
######### Copy device trees and boot scripts as components of the boot image #############
ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)
	@# Copy device trees and boot script to BOOT
	$(hide) $(call copy-dtb-files, $(zip_root)/BOOT)
	$(hide) cp $(PRODUCT_OUT)/boot.scr $(zip_root)/BOOT/boot.scr
endif
######################
endif
ifdef INSTALLED_2NDBOOTLOADER_TARGET
	$(hide) cp $(INSTALLED_2NDBOOTLOADER_TARGET) $(zip_root)/BOOT/second
endif
ifdef INTERNAL_KERNEL_CMDLINE
	$(hide) echo "$(INTERNAL_KERNEL_CMDLINE)" > $(zip_root)/BOOT/cmdline
endif
ifdef BOARD_KERNEL_BASE
	$(hide) echo "$(BOARD_KERNEL_BASE)" > $(zip_root)/BOOT/base
endif
ifdef BOARD_KERNEL_PAGESIZE
	$(hide) echo "$(BOARD_KERNEL_PAGESIZE)" > $(zip_root)/BOOT/pagesize
endif
endif # BOARD_USES_RECOVERY_AS_BOOT
	$(hide) $(foreach t,$(INSTALLED_RADIOIMAGE_TARGET),\
	            mkdir -p $(zip_root)/RADIO; \
	            cp $(t) $(zip_root)/RADIO/$(notdir $(t));)
	@# Contents of the system image
	$(hide) $(call package_files-copy-root, \
		$(SYSTEMIMAGE_SOURCE_DIR),$(zip_root)/SYSTEM)
	@# Contents of the data image
	$(hide) $(call package_files-copy-root, \
		$(TARGET_OUT_DATA),$(zip_root)/DATA)
ifdef BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE
	@# Contents of the vendor image
	$(hide) $(call package_files-copy-root, \
		$(TARGET_OUT_VENDOR),$(zip_root)/VENDOR)
endif
ifdef BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE
	@# Contents of the product image
	$(hide) $(call package_files-copy-root, \
		$(TARGET_OUT_PRODUCT),$(zip_root)/PRODUCT)
endif
ifdef INSTALLED_SYSTEMOTHERIMAGE_TARGET
	@# Contents of the system_other image
	$(hide) $(call package_files-copy-root, \
		$(TARGET_OUT_SYSTEM_OTHER),$(zip_root)/SYSTEM_OTHER)
endif
	@# Extra contents of the OTA package
	$(hide) mkdir -p $(zip_root)/OTA
	$(hide) cp $(INSTALLED_ANDROID_INFO_TXT_TARGET) $(zip_root)/OTA/
ifneq ($(AB_OTA_UPDATER),true)
ifneq ($(built_ota_tools),)
	$(hide) mkdir -p $(zip_root)/OTA/bin
	$(hide) cp $(PRIVATE_OTA_TOOLS) $(zip_root)/OTA/bin/
endif
endif
	@# Files that do not end up in any images, but are necessary to
	@# build them.
	$(hide) mkdir -p $(zip_root)/META
	$(hide) cp $(APKCERTS_FILE) $(zip_root)/META/apkcerts.txt
ifneq ($(tool_extension),)
	$(hide) cp $(PRIVATE_TOOL_EXTENSION) $(zip_root)/META/
endif
	$(hide) echo "$(PRODUCT_OTA_PUBLIC_KEYS)" > $(zip_root)/META/otakeys.txt
	$(hide) cp $(SELINUX_FC) $(zip_root)/META/file_contexts.bin
	$(hide) echo "recovery_api_version=$(PRIVATE_RECOVERY_API_VERSION)" > $(zip_root)/META/misc_info.txt
	$(hide) echo "fstab_version=$(PRIVATE_RECOVERY_FSTAB_VERSION)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "arch=$(TARGET_ARCH)" >> $(zip_root)/META/misc_info.txt
ifdef BOARD_FLASH_BLOCK_SIZE
	$(hide) echo "blocksize=$(BOARD_FLASH_BLOCK_SIZE)" >> $(zip_root)/META/misc_info.txt
endif
ifdef BOARD_BOOTIMAGE_PARTITION_SIZE
	$(hide) echo "boot_size=$(BOARD_BOOTIMAGE_PARTITION_SIZE)" >> $(zip_root)/META/misc_info.txt
endif
ifeq ($(INSTALLED_RECOVERYIMAGE_TARGET),)
	$(hide) echo "no_recovery=true" >> $(zip_root)/META/misc_info.txt
endif
ifdef BOARD_INCLUDE_RECOVERY_DTBO
	$(hide) echo "include_recovery_dtbo=true" >> $(zip_root)/META/misc_info.txt
endif
ifdef BOARD_RECOVERYIMAGE_PARTITION_SIZE
	$(hide) echo "recovery_size=$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)" >> $(zip_root)/META/misc_info.txt
endif
ifdef TARGET_RECOVERY_FSTYPE_MOUNT_OPTIONS
	@# TARGET_RECOVERY_FSTYPE_MOUNT_OPTIONS can be empty to indicate that nothing but defaults should be used.
	$(hide) echo "recovery_mount_options=$(TARGET_RECOVERY_FSTYPE_MOUNT_OPTIONS)" >> $(zip_root)/META/misc_info.txt
else
	$(hide) echo "recovery_mount_options=$(DEFAULT_TARGET_RECOVERY_FSTYPE_MOUNT_OPTIONS)" >> $(zip_root)/META/misc_info.txt
endif
	$(hide) echo "tool_extensions=$(PRIVATE_TOOL_EXTENSIONS)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "default_system_dev_certificate=$(DEFAULT_SYSTEM_DEV_CERTIFICATE)" >> $(zip_root)/META/misc_info.txt
ifdef PRODUCT_EXTRA_RECOVERY_KEYS
	$(hide) echo "extra_recovery_keys=$(PRODUCT_EXTRA_RECOVERY_KEYS)" >> $(zip_root)/META/misc_info.txt
endif
	$(hide) echo 'mkbootimg_args=$(BOARD_MKBOOTIMG_ARGS)' >> $(zip_root)/META/misc_info.txt
	$(hide) echo 'mkbootimg_version_args=$(INTERNAL_MKBOOTIMG_VERSION_ARGS)' >> $(zip_root)/META/misc_info.txt
	$(hide) echo "multistage_support=1" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "blockimgdiff_versions=3,4" >> $(zip_root)/META/misc_info.txt
ifneq ($(OEM_THUMBPRINT_PROPERTIES),)
	# OTA scripts are only interested in fingerprint related properties
	$(hide) echo "oem_fingerprint_properties=$(OEM_THUMBPRINT_PROPERTIES)" >> $(zip_root)/META/misc_info.txt
endif
ifneq ($(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SYSTEM_BASE_FS_PATH),)
	$(hide) cp $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SYSTEM_BASE_FS_PATH) \
	  $(zip_root)/META/$(notdir $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SYSTEM_BASE_FS_PATH))
endif
ifneq ($(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VENDOR_BASE_FS_PATH),)
	$(hide) cp $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VENDOR_BASE_FS_PATH) \
	  $(zip_root)/META/$(notdir $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VENDOR_BASE_FS_PATH))
endif
ifneq ($(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PRODUCT_BASE_FS_PATH),)
	$(hide) cp $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PRODUCT_BASE_FS_PATH) \
	  $(zip_root)/META/$(notdir $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PRODUCT_BASE_FS_PATH))
endif
ifneq ($(strip $(SANITIZE_TARGET)),)
	# We need to create userdata.img with real data because the instrumented libraries are in userdata.img.
	$(hide) echo "userdata_img_with_data=true" >> $(zip_root)/META/misc_info.txt
endif
ifeq ($(BOARD_USES_FULL_RECOVERY_IMAGE),true)
	$(hide) echo "full_recovery_image=true" >> $(zip_root)/META/misc_info.txt
endif
ifeq ($(BOARD_AVB_ENABLE),true)
	$(hide) echo "avb_enable=true" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_vbmeta_key_path=$(BOARD_AVB_KEY_PATH)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_vbmeta_algorithm=$(BOARD_AVB_ALGORITHM)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_vbmeta_args=$(BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_boot_add_hash_footer_args=$(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)" >> $(zip_root)/META/misc_info.txt
ifdef BOARD_AVB_BOOT_KEY_PATH
	$(hide) echo "avb_boot_key_path=$(BOARD_AVB_BOOT_KEY_PATH)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_boot_algorithm=$(BOARD_AVB_BOOT_ALGORITHM)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_boot_rollback_index_location=$(BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION)" >> $(zip_root)/META/misc_info.txt
endif # BOARD_AVB_BOOT_KEY_PATH
	$(hide) echo "avb_recovery_add_hash_footer_args=$(BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS)" >> $(zip_root)/META/misc_info.txt
ifdef BOARD_AVB_RECOVERY_KEY_PATH
	$(hide) echo "avb_recovery_key_path=$(BOARD_AVB_RECOVERY_KEY_PATH)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_recovery_algorithm=$(BOARD_AVB_RECOVERY_ALGORITHM)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_recovery_rollback_index_location=$(BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION)" >> $(zip_root)/META/misc_info.txt
endif # BOARD_AVB_RECOVERY_KEY_PATH
endif # BOARD_AVB_ENABLE
ifdef BOARD_BPT_INPUT_FILES
	$(hide) echo "board_bpt_enable=true" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "board_bpt_make_table_args=$(BOARD_BPT_MAKE_TABLE_ARGS)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "board_bpt_input_files=$(BOARD_BPT_INPUT_FILES)" >> $(zip_root)/META/misc_info.txt
endif
ifdef BOARD_BPT_DISK_SIZE
	$(hide) echo "board_bpt_disk_size=$(BOARD_BPT_DISK_SIZE)" >> $(zip_root)/META/misc_info.txt
endif
	$(call generate-userimage-prop-dictionary, $(zip_root)/META/misc_info.txt)
######### Copy already built boot and recovery images #############
	@# Add already compiled images
	$(hide) mkdir -p $(zip_root)/IMAGES
ifneq ($(strip $(TARGET_NO_KERNEL)),true)
	$(call copy-vfat-image,$(INSTALLED_BOOTIMAGE_TARGET),$(BOOTIMAGE_FILES))
endif
ifeq (,$(filter true, $(TARGET_NO_KERNEL) $(TARGET_NO_RECOVERY)))
	$(call copy-vfat-image,$(INSTALLED_RECOVERYIMAGE_TARGET),$(RECOVERYIMAGE_FILES))
endif
######################
ifneq ($(INSTALLED_RECOVERYIMAGE_TARGET),)
	$(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH MKBOOTIMG=$(MKBOOTIMG) \
	    build/make/tools/releasetools/make_recovery_patch $(zip_root) $(zip_root)
endif
ifeq ($(AB_OTA_UPDATER),true)
	@# When using the A/B updater, include the updater config files in the zip.
	$(hide) cp $(TOPDIR)system/update_engine/update_engine.conf $(zip_root)/META/update_engine_config.txt
	$(hide) for part in $(AB_OTA_PARTITIONS); do \
	  echo "$${part}" >> $(zip_root)/META/ab_partitions.txt; \
	done
	$(hide) for conf in $(AB_OTA_POSTINSTALL_CONFIG); do \
	  echo "$${conf}" >> $(zip_root)/META/postinstall_config.txt; \
	done
	@# Include the build type in META/misc_info.txt so the server can easily differentiate production builds.
	$(hide) echo "build_type=$(TARGET_BUILD_VARIANT)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "ab_update=true" >> $(zip_root)/META/misc_info.txt
ifdef BRILLO_VENDOR_PARTITIONS
	$(hide) mkdir -p $(zip_root)/VENDOR_IMAGES
	$(hide) for f in $(BRILLO_VENDOR_PARTITIONS); do \
	  pair1="$$(echo $$f | awk -F':' '{print $$1}')"; \
	  pair2="$$(echo $$f | awk -F':' '{print $$2}')"; \
	  src=$${pair1}/$${pair2}; \
	  dest=$(zip_root)/VENDOR_IMAGES/$${pair2}; \
	  mkdir -p $$(dirname "$${dest}"); \
	  cp $${src} $${dest}; \
	done;
endif
ifdef OSRELEASED_DIRECTORY
	$(hide) cp $(TARGET_OUT_OEM)/$(OSRELEASED_DIRECTORY)/product_id $(zip_root)/META/product_id.txt
	$(hide) cp $(TARGET_OUT_OEM)/$(OSRELEASED_DIRECTORY)/product_version $(zip_root)/META/product_version.txt
	$(hide) cp $(TARGET_OUT_ETC)/$(OSRELEASED_DIRECTORY)/system_version $(zip_root)/META/system_version.txt
endif
endif
ifeq ($(BREAKPAD_GENERATE_SYMBOLS),true)
	@# If breakpad symbols have been generated, add them to the zip.
	$(hide) $(ACP) -r $(TARGET_OUT_BREAKPAD) $(zip_root)/BREAKPAD
endif
# BOARD_BUILD_DISABLED_VBMETAIMAGE is used to build a special vbmeta.img
# that disables AVB verification. The content is fixed and we can just copy
# it to $(zip_root)/IMAGES without passing some info into misc_info.txt for
# regeneration.
ifeq (true,$(BOARD_BUILD_DISABLED_VBMETAIMAGE))
	$(hide) mkdir -p $(zip_root)/IMAGES
	$(hide) cp $(INSTALLED_VBMETAIMAGE_TARGET) $(zip_root)/IMAGES/
endif
ifdef BOARD_PREBUILT_VENDORIMAGE
	$(hide) mkdir -p $(zip_root)/IMAGES
	$(hide) cp $(INSTALLED_VENDORIMAGE_TARGET) $(zip_root)/IMAGES/
endif
ifdef BOARD_PREBUILT_PRODUCTIMAGE
	$(hide) mkdir -p $(zip_root)/IMAGES
	$(hide) cp $(INSTALLED_PRODUCTIMAGE_TARGET) $(zip_root)/IMAGES/
endif
ifdef BOARD_PREBUILT_BOOTIMAGE
	$(hide) mkdir -p $(zip_root)/IMAGES
	$(hide) cp $(INSTALLED_BOOTIMAGE_TARGET) $(zip_root)/IMAGES/
endif
ifdef BOARD_PREBUILT_DTBOIMAGE
	$(hide) mkdir -p $(zip_root)/PREBUILT_IMAGES
	$(hide) cp $(INSTALLED_DTBOIMAGE_TARGET) $(zip_root)/PREBUILT_IMAGES/
	$(hide) echo "has_dtbo=true" >> $(zip_root)/META/misc_info.txt
ifeq ($(BOARD_AVB_ENABLE),true)
	$(hide) echo "dtbo_size=$(BOARD_DTBOIMG_PARTITION_SIZE)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_dtbo_add_hash_footer_args=$(BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS)" >> $(zip_root)/META/misc_info.txt
ifdef BOARD_AVB_DTBO_KEY_PATH
	$(hide) echo "avb_dtbo_key_path=$(BOARD_AVB_DTBO_KEY_PATH)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_dtbo_algorithm=$(BOARD_AVB_DTBO_ALGORITHM)" >> $(zip_root)/META/misc_info.txt
	$(hide) echo "avb_dtbo_rollback_index_location=$(BOARD_AVB_DTBO_ROLLBACK_INDEX_LOCATION)" \
	    >> $(zip_root)/META/misc_info.txt
endif # BOARD_AVB_DTBO_KEY_PATH
endif # BOARD_AVB_ENABLE
endif # BOARD_PREBUILT_DTBOIMAGE
	@# The radio images in BOARD_PACK_RADIOIMAGES will be additionally copied from RADIO/ into
	@# IMAGES/, which then will be added into <product>-img.zip. Such images must be listed in
	@# INSTALLED_RADIOIMAGE_TARGET.
	$(hide) $(foreach part,$(BOARD_PACK_RADIOIMAGES), \
	    echo $(part) >> $(zip_root)/META/pack_radioimages.txt;)
	@# Run fs_config on all the system, vendor, boot ramdisk,
	@# and recovery ramdisk files in the zip, and save the output
	$(hide) $(call fs_config,$(zip_root)/SYSTEM,system/) > $(zip_root)/META/filesystem_config.txt
ifdef BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE
	$(hide) $(call fs_config,$(zip_root)/VENDOR,vendor/) > $(zip_root)/META/vendor_filesystem_config.txt
endif
ifdef BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE
	$(hide) $(call fs_config,$(zip_root)/PRODUCT,product/) > $(zip_root)/META/product_filesystem_config.txt
endif
ifeq ($(BOARD_BUILD_SYSTEM_ROOT_IMAGE),true)
	@# When using BOARD_BUILD_SYSTEM_ROOT_IMAGE, ROOT always contains the files for the root under
	@# normal boot. BOOT/RAMDISK exists only if additionally using BOARD_USES_RECOVERY_AS_BOOT.
	$(hide) $(call fs_config,$(zip_root)/ROOT,) > $(zip_root)/META/root_filesystem_config.txt
ifeq ($(BOARD_USES_RECOVERY_AS_BOOT),true)
	$(hide) $(call fs_config,$(zip_root)/BOOT/RAMDISK,) > $(zip_root)/META/boot_filesystem_config.txt
endif
else # BOARD_BUILD_SYSTEM_ROOT_IMAGE != true
	$(hide) $(call fs_config,$(zip_root)/BOOT/RAMDISK,) > $(zip_root)/META/boot_filesystem_config.txt
endif
ifneq ($(INSTALLED_RECOVERYIMAGE_TARGET),)
	$(hide) $(call fs_config,$(zip_root)/RECOVERY/RAMDISK,) > $(zip_root)/META/recovery_filesystem_config.txt
endif
ifdef INSTALLED_SYSTEMOTHERIMAGE_TARGET
	$(hide) $(call fs_config,$(zip_root)/SYSTEM_OTHER,system/) > $(zip_root)/META/system_other_filesystem_config.txt
endif
	@# Metadata for compatibility verification.
	$(hide) cp $(BUILT_SYSTEM_MANIFEST) $(zip_root)/META/system_manifest.xml
	$(hide) cp $(BUILT_SYSTEM_COMPATIBILITY_MATRIX) $(zip_root)/META/system_matrix.xml
ifdef BUILT_VENDOR_MANIFEST
	$(hide) cp $(BUILT_VENDOR_MANIFEST) $(zip_root)/META/vendor_manifest.xml
endif
ifdef BUILT_VENDOR_MATRIX
	$(hide) cp $(BUILT_VENDOR_MATRIX) $(zip_root)/META/vendor_matrix.xml
endif

	$(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH MKBOOTIMG=$(MKBOOTIMG) \
	    build/make/tools/releasetools/add_img_to_target_files -a -v -p $(HOST_OUT) $(zip_root)
	@# Zip everything up, preserving symlinks and placing META/ files first to
	@# help early validation of the .zip file while uploading it.
	$(hide) find $(zip_root)/META | sort >$@.list
	$(hide) find $(zip_root) -path $(zip_root)/META -prune -o -print | sort >>$@.list
	$(hide) $(SOONG_ZIP) -d -o $@ -C $(zip_root) -l $@.list
