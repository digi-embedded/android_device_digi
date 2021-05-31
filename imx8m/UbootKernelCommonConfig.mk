TARGET_UBOOT_ARCH := arm64

# This makefile is included in "device/nxp/common/build/Makefile",
# so it is the proper place to override some paths from NXP's
# "device/nxp/common/imx_path/ImxPathConfig.mk"
DIGI_FIRMWARE_PATH := vendor/digi/firmware
KERNEL_IMX_PATH := vendor/digi
UBOOT_IMX_PATH := vendor/digi
QCACLD_PATH := vendor/digi/qcacld-2.0

# Bare toolchain to build U-Boot bootable artifact
AARCH64_GCC_CROSS_COMPILE := "$(realpath prebuilts/gcc/linux-x86/aarch64-nolibc/gcc-8.4.0-nolibc/aarch64-linux/bin)/aarch64-linux-"
