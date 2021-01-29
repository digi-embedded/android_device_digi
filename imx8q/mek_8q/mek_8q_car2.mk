# This is a FSL Android Reference Design platform based on i.MX8QM/8QXP MEK board
# It will inherit from NXP core product which in turn inherit from Google generic

IMX_DEVICE_PATH := device/nxp/imx8q/mek_8q

# Don't enable vendor boot for Android Auto without M4 EVS for now
TARGET_USE_VENDOR_BOOT ?= false

# Android Auto without M4 EVS uses dynamic partition
TARGET_USE_DYNAMIC_PARTITIONS ?= true

include $(IMX_DEVICE_PATH)/mek_8q_car.mk

PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8q_car/xen:xen

# Overrides
PRODUCT_NAME := mek_8q_car2
