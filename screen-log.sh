#!/bin/bash
set -ueo pipefail

LOGFILE=${HOME}/screen-log-$(date +%Y%m%d-%H%M%S).csv
DRM_DEVICE_PATH=/sys/class/graphics/fb*/device/drm/card*
ALL_DRM_PORTS=$(find ${DRM_DEVICE_PATH} | grep '/dpms$')

function log_header()
{
	echo -n 'Timestamp;PowerSaveMode'
	for DRM_PORT in ${ALL_DRM_PORTS}; do
		echo -n "${DRM_PORT}" | sed -E 's/.*\/card[0-9]+\/(.*)\/dpms/;\1/g'
	done
	echo ""
}

function log_dpms_state()
{
	busctl --user get-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode | awk '{ORS=""; print $0}'
}

function log_drm_ports()
{
	for DRM_PORT in ${ALL_DRM_PORTS}; do
		cat ${DRM_PORT} | awk '{ORS=""; print ";" $0}'
	done
}

echo "Writing to ${LOGFILE}" > /dev/stderr
exec &> >(tee -i ${LOGFILE})

log_header
while ( true ); do
	echo -n "$(date '+%Y-%m-%d %H:%M:%S.%N');"
	log_dpms_state
	log_drm_ports
	echo ""
	sleep 0.5
done
