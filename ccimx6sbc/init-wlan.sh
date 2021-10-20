#!/system/bin/sh
#===============================================================================
#
#  init-wlan.sh
#
#  Copyright (C) 2021 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Load wireless driver
#
#===============================================================================

set -e

log -p i -t ${0} "[Digi] start Wi-Fi script"

# Variables.
ATH6K_DEVICE_ID="0x0301"
QCA_DEVICE_ID="0x050A"
ATH6K_DEVICE_ID_NUMBER="$(printf %d ${ATH6K_DEVICE_ID})"
QCA_DEVICE_ID_NUMBER="$(printf %d ${QCA_DEVICE_ID})"
NUM_SDIO_IFACES=4
IFACE_NUM=0
QCA_ARGS="asyncintdelay=0x2 writecccr1=0xf2 writecccr1value=0xf writecccr2=0xf1 writecccr2value=0xa8 writecccr3=0xf0 writecccr3value=0xa1 writecccr4=0x15 writecccr4value=0x30 enable_p2p=1"

# Read the Wi-Fi device ID. Iterate through the SDIO interfaces.
while [ "${IFACE_NUM}" -lt "${NUM_SDIO_IFACES}" ]; do
	IFACE_ENTRY="/sys/bus/sdio/devices/mmc${IFACE_NUM}:0001:1/device"
	IFACE_NUM=$(( IFACE_NUM + 1 ))
	if [ ! -f "${IFACE_ENTRY}" ]; then
		# If the interface does not exist continue with next one.
		continue
	fi
	DEVICE_ID="$(cat ${IFACE_ENTRY})"
	DEVICE_ID_NUMBER="$(printf %d ${DEVICE_ID})"
	# Check if the device ID matches with any Wi-Fi device ID.
	if [ ${DEVICE_ID_NUMBER} -eq ${ATH6K_DEVICE_ID_NUMBER} ]; then
		log -p i -t ${0} "[Digi] Found Atheros device ${ATH6K_DEVICE_ID_NUMBER}"
		exec /system/bin/modprobe -a -d /vendor/lib/modules ath6kl_core ath6kl_sdio
	elif [ ${DEVICE_ID_NUMBER} -eq ${QCA_DEVICE_ID_NUMBER} ]; then
		log -p i -t ${0} "[Digi] Found Qualcomm device ${QCA_DEVICE_ID_NUMBER}"
		exec /system/bin/modprobe -a -d /vendor/lib/modules qca6564_wlan ${QCA_ARGS}
	fi
done

log -p w -t ${0} "[Digi][WARN] No Wi-Fi device found in SDIO bus"
exit 1
