# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

ifneq ($(AARCH64_GCC_CROSS_COMPILE),)
ATF_CROSS_COMPILE := $(strip $(AARCH64_GCC_CROSS_COMPILE))
else
ATF_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-4.9/bin)
ATF_CROSS_COMPILE := $(ATF_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
endif

define build_imx_uboot
	$(hide) echo Building i.MX U-Boot with firmware; \
	ATF_PLATFORM="imx8mm"; \
	UBOOT_DTB="ccimx8mm-dvk.dtb"; \
	cp --remove-destination $(UBOOT_OUT)/u-boot-nodtb.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(UBOOT_OUT)/spl/u-boot-spl.bin  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/mkimage_uboot; \
	cp --remove-destination $(UBOOT_OUT)/arch/arm/dts/$${UBOOT_DTB} $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=$${ATF_PLATFORM} clean; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B 1>/dev/null || exit 1; \
	cp --remove-destination $(IMX_PATH)/arm-trusted-firmware/build/$${ATF_PLATFORM}/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/bl31.bin; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM dtbs=$${UBOOT_DTB} flash_spl_uboot || exit 1; \
	cp --remove-destination $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/flash.bin $(UBOOT_COLLECTION)/u-boot-$(strip $(2)).imx;
endef
