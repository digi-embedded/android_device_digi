KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64
# IMX8MM_USES_GKI := true

#Enable this to config 1GB ddr on evk_imx8mm
#LOW_MEMORY := true

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

# QCACLD wifi driver module
BOARD_VENDOR_KERNEL_MODULES += $(TARGET_OUT_INTERMEDIATES)/QCACLD_OBJ/wlan.ko
QCACLD_WIFI_INTERFACE := sdio

# SPI CAN controller on DVK
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_OUT)/drivers/net/can/spi/mcp25xxfd/mcp25xxfd.ko
