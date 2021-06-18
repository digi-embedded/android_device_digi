ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

-include $(dir $(TARGET_DEVICE_DIR))UbootKernelCommonConfig.mk  # TARGET_UBOOT_ARCH
-include $(TARGET_DEVICE_DIR)/UbootKernelBoardConfig.mk         # TARGET_BOOTLOADER_CONFIG

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage

FIRMWARE_UBOOTSCRIPT_SRC := $(TARGET_DEVICE_DIR)/install_android_fw_sd.txt
INSTALLED_FIRMWARE_UBOOTSCRIPT_TARGET := $(PRODUCT_OUT)/install_android_fw_sd.scr

INSTALLED_FIRMWARE_ZIP_TARGET := $(PRODUCT_OUT)/install_android_fw.zip
INSTALLED_FIRMWARE_SCRIPT_TARGET := $(PRODUCT_OUT)/install_android_fw_uuu.sh

FWINSTALLER_DEPENDENCIES := \
	$(BOARD_PREBUILT_DTBOIMAGE) \
	$(IMX_INSTALLED_VBMETAIMAGE_TARGET) \
	$(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET) \
	$(INSTALLED_ANDROID_INFO_TXT_TARGET) \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_BPTIMAGE_TARGET) \
	$(INSTALLED_FIRMWARE_SCRIPT_TARGET) \
	$(INSTALLED_FIRMWARE_UBOOTSCRIPT_TARGET) \
	$(INSTALLED_SUPERIMAGE_TARGET) \
	$(INSTALLED_VENDOR_BOOTIMAGE_TARGET)

TARGET_UBOOT_IMAGES := $(foreach config,$(TARGET_BOOTLOADER_CONFIG),$(PRODUCT_OUT)/u-boot-$(firstword $(subst :, ,$(config))).imx)

FWINSTALLER_FILELIST := \
	$(FWINSTALLER_DEPENDENCIES) \
	$(TARGET_UBOOT_IMAGES)

.PHONY: ubootscript
ubootscript: $(INSTALLED_FIRMWARE_UBOOTSCRIPT_TARGET)

$(INSTALLED_FIRMWARE_UBOOTSCRIPT_TARGET): $(FIRMWARE_UBOOTSCRIPT_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A $(TARGET_UBOOT_ARCH) -O linux -T script -C none -n "Install script" -d $< $@

.PHONY: fwinstaller
fwinstaller: $(INSTALLED_FIRMWARE_ZIP_TARGET)

$(INSTALLED_FIRMWARE_ZIP_TARGET): $(FWINSTALLER_DEPENDENCIES)
	$(hide) rm -f $@
	$(hide) ( \
		echo "Digi Embedded for Android kit upgrader"; \
		echo "--------------------------------------"; \
		echo ""; \
		echo "Version: $(BUILD_ID)"; \
		echo ""; \
		md5sum $(FWINSTALLER_FILELIST) | sed -e 's,^\([[:xdigit:]]\{32\}\).*/\([^/]\+\)$$,\1  \2,g'; \
	) > README.txt
	$(hide) zip -qXj --must-match $@ $(FWINSTALLER_FILELIST) README.txt
	$(hide) rm -f README.txt

endif
