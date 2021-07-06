#!/bin/sh
#===============================================================================
#
#  Copyright (C) 2021 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  Description:
#    Script to flash Digi Embedded for Android build artifacts over USB.
#===============================================================================
# set -x

SCRIPTNAME="$(basename "${0}")"

RED='\033[0;31m'
GREEN='\033[0;32m'
STD='\033[0;0m'
CCIMX8MMDVK="ccimx8mmdvk"
CCIMX8XSBCPRO="ccimx8xsbcpro"
FIRST_DEPLOY=0
WIPE_PARTITIONS=0
WAIT=10

UUU_LST_HEADER="\
uuu_version 1.3.124
FB: ucmd setenv fastboot_dev mmc
FB: ucmd setenv mmcdev 0
FB: ucmd mmc dev 0
FB: ucmd mmc dev 0 0
"

UUU_LST_BOOTLOADER="\
FB: ucmd env set bootcmd \"env default -a; env save; env save; reset\"
FB: ucmd env save
FB: ucmd mmc partconf 0 1 1 1
FB[-t 600000]: flash gpt %s
FB: ucmd setenv fastboot_dev sata
FB: ucmd setenv fastboot_dev mmc
"

UUU_LST_UNLOCK="\
FB: ucmd env set skip-fblock-check yes
"

UUU_LST_FLASH="\
FB[-t 600000]: flash dtbo_a %s
FB[-t 600000]: flash dtbo_b %s
FB[-t 600000]: flash boot_a %s
FB[-t 600000]: flash boot_b %s
FB[-t 600000]: flash vendor_boot_a %s
FB[-t 600000]: flash vendor_boot_b %s
FB[-t 600000]: flash vbmeta_a %s
FB[-t 600000]: flash vbmeta_b %s
FB[-t 600000]: flash super %s
"

UUU_LST_WIPE="\
FB[-t 600000]: erase userdata
FB[-t 600000]: erase misc
FB[-t 600000]: erase presistdata
FB[-t 600000]: erase metadata
FB[-t 600000]: erase fbmisc
"

UUU_LST_RESET="\
FB[-t 600000]: acmd reset
"

UUU_LST_FOOTER="\
FB: done
"

show_error()
{
	echo "${RED}[ERROR] ${1}${STD}"
}

show_usage()
{
cat << EOF

Usage: ${SCRIPTNAME} MODE <options>

MODE
  help                      Displays this help message.
  first-deploy              Completely erases and programs images including
                            the bootloader from the USB.
  development               Programs Android images.

'first-deploy' options:
  -u <uboot_filename>       U-Boot file name located at images directory.
  -p <part_table_filename>  Partition table file name located at images
                            directory.
                            'partition-table.img' if not specified.
  -d <images_dir>           Directory where images are located.
                            Current directory if not specify.
  -n                        No wait. Skips 10 seconds delay to stop script.

'development' options:
  -d <images_dir>           Directory where images are located.
                            Current directory if not specify.
  -wipe                     Wipe data partitions.

EOF
}

show_banner()
{
cat << EOF

####################################################################
#    Digi Embedded for Android firmware install through USB OTG    #
####################################################################

EOF
}

show_info()
{
cat << EOF
 ====================
 =    IMPORTANT!    =
 ====================
 This process will erase your eMMC and will install the following files
 on the partitions of the eMMC.

   PARTITION        FILENAME
   -------------    -------------
EOF

	if [ "${FIRST_DEPLOY}" -eq 1 ]; then
cat << EOF
   bootloader       ${IMG_UBOOT_FILENAME}
   gpt              ${IMG_PART_TABLE_FILENAME}
EOF
	fi

cat << EOF
   dtbo_a           ${IMG_DTBO_FILENAME}
   boot_a           ${IMG_BOOT_FILENAME}
   vendor_boot_a    ${IMG_VENDOR_BOOT_FILENAME}
   vbmeta_a         ${IMG_VBMETA_FILENAME}
   dtbo_b           ${IMG_DTBO_FILENAME}
   boot_b           ${IMG_BOOT_FILENAME}
   vendor_boot_b    ${IMG_VENDOR_BOOT_FILENAME}
   vbmeta_b         ${IMG_VBMETA_FILENAME}
   super            ${IMG_SUPER_FILENAME}

EOF

	[ ${WAIT} -gt 0 ] && echo " Press CTRL+C now if you wish to abort."

	for i in $(seq ${WAIT} -1 1); do
		printf "\r Update process starts in %d " "${i}"
		sleep 1
	done
	printf "\r                                   \n"
	echo " Starting update process"
	echo ""
}

