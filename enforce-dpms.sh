#!/bin/sh
set -ueo pipefail

function read_dpms_state()
{
	POWER_SAVE_MODE=$(busctl --user get-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode)
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
			fi
		elif [ "$POWER_SAVE_MODE" == "i 0" ]
		then
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
