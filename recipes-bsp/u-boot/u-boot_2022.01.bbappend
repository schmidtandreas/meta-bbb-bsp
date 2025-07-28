FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://bbb-multiboot.env \
    file://0001-configs-add-bbb-multiboot-defconfig.patch \
"

UBOOT_MACHINE = "bbb_multiboot_defconfig"

DEPENDS += "xxd-native"

do_compile:prepend() {
    cp ${WORKDIR}/bbb-multiboot.env ${S}/
}
