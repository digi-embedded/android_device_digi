ifeq ($(strip $(TARGET_DEA_BOOTIMAGE)),true)

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

BOOTSCRIPT_SRC := $(TARGET_DEVICE_DIR)/bootscript.txt
INSTALLED_BOOTSCRIPT_TARGET := $(PRODUCT_OUT)/boot.scr

.PHONY: bootscript
bootscript: $(INSTALLED_BOOTSCRIPT_TARGET)

$(INSTALLED_BOOTSCRIPT_TARGET): $(BOOTSCRIPT_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A $(TARGET_ARCH) -O linux -T script -C none -n "Boot script" -d $< $@

endif
