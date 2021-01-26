#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/nxp/imx8q/mek_8q

include device/nxp/imx8q/BoardConfigCommon.mk

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.nxp

# Support gpt
ifeq ($(PRODUCT_IMX_DUAL_BOOTLOADER),true)
  ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
    BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab-dual-bootloader_super.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab-dual-bootloader_super.bpt
  else
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab-dual-bootloader-no-product.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab-dual-bootloader-no-product.bpt
    else
      BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab-dual-bootloader.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab-dual-bootloader.bpt
    endif
  endif
else
  ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
      BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab_super.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab_super.bpt
  else
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab-no-product.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab-no-product.bpt
    else
      BOARD_BPT_INPUT_FILES += device/nxp/common/partition/device-partitions-13GB-ab.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/nxp/common/partition/device-partitions-28GB-ab.bpt
    endif
  endif
endif


# Vendor Interface Manifest
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

# Vendor compatibility matrix
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := MEK

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# NXP 8997 BLUETOOTH
BOARD_HAVE_BLUETOOTH_NXP := true

# sensor configs
BOARD_USE_SENSOR_FUSION := true
BOARD_USE_SENSOR_PEDOMETER := false
BOARD_USE_LEGACY_SENSOR :=true

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

BOARD_HAVE_USB_CAMERA := true
BOARD_HAVE_USB_MJPEG_CAMERA := false

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init androidboot.hardware=nxp firmware_class.path=/vendor/firmware loop.max_part=7

# framebuffer config
BOARD_KERNEL_CMDLINE += androidboot.fbTileSupport=enable

# memory config
BOARD_KERNEL_CMDLINE += cma=1184M@0x960M-0xe00M transparent_hugepage=never

# display config
BOARD_KERNEL_CMDLINE += androidboot.lcd_density=240 androidboot.primary_display=imx-drm

# wifi config
BOARD_KERNEL_CMDLINE += androidboot.wificountrycode=CN moal.mod_para=wifi_mod_para.conf

BOARD_KERNEL_CMDLINE += androidboot.console=ttyLP0

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_KERNEL_CMDLINE += androidboot.vendor.sysrq=1
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/mek_8q/dtbo-imx8qm.img
ifeq ($(OTA_TARGET),8qxp)
BOARD_PREBUILT_DTBOIMAGE := out/target/product/mek_8q/dtbo-imx8qxp.img
endif
ifeq ($(OTA_TARGET),8qxp-c0)
BOARD_PREBUILT_DTBOIMAGE := out/target/product/mek_8q/dtbo-imx8qxp.img
endif

# For Android Auto with M4 EVS, fstab entries in dtb are in the form of non-dynamic partition by default
# For Android Auto without M4 EVS, fstab entries in dtb are in the form of dynamic partition by default
# For standard Android, the form of fstab entries in dtb depend on the value of "TARGET_USE_DYNAMIC_PARTITIONS"
  ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-product.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-product.dtb
    else
      # imx8qm standard android; MIPI-HDMI display
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640.dtb
      # imx8qm standard android; MIPI panel display
      TARGET_BOARD_DTS_CONFIG += imx8qm-mipi-panel:imx8qm-mek-dsi-rm67191.dtb
      # imx8qm standard android; HDMI display
      TARGET_BOARD_DTS_CONFIG += imx8qm-hdmi:imx8qm-mek-hdmi.dtb
      # imx8qm standard android; Multiple display
      TARGET_BOARD_DTS_CONFIG += imx8qm-md:imx8qm-mek-md.dtb
      # imx8qxp standard android; MIPI-HDMI display
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg.dtb
      TARGET_BOARD_DTS_CONFIG += imx8dx:imx8dx-mek-ov5640.dtb
    endif #IMX_NO_PRODUCT_PARTITION
  else
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-product-no-dynamic_partition.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-product-no-dynamic_partition.dtb
    else
      TARGET_BOARD_DTS_CONFIG := imx8qm:imx8qm-mek-ov5640-no-dynamic_partition.dtb
      TARGET_BOARD_DTS_CONFIG += imx8qxp:imx8qxp-mek-ov5640-rpmsg-no-dynamic_partition.dtb
    endif
  endif


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
BOARD_TYPE := MEK

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata