# Check for target product
ifeq (cmremix_trlteusc,$(TARGET_PRODUCT))

# Inherit sabermod device configuration
include vendor/cmremix/products/sm_trlteusc.mk

# Set bootanimation Size
CMREMIX_BOOTANIMATION_NAME := 1440

# Include CM-Remix common configuration
include vendor/cmremix/config/cmremix_common.mk

# Inherit CM device configuration
$(call inherit-product, device/samsung/trlteusc/cm.mk)

PRODUCT_NAME := cmremix_trlteusc

endif
