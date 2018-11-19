MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

FWINSTALLER_SRC := device/digi/$(TARGET_PRODUCT)/install_android_fw_sd.txt
FWINSTALLER_TARGET := $(PRODUCT_OUT)/install_android_fw_sd.scr

.PHONY: fwinstaller
fwinstaller: $(FWINSTALLER_TARGET)

$(FWINSTALLER_TARGET): $(FWINSTALLER_SRC) | $(MKIMAGE)
	$(hide) mkdir -p $(dir $@)
	$(hide) $(MKIMAGE) -A arm -O linux -T script -C none -n "Install script" -d $< $@

droidcore: $(FWINSTALLER_TARGET)
