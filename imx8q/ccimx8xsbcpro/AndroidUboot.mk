# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

ifneq ($(AARCH64_GCC_CROSS_COMPILE),)
ATF_CROSS_COMPILE := $(strip $(AARCH64_GCC_CROSS_COMPILE))
else
ATF_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-4.9/bin)
ATF_CROSS_COMPILE := $(ATF_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
endif

define build_m4_image
	echo "android build without building M4 image"
endef

define build_imx_uboot
	UBOOT_PLATFORM="$(strip $(2))"; \
	SCFW_PLATFORM="$$(echo $${UBOOT_PLATFORM} | cut -d'-' -f1)"; \
	MKIMAGE_PLATFORM="iMX8QX"; \
	ATF_PLATFORM="imx8qx"; \
	REV="B0"; \
	if [ "$$(echo $${UBOOT_PLATFORM} | cut -d'-' -f2)" = "C0" ]; then \
		REV="C0";  \
	fi; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=$${ATF_PLATFORM} clean; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B 1>/dev/null || exit 1; \
	cp --remove-destination $(IMX_PATH)/arm-trusted-firmware/build/$${ATF_PLATFORM}/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/bl31.bin; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/imx-seco/firmware/seco/mx8qx*ahab-container.img $(IMX_MKIMAGE_PATH)/imx-mkimage/$$MKIMAGE_PLATFORM/; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/m4_image.bin; \
	cp --remove-destination $(DIGI_PROPRIETARY_PATH)/uboot-firmware/imx8q/$${SCFW_PLATFORM}_scfw-tcm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/scfw_tcm.bin; \
	cp --remove-destination $(UBOOT_OUT)/u-boot.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/u-boot.bin; \
	cp --remove-destination $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/mkimage_uboot; \
	for target in $(TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS); do \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
		$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=$${MKIMAGE_PLATFORM} REV=$${REV} $${target} || exit 1; \
		install -D $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/flash.bin $(UBOOT_COLLECTION)/u-boot-$${UBOOT_PLATFORM}-$${target}.imx; \
		cp --remove-destination $(UBOOT_COLLECTION)/u-boot-$${UBOOT_PLATFORM}-$${target}.imx $(UBOOT_COLLECTION)/u-boot-$${UBOOT_PLATFORM}.imx; \
	done;
endef
