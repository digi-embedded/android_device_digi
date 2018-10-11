#!/system/bin/busybox sh
#===============================================================================
#
#  init.bt.sh
#
#  Copyright (C) 2014 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Configure Bluetooth
#
#===============================================================================

# set -e

log -p i -t ${0}  "[Digi] start BT script"

#
# if this hardware does not support Bluetooth
#
if [ -d "/proc/device-tree/bluetooth" ]; then

	# Get MAC address from device tree. Use a default value if it has not been set.
	if [ -f "/proc/device-tree/bluetooth/mac-address" ]; then
		BTADDR="$(busybox hexdump -ve '1/1 "%02X" ":"' /proc/device-tree/bluetooth/mac-address | busybox sed 's/:$//g')"
	fi
	if [ -z "${BTADDR}" -o "${BTADDR}" = "00:00:00:00:00:00" ]; then
		BTADDR="00:04:F3:FF:FF:BB"
	fi
	log -p i -t ${0} "[Digi] BT MAC = ${BTADDR}"

	# Update the MAC address file only if it has changed.
	FW_MAC="/system/etc/firmware/ar3k/1020200/ar3kbdaddr.pst"
	[ -f "${FW_MAC}" ] && [ "$(cat ${FW_MAC})" = "${BTADDR}" ] || FW_DIR_UPDATE="1"

	JPN_REGCODE="0x2"
	REGCODE="$(cat /proc/device-tree/digi,hwid,cert)"
	BT_CLASS_LINK="/system/etc/firmware/ar3k/1020200/PS_ASIC.pst"
	BT_CLASS_FILE="/system/etc/firmware/ar3k/1020200/PS_ASIC_class_1.pst"
	if [ -n "${REGCODE}" ] && [ "${JPN_REGCODE}" = "${REGCODE}" ]; then
		BT_CLASS_FILE="/system/etc/firmware/ar3k/1020200/PS_ASIC_class_2.pst"
	fi

	# Replace the configuration file if different
	busybox cmp -s ${BT_CLASS_FILE} ${BT_CLASS_LINK} || FW_DIR_UPDATE="1"

	# Update the firmware directory only if any change is needed.
	if [ -n "${FW_DIR_UPDATE}" ]; then
		# Remount the /system partition read-write
		mount -o remount,rw /system

		# Update MAC address and firmware file symlink
		# -- Make sure to set read permission for all in the MAC file (otherwise
		# -- the mac address is not correctly configured)
		echo ${BTADDR} > ${FW_MAC}
		busybox chmod 644 ${FW_MAC}
		busybox ln -sf ${BT_CLASS_FILE} ${BT_CLASS_LINK}

		# Remove not used configuration file
		# -- Do not quote the subcommand to avoid leading/trailing whitespace
		# -- being part of the file name.
		rm -f $(echo /system/etc/firmware/ar3k/1020200/PS_ASIC_class_?.pst | busybox sed -e "s,${BT_CLASS_FILE},,g")

		# Set the /system partition back to read-only
		busybox sync
		mount -o remount,ro /system
	fi
fi
