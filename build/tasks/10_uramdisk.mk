MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_URAMDISK_TARGET := $(PRODUCT_OUT)/uramdisk.img

.PHONY: uramdisk
uramdisk: $(INSTALLED_URAMDISK_TARGET)

$(INSTALLED_URAMDISK_TARGET): $(INSTALLED_RAMDISK_TARGET) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A arm -O linux -T ramdisk -n "Android U-Boot ramdisk" -d $< $@
