ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

ifeq ($(strip $(TARGET_DEA_FWINSTALLER)),true)

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

FWINSTALLER_ZIP := $(PRODUCT_OUT)/install_android_fw_sd.zip
FWINSTALLER_SRC := device/digi/$(TARGET_PRODUCT)/install_android_fw_sd.txt
FWINSTALLER_TARGET := $(PRODUCT_OUT)/install_android_fw_sd.scr

FWINSTALLER_DEPENDENCIES := \
	$(FWINSTALLER_TARGET) \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_VENDORIMAGE_TARGET) \
	$(INSTALLED_SYSTEMIMAGE) \
	$(INSTALLED_RECOVERYIMAGE_TARGET)

UBOOT_FILELIST := $(PRODUCT_OUT)/u-boot-*.imx

FWINSTALLER_FILELIST := \
	$(FWINSTALLER_DEPENDENCIES) \
	$(UBOOT_FILELIST)

.PHONY: fwinstaller
fwinstaller: $(FWINSTALLER_ZIP)

$(FWINSTALLER_TARGET): $(FWINSTALLER_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A arm -O linux -T script -C none -n "Install script" -d $< $@

$(FWINSTALLER_ZIP): $(FWINSTALLER_DEPENDENCIES) $(TARGET_UBOOT_IMAGES)
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
	$(hide) zip -qXj $@ $(FWINSTALLER_FILELIST) README.txt
	$(hide) rm -f README.txt

droidcore: $(FWINSTALLER_ZIP)

endif

endif
