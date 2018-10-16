MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

BOOTSCRIPT_SRC := device/digi/$(TARGET_PRODUCT)/bootscript.txt
INSTALLED_BOOTSCRIPT_TARGET := $(PRODUCT_OUT)/boot.scr

.PHONY: bootscript
bootscript: $(INSTALLED_BOOTSCRIPT_TARGET)

$(INSTALLED_BOOTSCRIPT_TARGET): $(BOOTSCRIPT_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A arm -O linux -T script -C none -n "Boot script" -d $< $@
