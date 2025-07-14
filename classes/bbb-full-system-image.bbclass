SUMMARY = "Reusable class to create a full system image for BBB"

LICENSE = "MIT"

inherit image

MAINTENANCE_MODE_IMAGE_NAME ??= "bbb-maintenance-mode-image"
NORMAL_MODE_IMAGE_NAME ??= "bbb-normal-mode-image"

WKS_FILE = "bbb-multiboot.wks.in"
IMAGE_FSTYPES = "wic.bz2 wic.bmap"

# Define files for kernel boot partition
IMAGE_BOOT_FILES = "${KERNEL_IMAGETYPE} am335x-boneblack.dtb"

MAINTENANCE_BOOT_PART   ??= "2"
MAINTENANCE_ROOTFS_PART ??= "3"
NORMAL_BOOT_PART        ??= "6"
NORMAL_ROOTFS_PART      ??= "7"

DEPENDS += " \
    ${MAINTENANCE_MODE_IMAGE_NAME} \
    ${NORMAL_MODE_IMAGE_NAME} \
"
# Enforce the images of the respective modes complete before building the integrated image.
do_rootfs[depends] += " \
    ${MAINTENANCE_MODE_IMAGE_NAME}:do_image_complete \
    ${NORMAL_MODE_IMAGE_NAME}:do_image_complete \
"

# Make sure to clean partial images when cleaning the full image.
do_clean[depends] += " \
    ${MAINTENANCE_MODE_IMAGE_NAME}:do_clean \
    ${NORMAL_MODE_IMAGE_NAME}:do_clean \
"
do_prepare_bootloader_rootfs() {
    install -d ${DEPLOY_DIR_IMAGE}/bootloader_rootfs
    install -m 0644 ${DEPLOY_DIR_IMAGE}/MLO ${DEPLOY_DIR_IMAGE}/bootloader_rootfs/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/u-boot.${UBOOT_SUFFIX} ${DEPLOY_DIR_IMAGE}/bootloader_rootfs/
}
do_prepare_bootloader_rootfs[vardepsexclude] += "DATETIME"
do_prepare_bootloader_rootfs[nostamp] = "1"
do_prepare_bootloader_rootfs[dirs] = "${DEPLOY_DIR_IMAGE}/bootloader_rootfs"
do_prepare_bootloader_rootfs[cleandirs] = "${DEPLOY_DIR_IMAGE}/bootloader_rootfs"
do_prepare_bootloader_rootfs[depends] += " \
    u-boot:do_deploy \
"

addtask do_prepare_bootloader_rootfs before do_image_wic

do_deploy_wic_artifacts() {
    wic_workdir="${WORKDIR}/build-wic"
    image_link_base="${PN}-${MACHINE}"
    image_base="${image_link_base}-${DATETIME}"

    bbnote "Copying partitions from '${wic_workdir}' to '${IMGDEPLOYDIR}' ..."
    
    ext="wic.maintenance.boot.vfat"
    cp -v "${wic_workdir}"/*.direct.p"${MAINTENANCE_BOOT_PART}" "${IMGDEPLOYDIR}"/"${image_base}.${ext}"
    ln -svf "${image_base}.${ext}" "${IMGDEPLOYDIR}"/"${image_link_base}.${ext}"

    ext="wic.maintenance.rootfs.img"
    cp -v "${wic_workdir}"/*.direct.p"${MAINTENANCE_ROOTFS_PART}" "${IMGDEPLOYDIR}"/"${image_base}.${ext}"
    ln -svf "${image_base}.${ext}" "${IMGDEPLOYDIR}"/"${image_link_base}.${ext}"

    ext="wic.normal.boot.vfat"
    cp -v "${wic_workdir}"/*.direct.p"${NORMAL_BOOT_PART}" "${IMGDEPLOYDIR}"/"${image_base}.${ext}"
    ln -svf "${image_base}.${ext}" "${IMGDEPLOYDIR}"/"${image_link_base}.${ext}"

    ext="wic.normal.rootfs.ext4"
    cp -v "${wic_workdir}"/*.direct.p"${NORMAL_ROOTFS_PART}" "${IMGDEPLOYDIR}"/"${image_base}.${ext}"
    ln -svf "${image_base}.${ext}" "${IMGDEPLOYDIR}"/"${image_link_base}.${ext}"
}
do_deploy_wic_artifacts[vardepsexclude] += "DATETIME"
do_deploy_wic_artifacts[nostamp] = "1"
do_deploy_wic_artifacts[dirs] = "${IMGDEPLOYDIR}"

addtask deploy_wic_artifacts after do_image_wic before do_image_complete
