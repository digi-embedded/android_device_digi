ifeq ($(strip $(TARGET_DEA_FWINSTALLER)),true)

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

FWINSTALLER_ZIP := $(PRODUCT_OUT)/install_android_fw_sd.zip
FWINSTALLER_SRC := $(TARGET_DEVICE_DIR)/install_android_fw_sd.txt
FWINSTALLER_TARGET := $(PRODUCT_OUT)/install_android_fw_sd.scr

FWINSTALLER_DEPENDENCIES := \
	$(FWINSTALLER_TARGET) \
	$(INSTALLED_ANDROID_INFO_TXT_TARGET) \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_RECOVERYIMAGE_TARGET) \
	$(INSTALLED_SYSTEMIMAGE) \
	$(INSTALLED_VENDORIMAGE_TARGET)

TARGET_UBOOT_IMAGES := $(foreach config,$(TARGET_BOOTLOADER_CONFIG),$(PRODUCT_OUT)/u-boot-$(firstword $(subst :, ,$(config))).imx)
ifneq ($(strip $(TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS)),)
TARGET_UBOOT_IMAGES := $(foreach imxtgt,$(TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS),$(addsuffix -$(imxtgt).imx,$(basename $(TARGET_UBOOT_IMAGES))))
endif

FWINSTALLER_FILELIST := \
	$(FWINSTALLER_DEPENDENCIES) \
	$(TARGET_UBOOT_IMAGES)

.PHONY: fwinstaller
fwinstaller: $(FWINSTALLER_ZIP)

$(FWINSTALLER_TARGET): $(FWINSTALLER_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A $(TARGET_UBOOT_ARCH) -O linux -T script -C none -n "Install script" -d $< $@

$(FWINSTALLER_ZIP): $(FWINSTALLER_DEPENDENCIES) $(UBOOT_BIN)
	$(hide) rm -f $@
	$(hide) ( \
		echo "Digi Embedded for Android kit upgrader"; \
		echo "--------------------------------------"; \
		echo ""; \
		echo "Version: $(BUILD_ID)"; \
		echo "Build number: $(BUILD_NUMBER)"; \
		echo ""; \
		md5sum $(FWINSTALLER_FILELIST) | sed -e 's,^\([[:xdigit:]]\{32\}\).*/\([^/]\+\)$$,\1  \2,g'; \
	) > README.txt
	$(hide) zip -qXj --must-match $@ $(FWINSTALLER_FILELIST) README.txt
	$(hide) rm -f README.txt

droidcore: $(FWINSTALLER_ZIP)

endif
