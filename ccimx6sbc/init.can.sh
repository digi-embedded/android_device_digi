#!/system/bin/busybox sh
#===============================================================================
#
#  init.can.sh
#
#  Copyright (C) 2014 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: ConnectCore Wi-i.MX6 CAN script
#
#===============================================================================

SCRIPTNAME="$(busybox basename ${0})"

log -p e -t "${SCRIPTNAME}" "Digi: start CAN scripts " "${1}" "${2}" "boot" "$(getprop "sys.boot_completed")"

{
	local CAN0_BITRATE="${1}"
	local CAN1_BITRATE="${2}"

	if [ -z "$(getprop "sys.boot_completed")" ]; then
	    sleep 5
	    if [ -n "$(getprop "persist.CAN0_BITRATE")" ]; then
		CAN0_BITRATE="$(getprop "persist.CAN0_BITRATE")"
		setprop "ro.CAN0_ENABLED" "1"
		# First set bitrate and the enable interface. Otherwise, bitrate can't be set.
		ip link set can0 up type can bitrate ${CAN0_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Enabling CAN0 interface with property ${CAN0_BITRATE} bps."
	    else
		setprop "persist.CAN0_BITRATE" "${CAN0_BITRATE}"
		setprop "ro.CAN0_ENABLED" "1"
		# First set bitrate and the enable interface. Otherwise, bitrate can't be set.
		ip link set can0 up type can bitrate ${CAN0_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Enabling CAN0 interface at ${CAN0_BITRATE} bps."
	    fi

	    if [ -n "$(getprop "persist.CAN1_BITRATE")" ]; then
		CAN1_BITRATE="$(getprop "persist.CAN1_BITRATE")"
		setprop "ro.CAN1_ENABLED" "1"
		# First set bitrate and the enable interface. Otherwise, bitrate can't be set.
		ip link set can1 up type can bitrate ${CAN1_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Enabling CAN1 interface with property ${CAN1_BITRATE} bps."
	    else
		setprop "persist.CAN1_BITRATE" "${CAN1_BITRATE}"
		setprop "ro.CAN1_ENABLED" "1"

		ip link set can1 up type can bitrate ${CAN1_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Enabling CAN1 interface at ${CAN1_BITRATE} bps."
	    fi
	else
	    if [ "${CAN0_BITRATE}" != "0" ]; then
		setprop "persist.CAN0_BITRATE" "${CAN0_BITRATE}"
		ip link set can0 down
		sleep 1
		# First set bitrate and the enable interface. Otherwise, bitrate can't be set.
		ip link set can0 up type can bitrate ${CAN0_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Change CAN0 interface to ${CAN0_BITRATE} bps."
	    fi

	    if [ "${CAN1_BITRATE}" != "0" ]; then
		setprop "persist.CAN1_BITRATE" "${CAN1_BITRATE}"
		ip link set can1 down
		sleep 1
		# First set bitrate and the enable interface. Otherwise, bitrate can't be set.
		ip link set can1 up type can bitrate ${CAN1_BITRATE}
		log -p i -t "${SCRIPTNAME}" "Change CAN1 interface to ${CAN1_BITRATE} bps."
	    fi
	fi
}