show_final_msg()
{
	echo "${GREEN} ========================================================="
	if [ "${FIRST_DEPLOY}" -eq 1 ]; then
		echo "  Done! Restore board switches and reset the device."
	else
		echo "  Done! Wait for the target to complete the boot process."
	fi
	echo " =========================================================${STD}"
}

# not_supported_option <option>
not_supported_option()
{
	show_error "Option \"${1}\" not supported."
	show_usage && exit 1
}

# Parse uuu cmd output
getenv()
{
	uuu -v fb: ucmd printenv "${1}" | sed -ne "s,^${1}=,,g;T;p"
}


# check_images <dir_path>
check_images()
{
	get_platform_from_target

	# Determine partition_table, dtbo, boot, vendor_boot, vbmeta, and super image filenames
	[ -z "${IMG_PART_TABLE_FILENAME}" ] && IMG_PART_TABLE_FILENAME="partition-table.img"
	IMG_BOOT_FILENAME="boot.img"
	IMG_VENDOR_BOOT_FILENAME="vendor_boot.img"
	IMG_SUPER_FILENAME="super.img"

	[ ! -f "${1}${IMG_DTBO_FILENAME}" ] && IMG_DTBO_FILENAME="dtbo.img"
	[ ! -f "${1}${IMG_VBMETA_FILENAME}" ] && IMG_VBMETA_FILENAME="vbmeta.img"

	# Check existance of files before starting the update
	IMGS="${IMG_UBOOT_FILENAME} ${IMG_PART_TABLE_FILENAME} ${IMG_DTBO_FILENAME} ${IMG_BOOT_FILENAME} ${IMG_VENDOR_BOOT_FILENAME} ${IMG_VBMETA_FILENAME} ${IMG_SUPER_FILENAME}"
	for f in ${IMGS}; do
		if [ ! -f "${1}${f}" ]; then
			show_error "Could not find file '${f}'."
			ABORT=true
		fi
	done

	[ "${ABORT}" = true ] && exit 1
}

# get_platform_from_target
get_platform_from_target()
{
	if [ "${FIRST_DEPLOY}" -eq 1 ]; then
		printf " Looking for a supported platform... "
		if uuu -lsusb | grep -qs 'MX8QXP'; then
			uuu "${IMAGES_DIR}${IMG_UBOOT_FILENAME}" >/dev/null
			SOC_TYPE="imx8qxp"
			printf "%s\n\n" "${CCIMX8XSBCPRO}"
		elif uuu -lsusb | grep -qs 'MX8MM'; then
			uuu -b spl "${IMAGES_DIR}${IMG_UBOOT_FILENAME}" >/dev/null
			SOC_TYPE="imx8mm"
			printf "%s\n\n" "${CCIMX8MMDVK}"
		else
			show_error "Unable to find a supported platform. Ensure switches are properly configured and reset the device."
			exit 1
		fi
	fi

	if [ -z "${SOC_TYPE}" ]; then
		# Enable the redirect support to get u-boot variables values
		uuu fb: ucmd setenv stdout serial,fastboot >/dev/null

		SOC_TYPE=$(getenv "soc_type")

		# Remove redirect
		uuu fb: ucmd setenv stdout serial >/dev/null
	fi

	[ -z "${SOC_TYPE}" ] && show_error "Cannot determine the platform!" && exit 1

	case "${SOC_TYPE}" in
		imx8mm|imx8qxp)
			IMG_DTBO_FILENAME="dtbo-${SOC_TYPE}.img"
			IMG_VBMETA_FILENAME="vbmeta-${SOC_TYPE}.img";;
		*)
			show_error "Not supported platform (soc_type=${SOC_TYPE})"
			exit 1;;
	esac
}

