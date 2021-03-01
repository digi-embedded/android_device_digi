TARGET_UBOOT_ARCH := arm64

# This makefile is included in "device/nxp/common/build/Makefile",
# so it is the proper place to override some paths from NXP's
# "device/nxp/common/imx_path/ImxPathConfig.mk"
DIGI_PROPRIETARY_PATH := vendor/digi/proprietary
KERNEL_IMX_PATH := vendor/digi
UBOOT_IMX_PATH := vendor/digi
