TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := \
        ccimx8xsbcpro2GB-C0:ccimx8x_sbc_pro2GB_android_defconfig \
        ccimx8xsbcpro2GB-B0:ccimx8x_sbc_pro2GB_android_defconfig

#
# The U-Boot imx-mkimage target define the final bootable artifact to generate:
#
#   - flash: final bootable artifact includes:
#       * Standard U-Boot binary (u-boot.bin)
#       * The firmware that runs in the SCU (scfw-tcm.bin)
#       * The ARM Trusted Firmware that runs in the security controller (bl31.bin)
#       * A container used by NXP to verify signed images (ahab-container.img)
#
#   - flash_all: like 'flash' target and:
#       * Cortex M4 firmware (vendor/nxp/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin)
#
TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS := \
        flash \
        flash_all

TARGET_KERNEL_DEFCONFIG := ccimx8_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
