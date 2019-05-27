#!/bin/sh
#
# Copyright 2019, Digi International Inc.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, you can obtain one at http://mozilla.org/MPL/2.0/.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Description: make Android SDCARD image
#
#   Replicate approximately the EMMC partition table
#
#   => mmc part (512 bytes sectors)
#
#   Part    Start LBA       End LBA         Name
#     1     0x00001000      0x00010fff      "boot"
#     2     0x00011000      0x00020fff      "recovery"
#     3     0x00021000      0x00420fff      "system"
#     4     0x00421000      0x00820fff      "cache"
#     5     0x00821000      0x00858fff      "vendor"
#     6     0x00859000      0x00860fff      "datafooter"
#     7     0x00861000      0x00868fff      "safe"
#     8     0x00869000      0x008697ff      "frp"
#     9     0x00869800      0x008717ff      "metadata"
#    10     0x00871800      0x01d5bfde      "userdata"
#
# Known-issues:
#
#   * recovery does not work from the SD card, so the partition is not
#     populated.
#

# Partition sizes in MiB
BOOTLOADER_RESERVED="8"
BOOT_PARTITION_SIZE="32"
RECOVERY_PARTITION_SIZE="32"
SYSTEM_PARTITION_SIZE="2048"
CACHE_PARTITION_SIZE="2048"
VENDOR_PARTITION_SIZE="112"
DATAFOOTER_PARTITION_SIZE="16"
FRP_PARTITION_SIZE="1"
METADATA_PARTITION_SIZE="16"
USERDATA_PARTITION_SIZE="1024"

# Default U-Boot programming offset if not provided in BoardConfig
BOOTLOADER_OFFSET="${BOOTLOADER_OFFSET:=1}"

# ====================================
# NOTHING TO CUSTOMIZE BELOW THIS LINE
# ====================================
SCRIPTNAME="$(basename "${0}")"

# The extended partition contains SYSTEM, CACHE, VENDOR, DATAFOOTER, FRP, METADATA and some extra space for EBRs
EXTENDED_PARTITION_SIZE="$((SYSTEM_PARTITION_SIZE + CACHE_PARTITION_SIZE + VENDOR_PARTITION_SIZE + DATAFOOTER_PARTITION_SIZE + FRP_PARTITION_SIZE + METADATA_PARTITION_SIZE + 64))"

# Total size + 10% extra space
SDIMG_SIZE="$(((BOOTLOADER_RESERVED + BOOT_PARTITION_SIZE + RECOVERY_PARTITION_SIZE + EXTENDED_PARTITION_SIZE + USERDATA_PARTITION_SIZE) * 110 / 100))"

usage() {
	cat <<EOF
Usage: ${SCRIPTNAME} [OPTIONS] <sdcard-disk-device>

    -b <boot.img>      Boot filesystem image
    -s <system.img>    System filesystem image
    -u <u-boot.bin>    U-Boot binary
    -v <vendor.img>    Vendor filesystem image

EOF
}

#
# Check whether an image is sparse
#
# From: https://android.googlesource.com/platform/system/core/+/master/libsparse/sparse_format.h
#
#   Sparse magic: 0xed26ff3a
#   Sparse magic MD5SUM: 0d02a97f49fbaa4a5815e4cb78628f1b (printf '\x3a\xff\x26\xed' | md5sum)
#
is_sparse_image() {
	[ "$(dd if="${1}" bs=1 count=4 2>/dev/null | md5sum | cut -d' ' -f1)" = "0d02a97f49fbaa4a5815e4cb78628f1b" ]
}

## Exit cleanly on signal reception
trap_exit() {
	rm -f "${tmp_data}" "${tmp_cache}" "${tmp_system}" "${tmp_vendor}"
	exit 2
}
trap 'trap_exit' 1 2 3 15

