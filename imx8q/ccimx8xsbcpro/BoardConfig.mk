#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/digi/imx8q/ccimx8xsbcpro

include device/digi/build_id.mk
include device/fsl/imx8q/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp_aacp_dec/imx_dsp_aacp_dec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp_codec/imx_dsp_codec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp/imx_dsp.mk
endif

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.digi

# Vendor Interface Manifest
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

PRODUCT_MODEL := ccimx8xsbcpro

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# Qcom QCA6574 Wi-Fi
BOARD_HAVE_WIFI_QCA6574 := true
WIFI_DRIVER_MODULE_PATH := /vendor/lib/modules/qca6574_wlan.ko
WIFI_DRIVER_MODULE_NAME := wlan

# Qcom QCA6574 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
QCOM_BT_USE_SIBS := false

# sensor configs
BOARD_USE_SENSOR_FUSION := true
BOARD_USE_SENSOR_PEDOMETER := false
BOARD_USE_LEGACY_SENSOR :=true

# for recovery service
TARGET_SELECT_KEY := 28

UBOOT_POST_PROCESS := true

# camera hal v3
IMX_CAMERA_HAL_V3 := true

BOARD_HAVE_USB_CAMERA := true

# whether to accelerate camera service with openCL
# it will make camera service load the opencl lib in vendor
# and break the full treble rule
# OPENCL_2D_IN_CAMERA := true

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 5

KERNEL_NAME := Image.gz

#
# U-Boot configurations
#
TARGET_BOOTLOADER_BOARD_NAME := ccimx8xsbcpro
TARGET_BOOTLOADER_POSTFIX := bin
TARGET_BOOTLOADER_CONFIG := \
	ccimx8xsbcpro1GB:ccimx8x_sbc_pro1GB_defconfig \
	ccimx8xsbcpro2GB:ccimx8x_sbc_pro2GB_defconfig

# The U-Boot mkimage targets define the final U-Boot artifacts to generate:
#  - flash    :   Generate final U-Boot artifact that will include:
#                     - Standard U-Boot binary (u-boot.bin)
#                     - The firmware that runs in the SCU (scfw-tcm.bin)
#                     - The ARM Trusted Firmware that runs in the security controller (bl31.bin)
#                     - A container used by NXP to verify signed images (ahab-container.img)
#  - flash_all:   Like 'flash' but including the Cortex M4 firmware (CM4.bin)
TARGET_BOOTLOADER_IMXMKIMAGE_TARGETS := \
	flash \
	flash_all

# Location of the prebuilt Cortex M4 firmware to program on chip at boot.
# This firmware will be bundled with U-Boot final image using the 'flash_all' target.
TARGET_BOOTLOADER_PREBUILT_CM4 := vendor/nxp/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin

#
# Kernel configurations and device trees
#
TARGET_KERNEL_DEFCONFIG := ccimx8x_android_defconfig
TARGET_BOARD_DTS_CONFIG := \
	ccimx8x-sbc-pro:ccimx8x-sbc-pro.dtb \
	ccimx8x-sbc-pro-id135:ccimx8x-sbc-pro-id135.dtb \
	ccimx8x-sbc-pro-wb:ccimx8x-sbc-pro-wb.dtb

BOARD_SEPOLICY_DIRS := \
	$(IMX_DEVICE_PATH)/sepolicy \
	device/fsl/imx8q/sepolicy

# Disable A/B system updates and AVB (android verified boot)
AB_OTA_UPDATER := false
BOARD_AVB_ENABLE := false
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false
BOARD_USES_RECOVERY_AS_BOOT := false
TARGET_NO_RECOVERY := false

TARGET_USES_MKE2FS := true

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

# Use sparse EXT4 images
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

#
# DEA specific build time options
#
TARGET_DEA_BOOTIMAGE := true
TARGET_DEA_SPARSE_VFAT_IMAGES := true

#
# Partition sizes
# ---------------
# boot:     32 MiB
# recovery: 32 MiB
# system: 2048 MiB
# vendor:  112 MiB
#
BOARD_BOOTIMAGE_PARTITION_SIZE   := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_VENDORIMAGE_PARTITION_SIZE := 117440512
