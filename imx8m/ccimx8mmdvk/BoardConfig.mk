# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#
#IMX_DEVICE_PATH := device/digi/imx8m/ccimx8mmdvk

#
# SoC-specific compile-time definitions.
#

# -------@block_infrastructure-------
include $(CONFIG_REPO_PATH)/imx8m/BoardConfigCommon.mk

#BOARD_SOC_TYPE := IMX8MM
BOARD_TYPE := DVK
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
FSL_VPU_OMX_ONLY := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_VPU_TYPE

#cSOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MM
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = false

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# -------@block_memory-------
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
BOARD_BPT_INPUT_FILES += device/digi/common/partition/device-partitions-7GB-ab_super.bpt
endif

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mm.img

# -------@block_security-------
ENABLE_CFI=false

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256


# -------@block_treble-------
# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------
BOARD_WLAN_DEVICE            := qcwcn
WPA_SUPPLICANT_VERSION	     := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# Qcom QCA65X4 Wi-Fi
BOARD_HAVE_WIFI_QCA6574 := true
WIFI_DRIVER_MODULE_PATH := "/vendor/lib/modules/wlan.ko"
WIFI_DRIVER_MODULE_NAME := "wlan"
WIFI_DRIVER_MODULE_ARG := "asyncintdelay=0x2 writecccr1=0xf2 writecccr1value=0xf writecccr2=0xf1 writecccr2value=0xa8 writecccr3=0xf0 writecccr3value=0xa1 writecccr4=0x15 writecccr4value=0x30 enable_p2p=1"

# -------@block_bluetooth-------
# Qcom QCA65X4 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
QCOM_BT_USE_SIBS := false

# -------@block_kernel_bootimg------
CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init androidboot.console=ttymxc0 firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.hardware=digi

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# display config
BOARD_BOOTCONFIG += androidboot.lcd_density=240

# Only one centered kernel bootup logo
BOARD_KERNEL_CMDLINE += fbcon=logo-pos:center fbcon=logo-count:1

# low memory device build config
ifeq ($(LOW_MEMORY),true)
BOARD_KERNEL_CMDLINE += cma=320M@0x400M-0xb80M galcore.contiguousSize=33554432
BOARD_BOOTCONFIG += androidboot.displaymode=720p
else
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M
endif

# Disable fw_devlink.strict
BOARD_KERNEL_CMDLINE += fw_devlink.strict=0

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_KERNEL_CMDLINE += androidboot.vendor.sysrq=1
endif

BOARD_BOOTCONFIG += androidboot.selinux=permissive

# Keep the first one the base DTB, and then the overlays
TARGET_BOARD_DTS_CONFIG := \
	ccimx8mm-dvk.dtb \
	ccimx8m-dvk_flexspi.dtbo \
	ccimx8m-dvk_gpio-watchdog.dtbo \
	ccimx8m-dvk_hsd101pfw2-lvds.dtbo \
	ccimx8m-dvk_lvds.dtbo \
	ccimx8m-dvk_user-leds.dtbo \
	ccimx8m_bt.dtbo \
	ccimx8m_mca-keypad.dtbo \
	ccimx8m_trusty.dtbo \
	ccimx8m_wifi.dtbo

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       device/nxp/imx8m/sepolicy \
       device/digi/imx8m/ccimx8mmdvk/sepolicy

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

