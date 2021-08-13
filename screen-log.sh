#!/bin/bash
set -ueo pipefail

LOGFILE=${HOME}/screen-log-$(date +%Y%m%d-%H%M%S).csv
DRM_DEVICE_PATH=/sys/class/graphics/fb0/device/drm/card0
DRM_DEVICE_PORT=card0-HDMI-A-1
echo "Writing to ${LOGFILE}" > /dev/stderr

echo 'Timestamp;PowerSaveMode;card0-HDMI-A-1/dpms' | tee ${LOGFILE}

while ( true ); do
	echo -n "$(date '+%Y-%m-%d %H:%M:%S.%N');" | tee -a ${LOGFILE}
	busctl --user get-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode | awk '{ORS=";"; print $0}' | tee -a ${LOGFILE}
	cat ${DRM_DEVICE_PATH}/${DRM_DEVICE_PORT}/dpms | tee -a ${LOGFILE}
	sleep 0.5
done
