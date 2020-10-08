#
# Product-specific compile-time definitions.
#

include device/fsl/imx6/soc/imx6dq.mk
include device/digi/build_id.mk
include device/fsl/imx6/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

# Build for EXT4
BUILD_TARGET_FS ?= ext4
include device/fsl/imx6/imx6_target_fs.mk

TARGET_RECOVERY_FSTAB = device/digi/ccimx6sbc/fstab.digi

PRODUCT_MODEL := ccimx6sbc

# ATHEROS Wi-Fi device support
BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
TARGET_DIGI_ATHEROS_FW                      := true
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_qcwcn
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_qcwcn

BOARD_VENDOR_KERNEL_MODULES += \
	$(KERNEL_OUT)/drivers/net/wireless/ath/ath6kl/ath6kl_core.ko \
	$(KERNEL_OUT)/drivers/net/wireless/ath/ath6kl/ath6kl_sdio.ko

# for recovery service
TARGET_SELECT_KEY := 28

# atheros 3k BT
BOARD_HAVE_BLUETOOTH_AR3K := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/digi/ccimx6sbc/bluetooth

# GPU configuration
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false
BOARD_EGL_CFG := $(FSL_PROPRIETARY_PATH)/fsl-proprietary/gpu-viv/lib/egl/egl.cfg

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# camera hal v3
IMX_CAMERA_HAL_V3 := true

# define consumer IR HAL support
IMX6_CONSUMER_IR_HAL := false

# LVDS backlight support using the Dialog DA9063 PMIC
BOARD_HAVE_DA9063_BACKLIGHT := true

# NXP sensor support
BOARD_HAS_SENSOR := false

BOARD_SEPOLICY_DIRS := \
	device/digi/ccimx6sbc/sepolicy \
	device/fsl/imx6/sepolicy

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

# Build local configuration
TARGET_BOARD_LOCALCONFIG_MK := device/digi/build/tasks/01_localconf.mk

#
# U-Boot configurations
#
# The build system will compile images for all of them, but the SDCARD image
# will use the first one of the list.
#
TARGET_BOOTLOADER_BOARD_NAME := ccimx6sbc
TARGET_BOOTLOADER_POSTFIX := imx
TARGET_DTB_POSTFIX := -dtb
TARGET_UBOOT_CONFIG := \
	ccimx6qsbc \
	ccimx6qsbc2GB \
	ccimx6dlsbc

TARGET_KERNEL_DEFCONF := ccimx6sbc_android_defconfig
TARGET_BOARD_DTS_CONFIG := \
	imx6q-id129:imx6q-ccimx6sbc-id129.dtb \
	imx6q-id130:imx6q-ccimx6sbc-id130.dtb \
	imx6dl-id131:imx6dl-ccimx6sbc-id131.dtb \
	imx6dl:imx6dl-ccimx6sbc.dtb \
	imx6dl-wb:imx6dl-ccimx6sbc-wb.dtb \
	imx6dl-w:imx6dl-ccimx6sbc-w.dtb \
	imx6q:imx6q-ccimx6sbc.dtb \
	imx6q-wb:imx6q-ccimx6sbc-wb.dtb \
	imx6q-w:imx6q-ccimx6sbc-w.dtb

#
# DEA specific build time options
#
TARGET_DEA_BOOTIMAGE := true
TARGET_DEA_BUILDINFO := true
TARGET_DEA_FWINSTALLER := true
TARGET_DEA_SDIMAGE := true

# Enable DEA specific makefiles for building firmware
TARGET_DEA_FIRMWARE_MK := true

# Use sparse images
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

#
# Partition sizes
# ---------------
# boot:     32 MiB
# recovery: 32 MiB
# system: 1024 MiB
# vendor:  112 MiB
#
BOARD_BOOTIMAGE_PARTITION_SIZE   := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1073741824
BOARD_VENDORIMAGE_PARTITION_SIZE := 117440512

# CAAM ENCRYPTION (FULL DISK ENCRYPTION)
TARGET_CAAM_ENCRYPTION_SUPPORT := true
