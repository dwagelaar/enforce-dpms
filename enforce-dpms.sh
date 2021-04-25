#!/bin/sh
set -ueo pipefail

DRM_DEVICE_PATH=/sys/class/graphics/fb0/device/drm/card0
ALL_DRM_PORTS=$(find ${DRM_DEVICE_PATH} | grep '/dpms$')
DEBUG=0

function read_dpms_state()
{
	POWER_SAVE_MODE=$(busctl --user get-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode || true)
}

function find_active_drm_port()
{
	for DRM_PORT in ${ALL_DRM_PORTS}; do
		DRM_PORT_STATE=$(cat ${DRM_PORT})
		if [ "$DEBUG" == "1" ]
		then
			echo "${DRM_PORT}=${DRM_PORT_STATE}"
		fi
		if [ "$DRM_PORT_STATE" == "On" ]
		then
			return 0
		fi
	done
	return 1
}

echo "Started monitoring DPMS sleep mode"
while (true)
do

	DPMS_HAS_BEEN_AWAKE=0
	while (true)
	do
		read_dpms_state
		if [ "$POWER_SAVE_MODE" == "i 3" ]
		then
			if [ $DPMS_HAS_BEEN_AWAKE -eq 1 ]
			then
				echo "DPMS sleep mode activation detected"
				break
			elif ( find_active_drm_port )
			then
				echo "DPMS sleep mode active, but found DRM interfaces that are still switched on"
				break
			fi
		elif [ "$POWER_SAVE_MODE" == "i 0" ]
		then
			if [ $DPMS_HAS_BEEN_AWAKE -eq 0 ]
			then
				echo "DPMS sleep mode deactivated"
			fi
			DPMS_HAS_BEEN_AWAKE=1
		fi
		sleep 2
	done

	echo "Enforcing DPMS sleep mode"
	for counter in {1..150}
	do
		busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 3
		sleep 0.1
	done
	echo "Finished enforcing DPMS sleep mode"

done