while getopts "b:s:u:v:" c; do
	case "${c}" in
		b) bootimg="${OPTARG}";;
		s) systemimg="${OPTARG}";;
		u) ubootbin="${OPTARG}";;
		v) vendorimg="${OPTARG}";;
		*) usage; exit;;
	esac
done
shift $((OPTIND - 1))

SDIMG="${1}"

#
# Sanity checks
#
if [ -z "${bootimg}" ] || [ -z "${systemimg}" ] || [ -z "${ubootbin}" ] || [ -z "${vendorimg}" ] || [ -z "${SDIMG}" ]; then
	printf "\\n[ERROR]: Missing arguments.\\n\\n"
	usage
	exit 1
else
	for f in "${bootimg}" "${systemimg}" "${ubootbin}" "${vendorimg}"; do
		if [ ! -f "${f}" ]; then
			printf "\\n[ERROR]: %s not found.\\n\\n" "${f}"
			exit 1
		fi
	done
fi

# Initialize sdcard image file
dd if=/dev/zero of="${SDIMG}" bs=1M count=0 seek=${SDIMG_SIZE} 2>/dev/null

SFDISK_VER="$(sfdisk -v | cut -f4 -d ' ')"
SFDISK_MAJOR_VER="$(echo "${SFDISK_VER}" | cut -f1 -d '.')"
SFDISK_MINOR_VER="$(echo "${SFDISK_VER}" | cut -f2 -d '.')"

if [ "$((SFDISK_MAJOR_VER << 8 | SFDISK_MINOR_VER))" -ge "$((2 << 8 | 26))" ]; then
	# On newer implementations of sfdisk the syntax to pass the partition
	# size in MB has changed. That's why we check the tool version to apply
	# the correct setup.
	sfdisk -f -q "${SDIMG}" <<-EOF
	,$((BOOTLOADER_RESERVED + BOOT_PARTITION_SIZE))M,c
	,${RECOVERY_PARTITION_SIZE}M,c
	,${EXTENDED_PARTITION_SIZE}M,5
	,+,83
	,${SYSTEM_PARTITION_SIZE}M,83
	,${CACHE_PARTITION_SIZE}M,83
	,${VENDOR_PARTITION_SIZE}M,83
	,${DATAFOOTER_PARTITION_SIZE}M,83
	,${FRP_PARTITION_SIZE}M,83
	,${METADATA_PARTITION_SIZE}M,83
	EOF

	sfdisk -N1 -f -q "${SDIMG}" <<-EOF
	${BOOTLOADER_RESERVED}M,${BOOT_PARTITION_SIZE}M,c
	EOF
else
	sfdisk -uM -f -q "${SDIMG}" <<-EOF
	,$((BOOTLOADER_RESERVED + BOOT_PARTITION_SIZE)),c
	,${RECOVERY_PARTITION_SIZE},c
	,${EXTENDED_PARTITION_SIZE},5
	,+,83
	,${SYSTEM_PARTITION_SIZE},83
	,${CACHE_PARTITION_SIZE},83
	,${VENDOR_PARTITION_SIZE},83
	,${DATAFOOTER_PARTITION_SIZE},83
	,${FRP_PARTITION_SIZE},83
	,${METADATA_PARTITION_SIZE},83
	EOF

	sfdisk -N1 -uM -f -q "${SDIMG}" <<-EOF
	${BOOTLOADER_RESERVED},${BOOT_PARTITION_SIZE},c
	EOF
fi

#
# Prepare filesystem images
#
tmp_data="$(mktemp --tmpdir data.XXXXXX)"
dd if=/dev/zero of="${tmp_data}" bs=1M count=${USERDATA_PARTITION_SIZE} 2>/dev/null
mkfs.ext4 -q -F -Ldata "${tmp_data}"

tmp_cache="$(mktemp --tmpdir cache.XXXXXX)"
dd if=/dev/zero of="${tmp_cache}" bs=1M count=${CACHE_PARTITION_SIZE} 2>/dev/null
mkfs.ext4 -q -F -Lcache "${tmp_cache}"

