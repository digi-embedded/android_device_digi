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

CSF_TEMPLATES := sign_ahab_uboot

define build_trustfence_tools_zip
	echo "== Building Trustfence tools ZIP"; \
	TF_TOOLS_DIR="trustfence-tools-$(strip $(1))"; \
	UBOOT_SCRIPTS_DIR="$(realpath $(UBOOT_IMX_PATH)/uboot-imx/scripts)"; \
	( \
		cd $(UBOOT_COLLECTION); \
		mkdir -p $${TF_TOOLS_DIR}/csf_templates; \
		mv mkimage*.log $${TF_TOOLS_DIR}/; \
		install -m 0755 $${UBOOT_SCRIPTS_DIR}/sign_spl_ahab.sh $${TF_TOOLS_DIR}/trustfence-sign-uboot.sh; \
		for f in $(CSF_TEMPLATES); do \
			cp --remove-destination $${UBOOT_SCRIPTS_DIR}/csf_templates/$${f} $${TF_TOOLS_DIR}/csf_templates/; \
		done; \
		zip -qXr $${TF_TOOLS_DIR}.zip $${TF_TOOLS_DIR}; \
		rm -rf $${TF_TOOLS_DIR}; \
	);
endef

define build_imx_uboot
	echo "== Building i.MX U-Boot"; \
	UBOOT_PLATFORM="$(strip $(2))"; \
	SCFW_PLATFORM="$$(echo $${UBOOT_PLATFORM} | cut -d'-' -f1)"; \
	MKIMAGE_PLATFORM="iMX8QX"; \
	ATF_PLATFORM="imx8qx"; \
	REV="B0"; \
	if [ "$$(echo $${UBOOT_PLATFORM} | cut -d'-' -f2)" = "C0" ]; then \
		REV="C0";  \
	fi; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=$${ATF_PLATFORM} clean; \
	if [ "$$(echo $(2) | cut -d '-' -f3)" = "trusty" ]; then \
		cp --remove-destination $(DIGI_FIRMWARE_PATH)/uboot-firmware/imx8q/tee-$${SCFW_PLATFORM}.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/tee.bin; \
		$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 SPD=trusty -B 1>/dev/null || exit 1; \
	else \
		rm -f $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/tee.bin; \
		$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B 1>/dev/null || exit 1; \
	fi; \
	cp --remove-destination $(IMX_PATH)/arm-trusted-firmware/build/$${ATF_PLATFORM}/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/bl31.bin; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/imx-seco/firmware/seco/mx8qx*ahab-container.img $(IMX_MKIMAGE_PATH)/imx-mkimage/$$MKIMAGE_PLATFORM/; \
	cp --remove-destination $(DIGI_FIRMWARE_PATH)/uboot-firmware/imx8q/$${SCFW_PLATFORM}_scfw-tcm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/scfw_tcm.bin; \
	cp --remove-destination $(UBOOT_OUT)/u-boot.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/u-boot.bin; \
	cp --remove-destination $(UBOOT_OUT)/spl/u-boot-spl.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/u-boot-spl.bin; \
	cp --remove-destination $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/mkimage_uboot; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	$(MAKE) --no-print-directory -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=$${MKIMAGE_PLATFORM} REV=$${REV} flash_spl 2>&1 | tee $(UBOOT_COLLECTION)/mkimage.log || exit 1; \
	cp --remove-destination $(IMX_MKIMAGE_PATH)/imx-mkimage/$${MKIMAGE_PLATFORM}/flash.bin $(UBOOT_COLLECTION)/u-boot-$${UBOOT_PLATFORM}.imx; \
	$(call build_trustfence_tools_zip, $(2))
endef
