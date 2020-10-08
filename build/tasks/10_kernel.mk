ifeq ($(strip $(TARGET_DEA_FIRMWARE_MK)),true)

ifneq ($(strip $(TARGET_NO_KERNEL)),true)

TARGET_PREBUILT_KERNEL_ZIMAGE := $(call append-path,$(dir $(TARGET_PREBUILT_KERNEL)),zImage)

#
# Override kernel build rule in 'build/make' repo for Trustfence support
#
# TODO: do not hardcode "ccimx6" platform (make it a BoardConfig.mk variable)
#
$(TARGET_PREBUILT_KERNEL): $(wildcard $(LOCALCONF_MK)) | $(if $(TF_SIGN_ENABLED),$(TF_SIGN_ARTIFACT))
	$(MAKE) -C $(KERNEL_IMX_PATH)/kernel_imx mrproper
	$(MAKE) -C $(KERNEL_IMX_PATH)/kernel_imx O=$(realpath $(KERNEL_OUT)) -j$(HOST_PROCESSOR) $(KERNEL_ENV)
	$(MAKE) -C $(KERNEL_IMX_PATH)/kernel_imx O=$(realpath $(KERNEL_OUT)) dtbs $(KERNEL_ENV)
	if [ "$$TF_SIGN_ENABLED" = "1" ]; then \
		$(TF_SIGN_ARTIFACT) -p ccimx6 -l $(KERNEL_IMAGE_NAME) $@; \
	else \
		install -D $(KERNEL_IMAGE_NAME) $@; \
	fi
	\cp -f $@ $(TARGET_PREBUILT_KERNEL_ZIMAGE)
	for dtsplat in $(TARGET_BOARD_DTS_CONFIG); do \
		DTS_PLATFORM=`echo $$dtsplat | cut -d':' -f1`; \
		DTS_BOARD=`echo $$dtsplat | cut -d':' -f2`; \
		if [ "$$TF_SIGN_ENABLED" = "1" ]; then \
			$(TF_SIGN_ARTIFACT) -p ccimx6 -d $(KERNEL_OUT)/arch/$(TARGET_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/$$DTS_BOARD $(KERNEL_OUT)/$$DTS_BOARD; \
		else \
			install -D $(KERNEL_OUT)/arch/$(TARGET_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/$$DTS_BOARD $(KERNEL_OUT)/$$DTS_BOARD; \
		fi \
	done

endif

endif
