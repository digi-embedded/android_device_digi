# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash
ATF_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-4.9/bin)
ATF_CROSS_COMPILE := $(ATF_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-

# Make a second copy of the final artifcact removing the target from the name to avoid non-bootable U-Boots.
define build_imx_uboot
	MKIMAGE_PLATFORM="iMX8QX"; \
	SCFW_PLATFORM="8qx"; \
	ATF_PLATFORM="imx8qx"; \
	REV="B0"; \
	if [ `echo $(2) | cut -d '-' -f2` == "c0" ] || [ `echo $(2) | cut -d '-' -f3` == "c0" ]; then \
		REV=`echo C0`;  \
	fi; \
	UBOOT_PLATFORM="$(strip $(2))"; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=$${ATF_PLATFORM} clean; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B; \
	cp --remove-destination $(IMX_PATH)/arm-trusted-firmware/build/$${ATF_PLATFORM}/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/bl31.bin; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/imx-seco/firmware/seco/mx8qx*ahab-container.img $(IMX_MKIMAGE_PATH)/imx-mkimage/$$MKIMAGE_PLATFORM/; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/m4_image.bin; \
	cp --remove-destination $(DIGI_PROPRIETARY_PATH)/uboot-firmware/imx8q/$${UBOOT_PLATFORM}_scfw-tcm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/scfw_tcm.bin; \
	cp --remove-destination $(UBOOT_OUT)/u-boot.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/u-boot.bin; \
	cp --remove-destination $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/mkimage_uboot; \
	for target in $(TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS); do \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=$${MKIMAGE_PLATFORM} REV=$${REV} $${target}; \
		install -D $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/flash.bin $(PRODUCT_OUT)/u-boot-$${UBOOT_PLATFORM}-$${target}.imx; \
		cp --remove-destination $(PRODUCT_OUT)/u-boot-$${UBOOT_PLATFORM}-$${target}.imx $(PRODUCT_OUT)/u-boot-$${UBOOT_PLATFORM}.imx; \
	done;
endef

# Remove duplicated u-boot images
.PHONY: ubootimg_clean
ubootimg_clean: $(UBOOT_BIN)
	for ubootplat in $(TARGET_BOOTLOADER_CONFIG); do \
		UBOOT_PLATFORM=`echo $$ubootplat | cut -d':' -f1`; \
		rm -f $(PRODUCT_OUT)/u-boot-$${UBOOT_PLATFORM}.imx; \
	done

ALL_DEFAULT_INSTALLED_MODULES += ubootimg_clean
