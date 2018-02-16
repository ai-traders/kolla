#!/bin/dash
###
# ABOUT  : collectd monitoring script for smartmontools (using smartctl)
# AUTHOR : Samuel B. <samuel_._behan_(at)_dob_._sk> (c) 2012
# LICENSE: GNU GPL v3
# SOURCE: http://devel.dob.sk/collectd-scripts/
#
# This script monitors SMART pre-fail attributes of disk drives using smartmon tools.
# Generates output suitable for Exec plugin of collectd.
###
# Requirements:
#   * smartmontools installed (and smartctl binary)
#   * User & group for collector:collector
#       groupadd collector
#       useradd -d /var/lib/collector -g collector -l -m -s /bin/sh collector
#   * sudo entry for binary (ie. for sys account):
#       collector ALL=(root) NOPASSWD:/usr/sbin/smartctl *
#   * Configuration for collectd.conf
#       LoadPlugin exec
#       <Plugin exec>
#         Exec "collector:collector" "/usr/local/bin/collectd-smartmon" "ata-KINGSTON_SV300S37A60G_50026B774106FF4D"
#       </Plugin>
###
# Parameters:
#   <disk>[:<driver>,<id> ] ...
###
# Typical usage:
#   /etc/collect/smartmon.sh "ata-KINGSTON_SV300S37A60G_50026B774106FF4D"
#
###
# Typical output:
#   PUTVAL <host>/smartmon-ata-KINGSTON_SV300S37A60G_50026B774106FF4D/gauge-raw_read_error_rate interval=300 N:30320489
#   PUTVAL <host>/smartmon-ata-KINGSTON_SV300S37A60G_50026B774106FF4D/gauge-spin_up_time interval=300 N:0
#   PUTVAL <host>/smartmon-ata-KINGSTON_SV300S37A60G_50026B774106FF4D/gauge-reallocated_sector_count interval=300 N:472
#   ...
#
# Monitoring additional attributes:
#   If it is needed to monitor additional SMART attributes provided by smartctl, you
#   can do it simply by echoing SMART_<Attribute-Name> environment variable as its output
#   by smartctl -A. It's nothing complicated ;)
#
# History:
#   2012-04-17 v0.1.0  - public release
#   2012-09-03 v0.1.1  - fixed dash replacement (thx to R.Buehl)
#   2013-08-28 v0.2.0  - Fix sudo command.
#                        Use dash as it's lower overhead.
#                        Improve docs.
#                        Add a few metrics to output.
#                        Re-order & standardise output lines for easier review & updating.
#   2014-12-09 v0.2.1  - Fix basename calls.
###

if [ -z "$*" ]; then
	echo "Usage: $(basename $0) <disk> <disk>..." >&2
	exit 1
fi

for disk in "$@"; do
	disk=${disk%:*}
	if ! [ -e "/dev/disk/by-id/$disk" ]; then
		echo "$(basename $0): disk /dev/disk/by-id/$disk not found !" >&2
		exit 1
	fi
done

