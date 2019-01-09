ifeq ($(strip $(TARGET_DEA_BUILDINFO)),true)

REPO_MANIFEST_TARGET := $(TARGET_OUT_VENDOR_ETC)/repo-manifest.xml

.PHONY: repomanifest
repomanifest: $(REPO_MANIFEST_TARGET)

$(REPO_MANIFEST_TARGET):
	$(hide) mkdir -p $(dir $@)
	$(hide) repo manifest -r --suppress-upstream-revision -o $@

ALL_DEFAULT_INSTALLED_MODULES += $(REPO_MANIFEST_TARGET)

endif
