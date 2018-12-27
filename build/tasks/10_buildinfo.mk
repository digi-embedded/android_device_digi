# DATETIME is expected to be set from the environment (Jenkins)
ifndef DATETIME
DATETIME = $(shell date +'%Y%m%d%H%M%S')
endif

BUILDINFO_TARGET = $(TARGET_OUT_ETC)/build

.PHONY: buildinfo
buildinfo: $(BUILDINFO_TARGET)

$(BUILDINFO_TARGET):
	$(hide) mkdir -p $(dir $@)
	$(hide) echo $(DATETIME) > $@

ALL_DEFAULT_INSTALLED_MODULES += $(BUILDINFO_TARGET)
