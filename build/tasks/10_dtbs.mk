#
# This makefile requires on "device/fsl/common/build/kernel.mk" (which should be already included by the build system)
#
ifeq ($(TARGET_ARCH), arm)
DTS_ADDITIONAL_PATH :=
else ifeq ($(TARGET_ARCH), arm64)
DTS_ADDITIONAL_PATH := digi/
endif

KERNEL_DTBS := $(shell echo $(TARGET_BOARD_DTS_CONFIG) | sed -e "s,[^: ]\+:,$(KERNEL_OUT)/arch/$(TARGET_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH),g")
KERNEL_DTBS_MAKETARGET := $(firstword $(KERNEL_DTBS))

$(KERNEL_DTBS_MAKETARGET): $(KERNEL_CONFIG)
	$(hide) echo "Building $(KERNEL_ARCH) dtbs ..."
	$(call build_kernel,dtbs)

kerneldtbs: $(KERNEL_DTBS_MAKETARGET)
