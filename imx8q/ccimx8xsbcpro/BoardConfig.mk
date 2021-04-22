#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/digi/imx8q/ccimx8xsbcpro

include device/digi/imx8q/BoardConfigCommon.mk

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.digi

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
BOARD_BPT_INPUT_FILES += device/digi/common/partition/device-partitions-14GB-ab_super.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/digi/common/partition/device-partitions-7GB-ab_super.bpt
endif

# Vendor Interface Manifest
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

# Vendor compatibility matrix
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := ccimx8xsbcpro

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# Qcom QCA65X4 Wi-Fi
BOARD_HAVE_WIFI_QCA65X4 := true
BOARD_HAVE_WIFI_QCA6574 := true
WIFI_DRIVER_MODULE_PATH := /vendor/lib/modules/wlan.ko
WIFI_DRIVER_MODULE_NAME := wlan
WIFI_DRIVER_MODULE_ARG := enable_p2p=1

# Qcom QCA65X4 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
QCOM_BT_USE_SIBS := false

# sensor configs
BOARD_USE_SENSOR_FUSION := true
BOARD_USE_SENSOR_PEDOMETER := false
BOARD_USE_LEGACY_SENSOR := false

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

BOARD_HAVE_USB_CAMERA := true
BOARD_HAVE_USB_MJPEG_CAMERA := false

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init androidboot.hardware=digi firmware_class.path=/vendor/firmware loop.max_part=7

# framebuffer config
BOARD_KERNEL_CMDLINE += androidboot.fbTileSupport=enable

# memory config
BOARD_KERNEL_CMDLINE += cma=1184M@0x960M-0xe00M transparent_hugepage=never

# display config
BOARD_KERNEL_CMDLINE += androidboot.lcd_density=240 androidboot.primary_display=imx-drm

# Move the kernel bootup logo to the center
BOARD_KERNEL_CMDLINE += fbcon=logo-pos:center

BOARD_KERNEL_CMDLINE += androidboot.console=ttyLP2

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_KERNEL_CMDLINE += androidboot.vendor.sysrq=1
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/ccimx8xsbcpro/dtbo-imx8qxp.img
TARGET_BOARD_DTS_CONFIG := imx8qxp:ccimx8x-sbc-pro.dtb

BOARD_SEPOLICY_DIRS := \
       device/nxp/imx8q/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

BOARD_AVB_ENABLE := true

BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := device/nxp/common/security/testkey_rsa4096.pem
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

TARGET_USES_MKE2FS := true

TARGET_BOARD_KERNEL_HEADERS := device/nxp/common/kernel-headers

# define board type
BOARD_TYPE := CONNECTCORE

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata
