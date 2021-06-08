ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

INSTALLED_FIRMWARE_ZIP_TARGET := $(PRODUCT_OUT)/install_android_fw.zip
INSTALLED_FIRMWARE_SCRIPT_TARGET := $(PRODUCT_OUT)/install_android_fw.sh

FWINSTALLER_DEPENDENCIES := \
	$(BOARD_PREBUILT_DTBOIMAGE) \
	$(IMX_INSTALLED_VBMETAIMAGE_TARGET) \
	$(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET) \
	$(INSTALLED_ANDROID_INFO_TXT_TARGET) \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_BPTIMAGE_TARGET) \
	$(INSTALLED_FIRMWARE_SCRIPT_TARGET) \
	$(INSTALLED_SUPERIMAGE_TARGET) \
	$(INSTALLED_VENDOR_BOOTIMAGE_TARGET)

-include $(TARGET_DEVICE_DIR)/UbootKernelBoardConfig.mk
TARGET_UBOOT_IMAGES := $(foreach config,$(TARGET_BOOTLOADER_CONFIG),$(PRODUCT_OUT)/u-boot-$(firstword $(subst :, ,$(config))).imx)

FWINSTALLER_FILELIST := \
	$(FWINSTALLER_DEPENDENCIES) \
	$(TARGET_UBOOT_IMAGES)

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
