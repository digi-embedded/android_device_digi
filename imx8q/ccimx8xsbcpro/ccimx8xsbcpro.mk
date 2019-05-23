# This is a FSL Android Reference Design platform based on i.MX8QP ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

IMX_DEVICE_PATH := device/digi/imx8q/ccimx8xsbcpro
DIGI_PROPRIETARY_PATH := vendor/digi/proprietary

-include device/fsl/common/imx_path/ImxPathConfig.mk
$(call inherit-product, device/digi/imx8q/ProductConfigCommon.mk)

# Overrides
PRODUCT_NAME := ccimx8xsbcpro
PRODUCT_DEVICE := ccimx8xsbcpro
PRODUCT_BRAND := digi
PRODUCT_MANUFACTURER := digi
KERNEL_IMX_PATH := vendor/digi
UBOOT_IMX_PATH := vendor/digi

PRODUCT_COPY_FILES += \
	$(IMX_DEVICE_PATH)/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.rc \
	$(IMX_DEVICE_PATH)/init.recovery.digi.rc:root/init.recovery.digi.rc \
	$(IMX_DEVICE_PATH)/init.imx8qxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.imx8qxp.rc \
	$(IMX_DEVICE_PATH)/init.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.digi.usb.rc \
	$(IMX_DEVICE_PATH)/ueventd.digi.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
	$(IMX_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg \
	$(IMX_DEVICE_PATH)/fstab.digi:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.digi \
	$(IMX_DEVICE_PATH)/fstab.digi.sd:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.digi.sd

PRODUCT_COPY_FILES += \
	device/digi/common/runtime/sysinfo:$(TARGET_COPY_OUT_VENDOR)/bin/sysinfo \
	device/digi/common/runtime/bootanimation.zip:system/media/bootanimation.zip

# License
PRODUCT_COPY_FILES += \
	device/digi/common/legal/license.html:$(TARGET_COPY_OUT_VENDOR)/etc/license.html

# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
	$(IMX_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml \
	$(IMX_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
	$(IMX_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	$(IMX_DEVICE_PATH)/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-imx.xml \
	device/fsl/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
	device/fsl/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
	device/fsl/common/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
	frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
	frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
	frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
	frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
	frameworks/native/data/etc/android.hardware.vulkan.version-1_0_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_0_3.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
	frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
	frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
	frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
	frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
	frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
	$(IMX_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
	$(IMX_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy \
	$(IMX_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy

USE_XML_AUDIO_POLICY_CONF := 1

# VPU files
PRODUCT_COPY_FILES += \
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_dec.bin:vendor/firmware/vpu/vpu_fw_imx8_dec.bin \
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_enc.bin:vendor/firmware/vpu/vpu_fw_imx8_enc.bin

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

# GPU openCL g2d
PRODUCT_COPY_FILES += \
	$(IMX_PATH)/imx/opencl-2d/cl_g2d.cl:$(TARGET_COPY_OUT_VENDOR)/etc/cl_g2d.cl

# HWC2 HAL
PRODUCT_PACKAGES += \
	android.hardware.graphics.composer@2.1-impl \
	android.hardware.graphics.composer@2.1-service

# Gralloc HAL
PRODUCT_PACKAGES += \
	android.hardware.graphics.mapper@2.0-impl \
	android.hardware.graphics.allocator@2.0-impl \
	android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
	android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
	libEGL_VIVANTE \
	libGLESv1_CM_VIVANTE \
	libGLESv2_VIVANTE \
	gralloc_viv.imx8 \
	libGAL \
	libGLSLC \
	libVSC \
	libg2d \
	libgpuhelper \
	libSPIRV_viv \
	libvulkan_VIVANTE \
	vulkan.imx8 \
	libCLC \
	libLLVM_viv \
	libOpenCL \
	libopencl-2d \
	gatekeeper.imx8

PRODUCT_PACKAGES += \
	android.hardware.audio@4.0-impl:32 \
	android.hardware.audio@2.0-service \
	android.hardware.audio.effect@4.0-impl:32 \
	android.hardware.sensors@1.0-impl \
	android.hardware.sensors@1.0-service \
	android.hardware.power@1.0-impl \
	android.hardware.power@1.0-service \
	android.hardware.light@2.0-impl \
	android.hardware.light@2.0-service \
	android.hardware.configstore@1.1-service \
	configstore@1.1.policy

# Neural Network HAL
PRODUCT_PACKAGES += \
	android.hardware.neuralnetworks@1.0-service-imx-nn

# imx8 sensor HAL libs.
PRODUCT_PACKAGES += \
	sensors.imx8

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

# QCA6574
PRODUCT_PACKAGES += \
	qca6574_wlan.ko \
	qwlan30 \
	fakeboar \
	otp \
	utf \
	WCNSS_cfg \
	WCNSS_qcom_cfg

# QCA6574 Bluetooth Firmware
PRODUCT_PACKAGES += \
	nvm_tlv \
	rampatch_tlv

# Custom Digi packages
PRODUCT_PACKAGES += \
	com.digi.android \
	com.digi.android.xml \
	DigiLicenseApp \
	DigiServicesApp \
	digiservices \
	digiservices.xml \
	libdigiservices \
	librxtxSerial \
	libdiginativeservice \
	diginativeservice

# Jars boot order.
PRODUCT_BOOT_JARS += \
	CloudConnectorAndroid \
	digiservices \
	RXTXcomm

# Keymaster HAL
PRODUCT_PACKAGES += \
	android.hardware.keymaster@3.0-impl \
	android.hardware.keymaster@3.0-service

# DRM HAL
TARGET_ENABLE_MEDIADRM_64 := true
PRODUCT_PACKAGES += \
	android.hardware.drm@1.0-impl \
	android.hardware.drm@1.0-service

# new gatekeeper HAL
PRODUCT_PACKAGES += \
	android.hardware.gatekeeper@1.0-impl \
	android.hardware.gatekeeper@1.0-service

PRODUCT_PROPERTY_OVERRIDES += \
	ro.internel.storage_size=/sys/block/mmcblk0/size

# ro.product.first_api_level indicates the first api level the device has commercially launched on.
PRODUCT_PROPERTY_OVERRIDES += \
	ro.product.first_api_level=28

PRODUCT_PACKAGES += \
	libvpu-malone \
	lib_omx_v4l2_common_arm11_elinux \
	lib_omx_v4l2_dec_arm11_elinux \
	lib_omx_v4l2_enc_arm11_elinux

PRODUCT_PACKAGES += \
	fw_printenv \
	fw_env.config

PRODUCT_PACKAGES += \
	mca_tool

# Add oem unlocking option in settings.
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/frp
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

BOARD_VNDK_VERSION := current
