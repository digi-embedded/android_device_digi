TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := ccimx8mmdvk:ccimx8mm_dvk_android_defconfig
ifeq ($(PRODUCT_IMX_TRUSTY),true)
TARGET_BOOTLOADER_CONFIG += ccimx8mmdvk-trusty:ccimx8mm_dvk_android_trusty_defconfig
endif

# imx8mm kernel defconfig
TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= ccimx8mm_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := ccimx8_android_defconfig
endif
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

ifndef TARGET_DEVICE_DIR
# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
endif