HOST=`hostname -f`
INTERVAL=300
while true; do
	for disk in "$@"; do
		dsk=${disk%:*}
		drv=${disk#*:}
		id=

		if [ "$disk" != "$drv" ]; then
			drv="-d $drv"
			id=${drv#*,}
		else
			drv=
		fi

		eval `sudo /usr/sbin/smartctl $drv -A "/dev/disk/by-id/$dsk" | awk '$3 ~ /^0x/ && $2 ~ /^[a-zA-Z0-9_-]+$/ { gsub(/-/, "_"); print "SMART_" $2 "=" $10 }' 2>/dev/null`

		[ -n "$SMART_Command_Timeout" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-command_timeout interval=$INTERVAL N:${SMART_Command_Timeout:-U}"
		[ -n "$SMART_Power_On_Hours" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-power_on_hours interval=$INTERVAL N:${SMART_Power_On_Hours:-U}"
		[ -n "$SMART_Current_Pending_Sector" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-current_pending_sector interval=$INTERVAL N:${SMART_Current_Pending_Sector:-U}"
		[ -n "$SMART_End_to_End_Error" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-end_to_end_error interval=$INTERVAL N:${SMART_End_to_End_Error:-U}"
		[ -n "$SMART_Hardware_ECC_Recovered" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-hardware_ecc_recovered interval=$INTERVAL N:${SMART_Hardware_ECC_Recovered:-U}"
		[ -n "$SMART_Offline_Uncorrectable" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-offline_uncorrectable interval=$INTERVAL N:${SMART_Offline_Uncorrectable:-U}"
		[ -n "$SMART_Raw_Read_Error_Rate" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-raw_read_error_rate interval=$INTERVAL N:${SMART_Raw_Read_Error_Rate:-U}"
		[ -n "$SMART_Reallocated_Sector_Ct" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-reallocated_sector_count interval=$INTERVAL N:${SMART_Reallocated_Sector_Ct:-U}"
		[ -n "$SMART_Reallocated_Event_Count" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-reallocated_event_count interval=$INTERVAL N:${SMART_Reallocated_Event_Count:-U}"
		[ -n "$SMART_Reported_Uncorrect" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-reported_uncorrect interval=$INTERVAL N:${SMART_Reported_Uncorrect:-U}"
		[ -n "$SMART_Spin_Up_Time" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/gauge-spin_up_time interval=$INTERVAL N:${SMART_Spin_Up_Time:-U}"
		[ -n "$SMART_Airflow_Temperature_Cel" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/temperature-airflow interval=$INTERVAL N:${SMART_Airflow_Temperature_Cel:-U}"
		[ -n "$SMART_Temperature_Celsius" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/temperature-temperature interval=$INTERVAL N:${SMART_Temperature_Celsius:-U}"
		[ -n "$SMART_Media_Wearout_Indicator" ] &&
			echo "PUTVAL $HOST/smartmon-$dsk$id/guage-media_wearout_indicator interval=$INTERVAL N:${SMART_Media_Wearout_Indicator:-U}"
                [ -n "$SMART_Retired_Block_Count" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-retired_block_count interval=$INTERVAL N:${SMART_Retired_Block_Count:-U}"
		# Kingston SSDs
		[ -n "$SMART_Program_Fail_Count" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-program_fail_count interval=$INTERVAL N:${SMART_Program_Fail_Count:-U}"
		[ -n "$SMART_Erase_Fail_Count" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-erase_fail_count interval=$INTERVAL N:${SMART_Erase_Fail_Count:-U}"
		# Samsung SSDs
		[ -n "$SMART_Program_Fail_Cnt_Total" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-program_fail_count interval=$INTERVAL N:${SMART_Program_Fail_Cnt_Total:-U}"
                [ -n "$SMART_Erase_Fail_Count_Total" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-erase_fail_count interval=$INTERVAL N:${SMART_Erase_Fail_Count_Total:-U}"
		[ -n "$SMART_Runtime_Bad_Block" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-runtime_bad_block interval=$INTERVAL N:${SMART_Runtime_Bad_Block:-U}"
		[ -n "$SMART_Wear_Range_Delta" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-wear_range_delta interval=$INTERVAL N:${SMART_Wear_Range_Delta:-U}"
		[ -n "$SMART_Wear_Leveling_Count" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-wear_leveling_count interval=$INTERVAL N:${SMART_Wear_Leveling_Count:-U}"
		[ -n "$SMART_Life_Curve_Status" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-life_curve_status interval=$INTERVAL N:${SMART_Life_Curve_Status:-U}"
		[ -n "$SMART_SSD_Life_Left" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-ssd_life_left interval=$INTERVAL N:${SMART_SSD_Life_Left:-U}"
		[ -n "$SMART_Lifetime_Writes_GiB" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-lifetime_writes_gib interval=$INTERVAL N:${SMART_Lifetime_Writes_GiB:-U}"
		[ -n "$SMART_Lifetime_Reads_GiB" ] &&
                        echo "PUTVAL $HOST/smartmon-$dsk$id/guage-lifetime_reads_gib interval=$INTERVAL N:${SMART_Lifetime_Reads_GiB:-U}"
	done

	sleep $INTERVAL || true
done
