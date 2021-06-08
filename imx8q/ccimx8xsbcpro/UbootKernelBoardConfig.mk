TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := \
        ccimx8xsbcpro2GB-C0:ccimx8x_sbc_pro2GB_android_defconfig \
        ccimx8xsbcpro2GB-B0:ccimx8x_sbc_pro2GB_android_defconfig

TARGET_KERNEL_DEFCONFIG := ccimx8_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

ifndef TARGET_DEVICE_DIR
# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
endif
