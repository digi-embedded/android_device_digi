# This is a FSL Android Reference Design platform based on i.MX8QP ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

IMX_DEVICE_PATH := device/digi/imx8q/ccimx8xsbcpro

# configs shared between uboot, kernel and Android rootfs
include $(IMX_DEVICE_PATH)/SharedBoardConfig.mk

# Include PATHs from NXP's device folder
-include device/nxp/common/imx_path/ImxPathConfig.mk

ifneq ($(IMX8_BUILD_32BIT_ROOTFS),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif # IMX8_BUILD_32BIT_ROOTFS

$(call inherit-product, device/digi/imx8q/ProductConfigCommon.mk)
include device/digi/imx8q/ProductConfigCommon.mk

# Overrides
PRODUCT_NAME := ccimx8xsbcpro
PRODUCT_DEVICE := ccimx8xsbcpro
PRODUCT_MODEL := CCIMX8XSBCPRO

PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/power
PRODUCT_SOONG_NAMESPACES += hardware/google/pixel

SOONG_CONFIG_IMXPLUGIN_IMX_CAR = false
SOONG_CONFIG_IMXPLUGIN_BOARD_USE_LEGACY_SENSOR = true

#Enable this to choose 32 bit user space build
#IMX8_BUILD_32BIT_ROOTFS := true

# Enable this to support vendor boot and boot header v3, this would be a MUST for GKI
TARGET_USE_VENDOR_BOOT ?= true

#Enable this to use dynamic partitions for the readonly partitions not touched by bootloader
TARGET_USE_DYNAMIC_PARTITIONS ?= true
#If the device is retrofit to have dynamic partition feature, set this variable to true to build
#the images and OTA package. Here is a demo to update 10.0.0_1.0.0 to 10.0.0_2.0.0 or higher
TARGET_USE_RETROFIT_DYNAMIC_PARTITION ?= false

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
  PRODUCT_USE_DYNAMIC_PARTITIONS := true
  BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
  BOARD_SUPER_IMAGE_IN_UPDATE_PACKAGE := true
  ifeq ($(TARGET_USE_RETROFIT_DYNAMIC_PARTITION),true)
    PRODUCT_RETROFIT_DYNAMIC_PARTITIONS := true
    BOARD_SUPER_PARTITION_METADATA_DEVICE := system
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor
      BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 2952790016
      BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 536870912
    else
      BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor product
      BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 1610612736
      BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 536870912
      BOARD_SUPER_PARTITION_PRODUCT_DEVICE_SIZE := 1879048192
    endif
  endif
endif

# Include keystore attestation keys and certificates.
ifeq ($(PRODUCT_IMX_TRUSTY),true)
-include $(IMX_SECURITY_PATH)/attestation/imx_attestation.mk
endif

# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml \
    $(IMX_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(IMX_DEVICE_PATH)/input-port-associations.xml:$(TARGET_COPY_OUT_VENDOR)/etc/input-port-associations.xml \
    $(IMX_DEVICE_PATH)/init.imx8qm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.imx8qm.rc \
    $(IMX_DEVICE_PATH)/init.imx8qxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.imx8qxp.rc \
    $(IMX_DEVICE_PATH)/init.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.usb.rc \
    $(IMX_DEVICE_PATH)/ueventd.digi.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    device/nxp/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    device/nxp/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    device/nxp/common/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# To support multiple pcm device on cs42888, need delete below two lines:
#    device/nxp/common/audio-json/wm8960_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/wm8960_config.json \
#    device/nxp/common/audio-json/cs42888_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/cs42888_config.json \
# Then add below line:
#    device/nxp/common/audio-json/cs42888_multi_device_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/cs42888_config.json \

# Audio card json
PRODUCT_COPY_FILES += \
    device/nxp/common/audio-json/wm8960_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/wm8960_config.json \
    device/nxp/common/audio-json/cs42888_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/cs42888_config.json \
    device/nxp/common/audio-json/cdnhdmi_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/cdnhdmi_config.json \
    device/nxp/common/audio-json/btsco_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/btsco_config.json \
    device/nxp/common/audio-json/readme.txt:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/readme.txt

# Copy rpmb test key and AVB test public key
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_COPY_FILES += \
    device/nxp/common/security/rpmb_key_test.bin:rpmb_key_test.bin \
    device/nxp/common/security/testkey_public_rsa4096.bin:testkey_public_rsa4096.bin
endif

PRODUCT_COPY_FILES += \
    device/digi/imx8q/ccimx8xsbcpro/camera_config_imx8qm.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8qm.json \
    device/digi/imx8q/ccimx8xsbcpro/camera_config_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8qxp.json \
    device/digi/imx8q/ccimx8xsbcpro/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.rc \
    $(IMX_DEVICE_PATH)/fstab.digi:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.digi \
    $(IMX_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml \
    $(IMX_DEVICE_PATH)/init.recovery.digi.rc:root/init.recovery.digi.rc \
    $(IMX_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg

# We load the fstab from device tree so this is not needed, but since no kernel modules are installed to vendor
# boot ramdisk so far, we need this step to generate the vendor-ramdisk folder or build process would fail. This
# can be deleted once we figure out what kernel modules should be put into the vendor boot ramdisk.
ifeq ($(TARGET_USE_VENDOR_BOOT),true)
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/fstab.digi:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.digi
endif

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level-2020-03-01.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:vendor/etc/permissions/android.hardware.camera.external.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy \
    $(IMX_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
    device/nxp/common/seccomp_policy/codec2.vendor.base.policy:vendor/etc/seccomp_policy/codec2.vendor.base.policy \
    device/nxp/common/seccomp_policy/codec2.vendor.ext.policy:vendor/etc/seccomp_policy/codec2.vendor.ext.policy

USE_XML_AUDIO_POLICY_CONF := 1

# VPU files
PRODUCT_COPY_FILES += \
    $(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_dec.bin:vendor/firmware/vpu/vpu_fw_imx8_dec.bin \
    $(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_enc.bin:vendor/firmware/vpu/vpu_fw_imx8_enc.bin

# fastboot_imx_flashall scripts, fsl-sdcard-partition and uuu_imx_android_flash scripts
PRODUCT_COPY_FILES += \
    device/nxp/common/tools/fastboot_imx_flashall.bat:fastboot_imx_flashall.bat \
    device/nxp/common/tools/fastboot_imx_flashall.sh:fastboot_imx_flashall.sh \
    device/nxp/common/tools/uuu_imx_android_flash.bat:uuu_imx_android_flash.bat \
    device/nxp/common/tools/uuu_imx_android_flash.sh:uuu_imx_android_flash.sh

PRODUCT_COPY_FILES += \
     device/digi/imx8q/ccimx8xsbcpro/powerhint_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/powerhint_imx8qxp.json \
     device/digi/imx8q/ccimx8xsbcpro/powerhint_imx8qm.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/powerhint_imx8qm.json

# Set permission for GMS packages
PRODUCT_COPY_FILES += \
	  device/nxp/imx8q/permissions/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp.permissions-imx.xml \

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
    device/nxp/common/tools/imx-sdcard-partition.sh:imx-sdcard-partition.sh

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi xxhdpi

# GPU openCL g2d
PRODUCT_COPY_FILES += \
    $(IMX_PATH)/imx/opencl-2d/cl_g2d.cl:$(TARGET_COPY_OUT_VENDOR)/etc/cl_g2d.cl

# GPU openCL SDK header file
-include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/include/CL/cl_sdk.mk

# GPU openCL icdloader config file
-include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/gpu-viv/icdloader/icdloader.mk

# GPU openVX SDK header file
-include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/include/nnxc_kernels/nnxc_kernels.mk

# HWC2 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.4-service

# Charger Mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.charger.no_ui=false

# Do not skip charger_not_need trigger by default
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.skip.charger_not_need=0

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
        libEGL_VIVANTE \
        libGLESv1_CM_VIVANTE \
        libGLESv2_VIVANTE \
        gralloc_viv.imx \
        libGAL \
        libGLSLC \
        libVSC \
        libg2d-dpu \
        libg2d-viv \
        libgpuhelper \
        libSPIRV_viv \
        libvulkan_VIVANTE \
        vulkan.imx \
        libCLC \
        libLLVM_viv \
        libOpenCL \
        libg2d-opencl \
        libOpenVX \
        libOpenVXU \
        libNNVXCBinary-evis \
        libNNVXCBinary-evis2 \
        libNNVXCBinary-lite \
        libOvx12VXCBinary-evis \
        libOvx12VXCBinary-evis2 \
        libOvx12VXCBinary-lite \
        libNNGPUBinary-evis \
        libNNGPUBinary-evis2 \
        libNNGPUBinary-lite \
        libNNGPUBinary-ulite \
        libNNArchPerf \
        libarchmodelSw \
        imx_evs_app \
        imx_evs_app_default_resources

PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl:32 \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@6.0-impl:32 \
    android.hardware.power@1.3-service.imx \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.configstore@1.1-service \
    configstore@1.1.policy

# Thermal HAL
PRODUCT_COPY_FILES += \
    device/digi/imx8q/ccimx8xsbcpro/thermal_info_config_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/thermal_info_config_imx8qxp.json \
    device/digi/imx8q/ccimx8xsbcpro/thermal_info_config_imx8qm.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/thermal_info_config_imx8qm.json

# Neural Network HAL and Lib
PRODUCT_PACKAGES += \
    libovxlib \
    libnnrt \
    android.hardware.neuralnetworks@1.2-service-vsi-npu-server

# imx8 sensor HAL libs.
PRODUCT_PACKAGES += \
        sensors.imx

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service.imx

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wifilogd \
    wificond

# WiFi RRO
PRODUCT_PACKAGES += \
    WifiOverlay

# Wifi regulatory
PRODUCT_COPY_FILES += \
    external/wireless-regdb/regulatory.db:vendor/firmware/regulatory.db \
    external/wireless-regdb/regulatory.db.p7s:vendor/firmware/regulatory.db.p7s

# Bluetooth vendor config
PRODUCT_PACKAGES += \
    bt_vendor.conf

PRODUCT_COPY_FILES += \
    vendor/nxp/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/hdmitxfw.bin

# hardware backed keymaster service
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-service.trusty
endif
# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-service-imx

# DRM HAL
TARGET_ENABLE_MEDIADRM_64 := true
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software-imx

# Add Trusty OS backed gatekeeper and secure storage proxy
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.trusty \
    storageproxyd
endif

#Dumpstate HAL 1.1 support
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.1-service.imx

ifeq ($(PRODUCT_IMX_TRUSTY),true)
#Oemlock HAL 1.0 support
PRODUCT_PACKAGES += \
    android.hardware.oemlock@1.0-service.imx
endif

ifneq ($(BUILD_TARGET_FS),ubifs)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/by-name/presistdata
endif

# Tensorflow lite camera demo
PRODUCT_PACKAGES += \
                    tflitecamerademo

PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service

# Add oem unlocking option in settings.
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

BOARD_VNDK_VERSION := current

# Included GMS package
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
PRODUCT_SOONG_NAMESPACES += vendor/partner_gms

#DRM Widevine 1.2 L3 support
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.3-service.widevine \
    android.hardware.drm@1.3-service.clearkey \
    libwvdrmcryptoplugin \
    libwvhidl \
    libwvdrmengine \

# Specify rollback index for vbmeta and boot partition
ifneq ($(AVB_RBINDEX),)
BOARD_AVB_ROLLBACK_INDEX := $(AVB_RBINDEX)
else
BOARD_AVB_ROLLBACK_INDEX := 0
endif

ifneq ($(AVB_BOOT_RBINDEX),)
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(AVB_BOOT_RBINDEX)
else
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
endif

#set default lib name for g2d, which will be linked
#in OpenMAX repo
IMX-DEFAULT-G2D-LIB := libg2d-dpu

ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
ifneq ($(IMX8_BUILD_32BIT_ROOTFS),true)
INSTALL_64BIT_LIBRARY := true
endif
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp_aacp_dec/imx_dsp_aacp_dec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp_codec/imx_dsp_codec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp_wma_dec/imx_dsp_wma_dec.mk
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp/imx_dsp_8q.mk
endif

# Resume on Reboot support
PRODUCT_PACKAGES += \
    android.hardware.rebootescrow-service.default

PRODUCT_PROPERTY_OVERRIDES += \
    ro.rebootescrow.device=/dev/block/pmem0

PRODUCT_SOONG_NAMESPACES += hardware/google/camera
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/camera

$(call  inherit-product-if-exists, vendor/nxp-private/security/nxp_security.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
