#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MM
BOARD_TYPE := DVK
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
FSL_VPU_OMX_ONLY := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := false
HAVE_FSL_IMX_PXP := false
BOARD_KERNEL_BASE := 0x40400000
TARGET_GRALLOC_VERSION := v3
TARGET_USES_HWC2 := true
TARGET_HWCOMPOSER_VERSION := v2.0
USE_OPENGL_RENDERER := true
TARGET_HAVE_VULKAN := true
ENABLE_CFI=false

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_HAVE_VPU \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MM
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false

#
# Product-specific compile-time definitions.
#
IMX_DEVICE_PATH := device/digi/imx8m/ccimx8mmdvk

include device/digi/imx8m/BoardConfigCommon.mk

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.digi

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
BOARD_BPT_INPUT_FILES += device/digi/common/partition/device-partitions-7GB-ab_super.bpt
endif

# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := ccimx8mmdvk

USE_OPENGL_RENDERER := true

BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# Qcom QCA65X4 Wi-Fi
BOARD_HAVE_WIFI_QCA65X4 := true
WIFI_DRIVER_MODULE_PATH := /vendor/lib/modules/wlan.ko
WIFI_DRIVER_MODULE_NAME := wlan
WIFI_DRIVER_MODULE_ARG := "asyncintdelay=0x2 writecccr1=0xf2 writecccr1value=0xf writecccr2=0xf1 writecccr2value=0xa8 writecccr3=0xf0 writecccr3value=0xa1 writecccr4=0x15 writecccr4value=0x30 enable_p2p=1"

# Qcom QCA65X4 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
QCOM_BT_USE_SIBS := false

BOARD_USE_SENSOR_FUSION := true

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

BOARD_HAVE_USB_CAMERA := true
BOARD_HAVE_USB_MJPEG_CAMERA := false

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := device/nxp/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

TARGET_USES_MKE2FS := true

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init androidboot.console=ttymxc0 androidboot.hardware=digi firmware_class.path=/vendor/firmware loop.max_part=7

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# display config
BOARD_KERNEL_CMDLINE += androidboot.lcd_density=240 androidboot.primary_display=imx-drm

# Move the kernel bootup logo to the center
BOARD_KERNEL_CMDLINE += fbcon=logo-pos:center

# low memory device build config
ifeq ($(LOW_MEMORY),true)
BOARD_KERNEL_CMDLINE += cma=320M@0x400M-0xb80M androidboot.displaymode=720p galcore.contiguousSize=33554432
else
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_KERNEL_CMDLINE += androidboot.vendor.sysrq=1
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/ccimx8mmdvk/dtbo-imx8mm.img
TARGET_BOARD_DTS_CONFIG += imx8mm:ccimx8mm-dvk.dtb

BOARD_SEPOLICY_DIRS := \
       device/nxp/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

TARGET_BOARD_KERNEL_HEADERS := device/nxp/common/kernel-headers

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata
