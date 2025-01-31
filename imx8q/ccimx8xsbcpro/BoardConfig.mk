# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
BOARD_BPT_INPUT_FILES += device/digi/common/partition/device-partitions-14GB-ab_super.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/digi/common/partition/device-partitions-7GB-ab_super.bpt
endif

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8qxp.img

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# -------@block_infrastructure-------
include $(CONFIG_REPO_PATH)/imx8q/BoardConfigCommon.mk

# -------@block_memory-------
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# -------@block_security-------
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
# Vendor Interface Manifest
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

# Vendor compatibility matrix
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

# -------@block_wifi-------
BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WPA_SUPPLICANT_VERSION := VER_0_8_X
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# Qcom QCA65X4 Wi-Fi
BOARD_HAVE_WIFI_QCA6574 := true
WIFI_DRIVER_MODULE_PATH := "/vendor/lib/modules/wlan.ko"
WIFI_DRIVER_MODULE_NAME := "wlan"
WIFI_DRIVER_MODULE_ARG := "enable_p2p=1"

# -------@block_bluetooth-------
# Qcom QCA65X4 BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_HAS_QCA_BT_ROME := true
QCOM_BT_USE_SIBS := false

# -------@block_kernel_bootimg-------

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.hardware=digi

# framebuffer config
BOARD_BOOTCONFIG += androidboot.fbTileSupport=enable

# memory config
BOARD_KERNEL_CMDLINE += cma=800M transparent_hugepage=never

# display config
BOARD_BOOTCONFIG += androidboot.lcd_density=240

# Only one centered kernel bootup logo
BOARD_KERNEL_CMDLINE += fbcon=logo-pos:center fbcon=logo-count:1

BOARD_BOOTCONFIG += androidboot.console=ttyLP2

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

BOARD_BOOTCONFIG += androidboot.selinux=permissive

# Keep the first one the base DTB, and then the overlays
TARGET_BOARD_DTS_CONFIG := \
	ccimx8x-sbc-pro.dtb \
	_ov_board_flexcan1_ccimx8x-sbc-pro.dtbo \
	_ov_board_flexspi_ccimx8x-sbc-pro.dtbo \
	_ov_board_gpio-watchdog_ccimx8x-sbc-pro.dtbo \
	_ov_board_hsd101pfw2-lvds_ccimx8x-sbc-pro.dtbo \
	_ov_board_lpuart3_ccimx8x-sbc-pro.dtbo \
	_ov_board_lt8912-hdmi-dsi0_ccimx8x-sbc-pro.dtbo \
	_ov_board_lvds1_ccimx8x-sbc-pro.dtbo \
	_ov_board_parallel-camera_ccimx8x-sbc-pro.dtbo \
	_ov_board_pcie-card_ccimx8x-sbc-pro.dtbo \
	_ov_board_pcie-modem_ccimx8x-sbc-pro.dtbo \
	_ov_board_user-leds_ccimx8x-sbc-pro.dtbo \
	_ov_board_v1-v3_ccimx8x-sbc-pro.dtbo \
	_ov_som_bt_ccimx8x.dtbo \
	_ov_som_mca-keypad_ccimx8x.dtbo \
	_ov_som_quad_ccimx8x.dtbo \
	_ov_som_trusty_ccimx8x.dtbo \
	_ov_som_wifi_ccimx8x.dtbo

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
	device/nxp/imx8q/sepolicy \
	device/digi/imx8q/ccimx8xsbcpro/sepolicy