# shellcheck disable=SC2059 # printf format included in variables
generate_uuu_lst()
{
	UUU_LST_FILE=$(mktemp --suffix=.lst --tmpdir="${IMAGES_DIR}")

	printf "${UUU_LST_HEADER}" > "${UUU_LST_FILE}"

	if [ ${FIRST_DEPLOY} -eq 1 ]; then
		# Erase bootloader environment and flash partition table image
		printf "${UUU_LST_BOOTLOADER}" "${IMG_PART_TABLE_FILENAME}" \
			>> "${UUU_LST_FILE}"
	else
		# Unlock the bootloader
		printf "${UUU_LST_UNLOCK}" >> "${UUU_LST_FILE}"
	fi

	# Flash rest of partitions
	printf "${UUU_LST_FLASH}" \
		"${IMG_DTBO_FILENAME}" "${IMG_DTBO_FILENAME}" \
		"${IMG_BOOT_FILENAME}" "${IMG_BOOT_FILENAME}" \
		"${IMG_VENDOR_BOOT_FILENAME}" "${IMG_VENDOR_BOOT_FILENAME}" \
		"${IMG_VBMETA_FILENAME}" "${IMG_VBMETA_FILENAME}" \
		"${IMG_SUPER_FILENAME}" \
		>> "${UUU_LST_FILE}"

	# Wipe partitions
	if [ "${WIPE_PARTITIONS}" -eq 1 ]; then
		printf "${UUU_LST_WIPE}" >> "${UUU_LST_FILE}"
	fi

	if [ "${FIRST_DEPLOY}" -eq 0 ]; then
		printf "${UUU_LST_RESET}" >> "${UUU_LST_FILE}"
	fi

	printf "${UUU_LST_FOOTER}" >> "${UUU_LST_FILE}"
}

get_options()
{
	shift  # Shift mode
	while [ ${#} -gt 0 ]; do
		case "${1}" in
			-d)
				IMAGES_DIR=${2}; shift;;
			-u)
				[ "${FIRST_DEPLOY}" -eq 0 ] && not_supported_option "${1}"
				IMG_UBOOT_FILENAME=${2}; shift;;
			-p)
				[ "${FIRST_DEPLOY}" -eq 0 ] && not_supported_option "${1}"
				IMG_PART_TABLE_FILENAME=${2}; shift;;
			-wipe)
				[ "${FIRST_DEPLOY}" -eq 1 ] && not_supported_option "${1}"
				WIPE_PARTITIONS=1;;
			-n)
				[ "${FIRST_DEPLOY}" -eq 0 ] && not_supported_option "${1}"
				WAIT=0;;
			*)
				not_supported_option "${1}";;
		esac
		shift
	done

	if [ "${FIRST_DEPLOY}" -eq 1 ] && [ -z "${IMG_UBOOT_FILENAME}" ]; then
		show_error "U-Boot file name required."
		show_usage && exit 1
	fi

	if [ -n "${IMAGES_DIR}" ]; then
		if ! DIR="$(cd "${IMAGES_DIR}" 2>/dev/null && pwd)"; then
			show_error "Path '${IMAGES_DIR}' not found"
			exit 1
		fi
		IMAGES_DIR="${DIR}/"
	else
		IMAGES_DIR="$(pwd)/"
	fi
}

clean_up()
{
	trap - INT TERM QUIT EXIT
	rm -f "${UUU_LST_FILE}"
}
trap 'clean_up; exit 1' INT TERM QUIT EXIT

MODE="$(echo "${1}" | tr '[:upper:]' '[:lower:]')"

# Sanity check
[ -z "${MODE}" ] && MODE="help"

# Get mode
case "${MODE}" in
	help)
		show_usage; exit;;
	development)
		WAIT=0;;
	first-deploy)
		FIRST_DEPLOY=1
		WIPE_PARTITIONS=1;;
	*)
		show_error "\"${1}\" not supported."
		show_usage && exit 1;;
esac

get_options "${@}"

show_banner

check_images "${IMAGES_DIR}"

show_info

generate_uuu_lst

[ "${FIRST_DEPLOY}" -eq 1 ] && uuu -b emmc "${IMAGES_DIR}${IMG_UBOOT_FILENAME}"

uuu "${UUU_LST_FILE}" && show_final_msg

