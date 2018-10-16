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
TARGET_RECOVERY_FSTAB = device/digi/ccimx6sbc/fstab.freescale
PRODUCT_COPY_FILES +=	\
	device/fsl/sabresd_6dq/fstab.freescale:root/fstab.freescale

# Vendor Interface Manifest
PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/manifest.xml:vendor/manifest.xml

TARGET_BOOTLOADER_BOARD_NAME := ccimx6sbc
PRODUCT_MODEL := ccimx6sbc

# TODO: If we rework/rename the board makefiles we can use some of the standard
# Android variables to get the platform name (i.e. TARGET_BOARD_PLATFORM).
TARGET_PLATFORM_NAME := ccimx6sbc

# ATHEROS Wi-Fi device support
BOARD_WLAN_VENDOR            := ATHEROS
BOARD_WLAN_DEVICE            := DIGI_ATH
WPA_SUPPLICANT_VERSION       := VER_0_8_UNITE
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
TARGET_DIGI_ATHEROS_FW                      := true
BOARD_HOSTAPD_PRIVATE_LIB_QCOM              := lib_driver_cmd_qcwcn
BOARD_WPA_SUPPLICANT_PRIVATE_LIB_QCOM       := lib_driver_cmd_qcwcn

# for recovery service
TARGET_SELECT_KEY := 28

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# atheros 3k BT
BOARD_USE_AR3K_DIGI_BLUETOOTH := true
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

BOARD_HAS_SENSOR := true

BOARD_SEPOLICY_DIRS := \
	device/fsl/imx6/sepolicy \
	device/digi/ccimx6sbc/sepolicy

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

#
# U-Boot configurations
#
# The build system will compile images for all of them, but the SDCARD image
# will use the first one of the list.
#
TARGET_BOOTLOADER_POSTFIX := imx
TARGET_DTB_POSTFIX := -dtb
TARGET_BOOTLOADER_CONFIG := \
	ccimx6qsbc:ccimx6qsbc_defconfig \
	ccimx6qsbc2GB:ccimx6qsbc2GB_defconfig \
	ccimx6qsbc512MB:ccimx6qsbc512MB_defconfig

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

# Do not include key verification in the recovery app
# neither verification keys in the recovery ramdisk
NO_RECOVERY_KEY_VERIFICATION := true

# Use raw images when generating OTA package
OTA_USE_RAW_IMAGES := true

# Omit prerequisite in OTA update
# The prerequisite checks if the date of the build on the device is older than
# (or the same as) the new build in the OTA to be installed.
OTA_OMIT_PREREQUISITE := false

# Build VFAT boot image
TARGET_DEA_BOOTIMAGE := true

# Build firmware installer script
TARGET_DEA_FWINSTALLER := true

# Build SDCARD image
TARGET_DEA_SDCARDIMAGE := true

#
# Partition sizes
# ---------------
# boot:     64 MiB
# system:  512 MiB
# recovery: 64 MiB
#
BOARD_BOOTIMAGE_PARTITION_SIZE   := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1073741824
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
