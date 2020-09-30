-include device/fsl/common/imx_path/ImxPathConfig.mk
$(call inherit-product, device/digi/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

# Overrides
PRODUCT_NAME := ccimx6sbc
PRODUCT_DEVICE := ccimx6sbc
PRODUCT_BRAND := digi
PRODUCT_MANUFACTURER := digi
KERNEL_IMX_PATH := vendor/digi
UBOOT_IMX_PATH := vendor/digi

PRODUCT_PACKAGES += \
	com.digi.android \
	com.digi.android.xml \
	digiservices \
	libdigiservices \
	librxtxSerial

# fw_printenv/fw_setenv
PRODUCT_PACKAGES += \
	fw_printenv \
	fw_env.config

# Install TF tool in the recovery ramdisk
PRODUCT_PACKAGES += \
	trustfence-tool

# Digi Atheros wifi firmware file.
PRODUCT_PACKAGES += \
        athwlan \
        Digi_6203-6233-US \
        Digi_6203-6233-World \
        Digi_6203_2_ANT-US \
        Digi_6203_2_ANT-World \
        Digi_fw-4 \
        Digi_athtcmd_ram \
        Digi_nullTestFlow \
        Digi_utf \
        wpa_supplicant_overlay_digi.conf

# Digi Atheros bt firmware file.
PRODUCT_PACKAGES += \
	PS_ASIC_class_1 \
	PS_ASIC_class_2 \
	RamPatch

# Jars boot order.
PRODUCT_BOOT_JARS += \
	CloudConnectorAndroid

PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/init.rc:root/init.digi.rc \
	device/digi/ccimx6sbc/init.recovery.digi.rc:root/init.recovery.digi.rc \
	device/digi/ccimx6sbc/init.imx6q.rc:root/init.digi.imx6q.rc \
	device/digi/ccimx6sbc/init.imx6dl.rc:root/init.digi.imx6dl.rc \
	device/digi/ccimx6sbc/init.imx6qp.rc:root/init.digi.imx6qp.rc \
	device/digi/ccimx6sbc/ueventd.digi.rc:root/ueventd.digi.rc

PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/input/fusion-touch.idc:system/usr/idc/fusion-touch.idc \
	device/digi/ccimx6sbc/sysinfo:system/bin/sysinfo \
	device/digi/ccimx6sbc/binaries/bootanimation.zip:system/media/bootanimation.zip

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/audio_effects.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.conf \
	device/digi/ccimx6sbc/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
	device/digi/ccimx6sbc/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

# VPU firmware
PRODUCT_COPY_FILES += \
	$(LINUX_FIRMWARE_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:vendor/lib/firmware/vpu/vpu_fw_imx6d.bin \
	$(LINUX_FIRMWARE_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:vendor/lib/firmware/vpu/vpu_fw_imx6q.bin

# Vendor Interface Manifest
PRODUCT_COPY_FILES += \
	device/digi/ccimx6sbc/manifest.xml:vendor/manifest.xml


# GPU files

DEVICE_PACKAGE_OVERLAYS := device/digi/ccimx6sbc/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	device/digi/ccimx6sbc/required_hardware.xml:system/etc/permissions/required_hardware.xml

PRODUCT_COPY_FILES += \
	$(FSL_PROPRIETARY_PATH)/fsl-proprietary/gpu-viv/lib/egl/egl.cfg:system/lib/egl/egl.cfg

# HWC2 HAL
PRODUCT_PACKAGES += \
	android.hardware.graphics.composer@2.1-impl

# Gralloc HAL
PRODUCT_PACKAGES += \
	android.hardware.graphics.mapper@2.0-impl \
	android.hardware.graphics.allocator@2.0-impl \
	android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
	android.hardware.renderscript@1.0-impl

# Audio HAL
PRODUCT_PACKAGES += \
	android.hardware.audio@2.0-impl \
	android.hardware.audio@2.0-service \
	android.hardware.audio.effect@2.0-impl

# Power HAL
PRODUCT_PACKAGES += \
	android.hardware.power@1.0-impl \
	android.hardware.power@1.0-service

# Light HAL
PRODUCT_PACKAGES += \
	android.hardware.light@2.0-impl \
	android.hardware.light@2.0-service

# USB HAL
PRODUCT_PACKAGES += \
	android.hardware.usb@1.0-service

# Bluetooth HAL
PRODUCT_PACKAGES += \
	android.hardware.bluetooth@1.0-impl \
	android.hardware.bluetooth@1.0-service

# WiFi HAL
PRODUCT_PACKAGES += \
	android.hardware.wifi@1.0-service \
	wifilogd \
	wificond

# Keymaster HAL
PRODUCT_PACKAGES += \
	android.hardware.keymaster@3.0-impl

PRODUCT_PACKAGES += \
	libEGL_VIVANTE \
	libGLESv1_CM_VIVANTE \
	libGLESv2_VIVANTE \
	libGAL \
	libGLSLC \
	libVSC \
	libg2d \
	libgpuhelper

PRODUCT_PACKAGES += \
	Launcher3

PRODUCT_PROPERTY_OVERRIDES += \
	ro.internel.storage_size=/sys/block/bootdev_size

PRODUCT_PROPERTY_OVERRIDES += \
	ro.frp.pst=/dev/block/by-name/frp

PRODUCT_SYSTEM_SERVER_JARS += \
	digiservices
