ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

ifeq ($(strip $(TARGET_DEA_SDIMAGE)),true)

MKSDIMAGE := $(TOPDIR)device/digi/build/tools/mksdimage.sh

INSTALLED_SDIMAGE_TARGET := $(PRODUCT_OUT)/sdcard.img
INSTALLED_SDIMAGE_TARGET_GZ := $(INSTALLED_SDIMAGE_TARGET).gz

# Use the proper u-boot binary for the SD image depending on TF_SIGN_ENABLED
SDIMG_UBOOT := $(firstword $(TARGET_UBOOT_IMAGES))
ifeq ($(strip $(TF_SIGN_ENABLED)),1)
SDIMG_UBOOT := $(subst u-boot,u-boot-signed,$(SDIMG_UBOOT))
endif

.PHONY: sdimage
sdimage: $(INSTALLED_SDIMAGE_TARGET_GZ)

$(INSTALLED_SDIMAGE_TARGET_GZ): $(TARGET_UBOOT_IMAGES) $(INSTALLED_BOOTIMAGE_TARGET) $(INSTALLED_SYSTEMIMAGE) $(INSTALLED_VENDORIMAGE_TARGET) | $(MINIGZIP) $(SIMG2IMG)
	$(call pretty,"Target DEA sdcard image: $@")
	$(hide) $(MKSDIMAGE) \
		-u $(SDIMG_UBOOT) \
		-b $(INSTALLED_BOOTIMAGE_TARGET) \
		-s $(INSTALLED_SYSTEMIMAGE) \
		-v $(INSTALLED_VENDORIMAGE_TARGET) \
		$(INSTALLED_SDIMAGE_TARGET)
	$(hide) $(MINIGZIP) -9 < $(INSTALLED_SDIMAGE_TARGET) > $@
	$(hide) rm -f $(INSTALLED_SDIMAGE_TARGET)

droidcore: $(INSTALLED_SDIMAGE_TARGET_GZ)

endif

endif
