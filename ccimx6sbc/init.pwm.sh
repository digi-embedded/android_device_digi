#!/system/bin/busybox sh
#===============================================================================
#
#  init.pwm.sh
#
#  Copyright (C) 2011 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Configures PWM permissions to be used by PWM API
#
#===============================================================================

PWM_FOLDER="/sys/class/leds/"

PWM_PREFIX="pwm"

DUTY_FILE="brightness"

# Sanity check
if [ ! -d ${PWM_FOLDER} ]; then
	busybox echo "[ERROR] ${PWM_FOLDER} does not exist"
	exit 1
fi

# Look for all PWM channel directories.
for dir in ${PWM_FOLDER}${PWM_PREFIX}*/
do
	# Check the duty file.
	if [ -f "$dir"${DUTY_FILE} ]; then
		chmod ug+w "$dir"${DUTY_FILE}
		chown system:system "$dir"${DUTY_FILE}
	fi
done

