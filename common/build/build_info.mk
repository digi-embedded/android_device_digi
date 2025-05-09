DEA_BUILD_ID := dea-14.0-r2.1

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.build.dea.id=$(DEA_BUILD_ID)

# -------@release build info-------
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build_id=$(DEA_BUILD_ID)
