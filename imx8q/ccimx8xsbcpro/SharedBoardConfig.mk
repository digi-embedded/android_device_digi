KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

# QCACLD wifi driver module
BOARD_VENDOR_KERNEL_MODULES += $(TARGET_OUT_INTERMEDIATES)/QCACLD_OBJ/wlan.ko
QCACLD_WIFI_INTERFACE := pci
