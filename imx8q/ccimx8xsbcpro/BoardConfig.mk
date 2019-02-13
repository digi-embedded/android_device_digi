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

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab.bpt
ADDITION_BPT_PARTITION = \
	partition-table-7GB:device/fsl/common/partition/device-partitions-7GB-ab.bpt \
	partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab.bpt

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

# BOARD_VENDOR_KERNEL_MODULES += \
# 	$(KERNEL_OUT)/drivers/net/wireless/qcacld-2.0/wlan.ko

# Qcom 1CQ(QCA6174) BT
# BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
# BOARD_HAVE_BLUETOOTH_QCOM := true
# BOARD_HAS_QCA_BT_ROME := true
# BOARD_HAVE_BLUETOOTH_BLUEZ := false
# QCOM_BT_USE_SIBS := true
# ifeq ($(QCOM_BT_USE_SIBS), true)
# WCNSS_FILTER_USES_SIBS := true
# endif

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

KERNEL_NAME := Image

# BOARD_KERNEL_CMDLINE := init=/init androidboot.hardware=freescale androidboot.fbTileSupport=enable cma=800M@0x960M-0xe00M androidboot.primary_display=imx-drm firmware_class.path=/vendor/firmware transparent_hugepage=never swiotlb=49152 androidboot.console=ttyLP0

BOARD_PREBUILT_DTBOIMAGE := out/target/product/ccimx8xsbcpro/dtbo-ccimx8x-sbc-pro-id135.img

#
# U-Boot configurations
#
TARGET_BOOTLOADER_BOARD_NAME := ccimx8xsbcpro
TARGET_BOOTLOADER_POSTFIX := bin
TARGET_BOOTLOADER_CONFIG := \
	ccimx8xsbcpro1GB:ccimx8x_sbc_pro1GB_defconfig \
	ccimx8xsbcpro2GB:ccimx8x_sbc_pro2GB_defconfig

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

BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

# Use sparse EXT4 images
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false
