#!/bin/bash
set -e

HSS_PAYLOAD_GENERATOR="${HOST_DIR}"/bin/hss-payload-generator
MKIMAGE="${HOST_DIR}"/bin/mkimage
BOARD_DIR="$(pwd)"/"${0%/*}"

pushd "${BINARIES_DIR}"

# Compile BeagleV-Fire LED Overlay
DTC="${HOST_DIR}/bin/dtc"
KERNEL_DIR="${BUILD_DIR}/linux-custom"

"${HOST_DIR}/bin/riscv64-buildroot-linux-gnu-cpp" -E -nostdinc \
	-I"${KERNEL_DIR}/include" \
	-x assembler-with-cpp -undef \
	-o mpfs_beaglev_fire_led.pre.dtso \
	"${BOARD_DIR}/mpfs_beaglev_fire_led.dtso"

"${DTC}" -@ -Wno-unit_address_vs_reg -I dts -O dtb \
	-o mpfs_beaglev_fire_led.dtbo \
	mpfs_beaglev_fire_led.pre.dtso

"${HSS_PAYLOAD_GENERATOR}" -c "${BOARD_DIR}"/config.yaml payload.bin
cp "${BOARD_DIR}"/beaglev_fire.its "${BINARIES_DIR}"/beaglev_fire.its
gzip -9 Image -c > Image.gz
"${MKIMAGE}" -f beaglev_fire.its beaglev_fire.itb
popd
support/scripts/genimage.sh -c "${BOARD_DIR}"/genimage.cfg