tmp_boot="$(mktemp --tmpdir boot.XXXXXX)"
if is_sparse_image "${bootimg}"; then
	simg2img "${bootimg}" "${tmp_boot}"
else
	cp -af "${bootimg}" "${tmp_boot}"
fi

tmp_system="$(mktemp --tmpdir system.XXXXXX)"
if is_sparse_image "${systemimg}"; then
	simg2img "${systemimg}" "${tmp_system}"
else
	cp -af "${systemimg}" "${tmp_system}"
fi

tmp_vendor="$(mktemp --tmpdir vendor.XXXXXX)"
if is_sparse_image "${vendorimg}"; then
	simg2img "${vendorimg}" "${tmp_vendor}"
else
	cp -af "${systemimg}" "${tmp_vendor}"
fi

#
# Get partitions start sectors
#
# $ sfdisk -uS -l sdcard.img
#
# Disk sdcard.img: 5,8 GiB, 6229590016 bytes, 12167168 sectors
# Sector size (logical/physical): 512 bytes / 512 bytes
#
# Device              Start      End Sectors  Size Id Type
# sdcard.img1         16384    81919   65536   32M  c W95 FAT32 (LBA)   boot
# sdcard.img2         83968   149503   65536   32M  c W95 FAT32 (LBA)   recovery
# sdcard.img3        149504  8966143 8816640  4,2G  5 Extended
# sdcard.img4       8966144 12167167 3201024  1,5G 83 Linux             data
# sdcard.img5        151552  4345855 4194304    2G 83 Linux             system
# sdcard.img6       4347904  8542207 4194304    2G 83 Linux             cache
# sdcard.img7       8544256  8773631  229376  112M 83 Linux             vendor
# sdcard.img8       8775680  8808447   32768   16M 83 Linux             datafooter
# sdcard.img9       8810496  8812543    2048    1M 83 Linux             frp
# sdcard.img10      8814592  8847359   32768   16M 83 Linux             metadata
#
BOOT_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}1" '$1 == PART {print $2}')"
# RECOVERY_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}2" '$1 == PART {print $2}')"
DATA_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}4" '$1 == PART {print $2}')"
SYSTEM_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}5" '$1 == PART {print $2}')"
CACHE_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}6" '$1 == PART {print $2}')"
VENDOR_START_SECTOR="$(sfdisk -uS -l "${SDIMG}" 2>/dev/null | awk -v PART="${SDIMG}7" '$1 == PART {print $2}')"

#
# Flash images
#
dd if="${ubootbin}" of="${SDIMG}" bs=1K seek="${BOOTLOADER_OFFSET}" conv=notrunc,fsync 2>/dev/null
dd if="${tmp_boot}" of="${SDIMG}" bs=512 seek="${BOOT_START_SECTOR}" conv=notrunc,fsync 2>/dev/null
# dd if="${recoveryimg}" of="${SDIMG}" bs=512 seek="${RECOVERY_START_SECTOR}" conv=notrunc,fsync 2>/dev/null
dd if="${tmp_data}" of="${SDIMG}" bs=512 seek="${DATA_START_SECTOR}" conv=notrunc,fsync 2>/dev/null
dd if="${tmp_system}" of="${SDIMG}" bs=512 seek="${SYSTEM_START_SECTOR}" conv=notrunc,fsync 2>/dev/null
dd if="${tmp_cache}" of="${SDIMG}" bs=512 seek="${CACHE_START_SECTOR}" conv=notrunc,fsync 2>/dev/null
dd if="${tmp_vendor}" of="${SDIMG}" bs=512 seek="${VENDOR_START_SECTOR}" conv=notrunc,fsync 2>/dev/null

#
# Clean-up: remove temporary filesystem images
#
rm -f "${tmp_data}" "${tmp_cache}" "${tmp_boot}" "${tmp_system}" "${tmp_vendor}"
