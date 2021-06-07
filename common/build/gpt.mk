ifdef ADDITION_BPT_PARTITION

INSTALLED_ADDITIONAL_BPTIMAGE_TARGET := $(foreach part,$(ADDITION_BPT_PARTITION),$(PRODUCT_OUT)/$(firstword $(subst :, ,$(part))).img)
INSTALLED_ADDITIONAL_BPTIMAGE_TARGET_F := $(firstword $(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET))

define build-additional-bptimage-target
  $(call pretty,"Additional target partition table images: $(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET)")
  for addition_partition in $(ADDITION_BPT_PARTITION); do \
    PARTITION_OUT_IMAGE=`echo $$addition_partition | cut -d":" -f1`; \
    PARTITION_INPUT_BPT=`echo $$addition_partition | cut -d":" -f2`; \
    $(BPTTOOL) make_table --output_gpt $(PRODUCT_OUT)/$$PARTITION_OUT_IMAGE.img \
      --output_json $(PRODUCT_OUT)/$$PARTITION_OUT_IMAGE.bpt --input $$PARTITION_INPUT_BPT \
      $(BOARD_BPT_MAKE_TABLE_ARGS); \
   done
endef

$(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET_F): | $(BPTTOOL)
	$(build-additional-bptimage-target)

bptimage: $(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET_F)

droidcore: $(INSTALLED_ADDITIONAL_BPTIMAGE_TARGET_F)

endif # ADDITION_BPT_PARTITION
