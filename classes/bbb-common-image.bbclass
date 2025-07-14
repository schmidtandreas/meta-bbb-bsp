SUMMARY = "Reusable class representing the common part for BBB images"

LICENSE = "MIT"

inherit core-image
inherit image-buildinfo

IMAGE_INSTALL += " \
    bash \
"

# Enable this image / derived images to be referenced in wic images.
# ------------------------------------------------------------------
# Note: do_rootfs_wicenv creates the .env file containing meta information
# about the image, read by wic before processing .wks files.
addtask rootfs_wicenv after do_image before do_image_complete
