TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for imx8qm_mek standard android
TARGET_BOOTLOADER_CONFIG := imx8qm:imx8qm_mek_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx8qm-hdmi:imx8qm_mek_android_hdmi_defconfig
TARGET_BOOTLOADER_CONFIG += imx8qm-md:imx8qm_mek_android_hdmi_defconfig
# u-boot target for imx8qxp_mek standard android
TARGET_BOOTLOADER_CONFIG += imx8qxp:imx8qxp_mek_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx8qxp-c0:imx8qxp_mek_android_defconfig
# u-boot target for imx8dx_mek standard android
TARGET_BOOTLOADER_CONFIG += imx8dx:imx8dx_mek_android_defconfig
# u-boot target used by uuu for imx8dx_mek
TARGET_BOOTLOADER_CONFIG += imx8dx-mek-uuu:imx8dx_mek_android_uuu_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
  # u-boot target for imx8qm_mek standard android with trusty support
  TARGET_BOOTLOADER_CONFIG += imx8qm-trusty:imx8qm_mek_android_trusty_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8qm-trusty-secure-unlock:imx8qm_mek_android_trusty_secure_unlock_defconfig
  # u-boot target for imx8qxp_mek standard android with trusty support
  TARGET_BOOTLOADER_CONFIG += imx8qxp-trusty:imx8qxp_mek_android_trusty_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8qxp-trusty-c0:imx8qxp_mek_android_trusty_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8qxp-trusty-secure-unlock:imx8qxp_mek_android_trusty_secure_unlock_defconfig
endif

# u-boot target used by uuu for imx8qm_mek
TARGET_BOOTLOADER_CONFIG += imx8qm-mek-uuu:imx8qm_mek_android_uuu_defconfig
# u-boot target used by uuu for imx8qxp_mek
TARGET_BOOTLOADER_CONFIG += imx8qxp-mek-uuu:imx8qxp_mek_android_uuu_defconfig
TARGET_BOOTLOADER_CONFIG += imx8qxp-mek-c0-uuu:imx8qxp_mek_android_uuu_defconfig

TARGET_KERNEL_DEFCONFIG := imx_v8_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
