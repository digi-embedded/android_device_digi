TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := ccimx8xsbcpro-C0:ccimx8x_sbc_pro_android_defconfig
TARGET_BOOTLOADER_CONFIG += ccimx8xsbcpro-B0:ccimx8x_sbc_pro_android_defconfig
ifeq ($(PRODUCT_IMX_TRUSTY),true)
TARGET_BOOTLOADER_CONFIG += ccimx8xsbcpro-C0-trusty:ccimx8x_sbc_pro_android_trusty_defconfig
TARGET_BOOTLOADER_CONFIG += ccimx8xsbcpro-B0-trusty:ccimx8x_sbc_pro_android_trusty_defconfig
endif

TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= ccimx8x_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := ccimx8_android_defconfig
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig
endif # LOADABLE_KERNEL_MODULE

ifndef TARGET_DEVICE_DIR
# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
endif
