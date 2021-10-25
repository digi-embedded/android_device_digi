# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

ifneq ($(AARCH64_GCC_CROSS_COMPILE),)
ATF_CROSS_COMPILE := $(strip $(AARCH64_GCC_CROSS_COMPILE))
else
ATF_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-4.9/bin)
ATF_CROSS_COMPILE := $(ATF_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
endif

CSF_TEMPLATES := \
	encrypt_sign_uboot_fit \
	encrypt_sign_uboot_spl \
	encrypt_uboot_fit \
	encrypt_uboot_spl \
	sign_uboot_fit \
	sign_uboot_spl

define build_trustfence_tools_zip
	echo "== Building Trustfence tools ZIP"; \
	TF_TOOLS_DIR="trustfence-tools-$(strip $(1))"; \
	UBOOT_SCRIPTS_DIR="$(realpath $(UBOOT_IMX_PATH)/uboot-imx/scripts)"; \
	TF_KEY_SCRIPTS_DIR="$(realpath device/digi/common/trustfence)"; \
	( \
		cd $(UBOOT_COLLECTION); \
		mkdir -p $${TF_TOOLS_DIR}/bin $${TF_TOOLS_DIR}/csf_templates; \
		mv mkimage*.log $${TF_TOOLS_DIR}/; \
		install -m 0755 $${UBOOT_SCRIPTS_DIR}/sign_spl_fit.sh $${TF_TOOLS_DIR}/trustfence-sign-uboot.sh; \
		install -m 0755 $${TF_KEY_SCRIPTS_DIR}/keys/hab4_pki_tree.sh $${TF_TOOLS_DIR}/bin/trustfence-gen-pki.sh; \
		install -m 0755 $${TF_KEY_SCRIPTS_DIR}/ca/openssl.cnf $${TF_TOOLS_DIR}/bin/openssl.cnf; \
		install -m 0755 $${TF_KEY_SCRIPTS_DIR}/ca/v3_ca.cnf $${TF_TOOLS_DIR}/bin/v3_ca.cnf; \
		install -m 0755 $${TF_KEY_SCRIPTS_DIR}/ca/v3_usr.cnf $${TF_TOOLS_DIR}/bin/v3_usr.cnf; \
		for f in $(CSF_TEMPLATES); do \
			cp --remove-destination $${UBOOT_SCRIPTS_DIR}/csf_templates/$${f} $${TF_TOOLS_DIR}/csf_templates/; \
		done; \
		zip -qXr $${TF_TOOLS_DIR}.zip $${TF_TOOLS_DIR}; \
		rm -rf $${TF_TOOLS_DIR}; \
	);
endef

define build_imx_uboot
	echo "== Building i.MX U-Boot with firmware"; \
	ATF_PLATFORM="imx8mm"; \
	UBOOT_DTB="ccimx8mm-dvk.dtb"; \
	cp --remove-destination $(UBOOT_OUT)/u-boot-nodtb.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(UBOOT_OUT)/spl/u-boot-spl.bin  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(UBOOT_OUT)/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/mkimage_uboot; \
	cp --remove-destination $(UBOOT_OUT)/arch/arm/dts/$${UBOOT_DTB} $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp --remove-destination $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ PLAT=$${ATF_PLATFORM} clean; \
	if [ "$$(echo $(2) | cut -d '-' -f2)" = "trusty" ]; then \
		cp --remove-destination $(DIGI_FIRMWARE_PATH)/uboot-firmware/imx8m/tee-ccimx8mm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
		$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B SPD=trusty 1>/dev/null || exit 1; \
	else \
		rm -f $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
		$(MAKE) -C $(IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" PLAT=$${ATF_PLATFORM} bl31 -B 1>/dev/null || exit 1; \
	fi; \
	cp --remove-destination $(IMX_PATH)/arm-trusted-firmware/build/$${ATF_PLATFORM}/release/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/bl31.bin; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	$(MAKE) --no-print-directory -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM dtbs=$${UBOOT_DTB} flash_spl_uboot 2>&1 | tee $(UBOOT_COLLECTION)/mkimage.log || exit 1; \
	cp --remove-destination $(UBOOT_OUT)/arch/arm/dts/$${UBOOT_DTB} $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	$(MAKE) --no-print-directory -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8MM dtbs=$${UBOOT_DTB} print_fit_hab 2>&1 | tee $(UBOOT_COLLECTION)/mkimage-print_fit_hab.log || exit 1; \
	cp --remove-destination $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/flash.bin $(UBOOT_COLLECTION)/u-boot-$(strip $(2)).imx; \
	$(call build_trustfence_tools_zip, $(2))
endef
