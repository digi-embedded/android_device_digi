ifneq ($(strip $(TARGET_UBOOT_CONFIG)),)

UBOOT_CROSS_TOOLCHAIN := $(ANDROID_TOOLCHAIN)/arm-linux-androideabi-
UBOOT_OUT := $(TARGET_OUT_INTERMEDIATES)/UBOOT_OBJ

TARGET_UBOOT_IMAGES := $(foreach config, $(TARGET_UBOOT_CONFIG), $(PRODUCT_OUT)/u-boot-$(config).imx)
TARGET_UBOOT_DOTCONFIGS := $(foreach config, $(TARGET_UBOOT_CONFIG), $(UBOOT_OUT)/$(config)/.config)

UBOOT_CONFIG_OPTIONS := \
	CONSOLE_DISABLE \
	CONSOLE_ENABLE_GPIO \
	CONSOLE_ENABLE_GPIO_NR \
	CONSOLE_ENABLE_PASSPHRASE \
	CONSOLE_ENABLE_PASSPHRASE_KEY \
	SIGN_IMAGE \
	SIGN_KEYS_PATH \
	UNLOCK_SRK_REVOKE \
	KEY_INDEX \
	DEK_PATH \
	ENV_AES \
	ENV_AES_CAAM_KEY

define TRUSTFENCE_AMEND_DOTCONFIG
for i in $(UBOOT_CONFIG_OPTIONS); do \
	sed -i -e "/CONFIG_$${i}/d" $@; \
done
if [ "$(TRUSTFENCE_CONSOLE_DISABLE:"%"=%)" = "1" ]; then \
	echo "CONFIG_CONSOLE_DISABLE=y"; \
	if [ -n "$(TRUSTFENCE_CONSOLE_PASSPHRASE_ENABLE:"%"=%)" ]; then \
		echo "CONFIG_CONSOLE_ENABLE_PASSPHRASE=y"; \
		echo "CONFIG_CONSOLE_ENABLE_PASSPHRASE_KEY=\"$$(printf '%s' '$(TRUSTFENCE_CONSOLE_PASSPHRASE_ENABLE:"%"=%)' | sha256sum | cut -d' ' -f1)\""; \
	elif [ -n "$(TRUSTFENCE_CONSOLE_GPIO_ENABLE:"%"=%)" ]; then \
		echo "CONFIG_CONSOLE_ENABLE_GPIO=y"; \
		echo "CONFIG_CONSOLE_ENABLE_GPIO_NR=$(TRUSTFENCE_CONSOLE_GPIO_ENABLE:"%"=%)"; \
	fi; \
fi >> $@
if [ "$(TRUSTFENCE_SIGN:"%"=%)" = "1" ]; then \
	echo "CONFIG_SIGN_IMAGE=y"; \
	if [ -n "$(TRUSTFENCE_SIGN_KEYS_PATH:"%"=%)" ]; then \
		echo "CONFIG_SIGN_KEYS_PATH=\"$(TRUSTFENCE_SIGN_KEYS_PATH:"%"=%)\""; \
	fi; \
	if [ "$(TRUSTFENCE_UNLOCK_KEY_REVOCATION:"%"=%)" = "1" ]; then \
		echo "CONFIG_UNLOCK_SRK_REVOKE=y"; \
	fi; \
	if [ -n "$(TRUSTFENCE_KEY_INDEX:"%"=%)" ]; then \
		echo "CONFIG_KEY_INDEX=$(TRUSTFENCE_KEY_INDEX:"%"=%)"; \
	fi; \
	if [ -n "$(TRUSTFENCE_DEK_PATH:"%"=%)" ] && [ "$(TRUSTFENCE_DEK_PATH:"%"=%)" != "0" ]; then \
		echo "CONFIG_DEK_PATH=\"$(TRUSTFENCE_DEK_PATH:"%"=%)\""; \
	fi; \
fi >> $@
if [ "$(TRUSTFENCE_ENCRYPT_ENVIRONMENT:"%"=%)" = "1" ]; then \
	echo "CONFIG_ENV_AES=y"; \
	echo "CONFIG_ENV_AES_CAAM_KEY=y"; \
fi >> $@
endef

$(TARGET_UBOOT_DOTCONFIGS): $(wildcard $(LOCALCONF_MK))
	$(MAKE) -C $(UBOOT_IMX_PATH)/uboot-imx O=$(realpath $(@D)) CROSS_COMPILE=$(UBOOT_CROSS_TOOLCHAIN) $(lastword $(subst /, ,$(@D)))_defconfig
ifeq ($(strip $(TRUSTFENCE_ENABLE:"%"=%)),1)
	@$(TRUSTFENCE_AMEND_DOTCONFIG)
	$(MAKE) -C $(UBOOT_IMX_PATH)/uboot-imx O=$(realpath $(@D)) CROSS_COMPILE=$(UBOOT_CROSS_TOOLCHAIN) oldnoconfig
endif

.PHONY: bootloader
bootloader: $(TARGET_UBOOT_IMAGES)

# Generate u-boot images dependences
$(foreach ubimg, $(TARGET_UBOOT_IMAGES), $(eval $(ubimg): $(UBOOT_OUT)/$(subst u-boot-,,$(basename $(notdir $(ubimg))))/.config))

$(TARGET_UBOOT_IMAGES): | $(if $(TF_SIGN_ENABLED),$(TF_SIGN_UBOOT) $(TF_SIGN_ARTIFACT))
	$(MAKE) -C $(UBOOT_IMX_PATH)/uboot-imx O=$(realpath $(<D)) CROSS_COMPILE=$(UBOOT_CROSS_TOOLCHAIN)
	install -D $(<D)/u-boot$(TARGET_DTB_POSTFIX).$(TARGET_BOOTLOADER_POSTFIX) $@
ifeq ($(strip $(TF_SIGN_ENABLED)),1)
	\cp --remove-destination $(<D)/SRK_efuses.bin $(PRODUCT_OUT)/u-boot-SRK_efuses.bin
	install -D $(<D)/u-boot$(TARGET_DTB_POSTFIX)-signed.imx $(subst u-boot,u-boot-signed,$@)
	install -D $(<D)/u-boot$(TARGET_DTB_POSTFIX)-usb-signed.imx $(subst u-boot,u-boot-usb-signed,$@)
endif
ifeq ($(strip $(TF_ENCRYPT_ENABLED)),1)
	install -D $(<D)/u-boot$(TARGET_DTB_POSTFIX)-encrypted.imx $(subst u-boot,u-boot-encrypted,$@)
endif

endif
