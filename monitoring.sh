#!/bin/bash

set -e

# Command line arguments
T=$1
TP=$2
X=$3
Y=$4

# Log Files
MONITORING_DIR="/var/log/monitoring"
CPU_LOG_FILE="$MONITORING_DIR/cpu_log.csv"
ALERT_LOG_FILE="$MONITORING_DIR/alert_log_file.csv"
CPU_CORE=`nproc --all`
X=$(( $X * $CPU_CORE ))
Y=$(( $Y * $CPU_CORE ))
FLAG1=0
FLAG2=0

# Create Log files
get_file()
{
	if [ -f "$1" ] 
	then 
		if [ ! -s "$1" ]
		then
			update_file_headers "$1"
		fi
	else
		touch "$1"
		update_file_headers "$1"
	fi
}

# Update headers of the log files
update_file_headers()
{
	if [ $1 = $CPU_LOG_FILE ]
	then
		echo -e "Timestamp  1 min load average  5 min load average  15 min load average" > $1
		sed -i '1s|$|\n---------  ------------------  ------------------  -------------------|' $1
	elif [ $1 = $ALERT_LOG_FILE ]
	then
		echo -e "Timestamp   Alert Message         1 min load average  5 min load average  15 min load average" >> $1	
		sed -i '1s|$|\n---------   -------------------   ------------------  ------------------  -------------------|' $1	
	else
		echo "Invalid File"
	fi
}

# Get all the monitoring values
get_values()
{
	UPTIME="$(uptime)"
	TIMESTAMP="$(echo $UPTIME | sed 's/ .*//')"
	LOAD_AVERAGES="$(echo $UPTIME | awk -F 'load average: ' '{print $2}')"
	ONE_MIN=$(echo $LOAD_AVERAGES | awk '{print $1*100}' | sed 's/,//g')
	FIVE_MIN=$(echo $LOAD_AVERAGES | awk '{print $2*100}' | sed 's/,//g')
	FIFTEEN_MIN=$(echo $LOAD_AVERAGES | awk '{print $3*100}')
}

# Log CPU loads onto the log file
log_cpu_loads()
{
	get_file "$CPU_LOG_FILE"
	ONE_MIN_AVG=$(echo "$ONE_MIN/100" | awk -F "/" '{printf "%.2f", ($1/$2)}')
	FIVE_MIN_AVG=$(echo "$FIVE_MIN/100" | awk -F "/" '{printf "%.2f", ($1/$2)}')
	FIFTEEN_MIN_AVG=$(echo "$FIFTEEN_MIN/100" | awk -F "/" '{printf "%.2f", ($1/$2)}')
	echo -e " $TIMESTAMP \t  $ONE_MIN_AVG \t\t    $FIVE_MIN_AVG  \t\t  $FIFTEEN_MIN_AVG" >> $CPU_LOG_FILE
}

# Check for CPU usage and generate alerts
check_cpu_usage()
{
	if [[ ${ONE_MIN%.*} -ge $X ]]
	then
		echo
		echo "HIGH CPU usage: $ONE_MIN% [$ONE_MIN_AVG - last 1 min average] recorded at $TIMESTAMP"
		log_alerts "$TIMESTAMP" "HIGH CPU usage" "$ONE_MIN_AVG" "$FIVE_MIN_AVG" "$FIFTEEN_MIN_AVG"
		if [ $FLAG1 -eq 0 ]
		then
			FLAG1=1
		fi
	fi

	if [[ ${FIVE_MIN%.*} -ge $Y ]] && [[ ${ONE_MIN%.*} -ge ${FIVE_MIN%.*} ]]
	then
		echo
		echo "Very HIGH CPU usage: $FIVE_MIN% [$FIVE_MIN_AVG - last 5 min average] recorded at $TIMESTAMP"
		log_alerts "$TIMESTAMP" "Very HIGH CPU usage" "$ONE_MIN_AVG" "$FIVE_MIN_AVG" "$FIFTEEN_MIN_AVG"
		if [ $FLAG2 -eq 0 ]
		then
			FLAG2=1
		fi
	fi
}

# Log the generated alerts
log_alerts()
{
	get_file "$ALERT_LOG_FILE"
	if [ "$2" = "HIGH CPU usage" ]
	then
		echo -e " $1   $2 \t\t $3 \t\t $4 \t\t\t  $5" >> $ALERT_LOG_FILE
	else
		echo -e " $1   $2 \t $3 \t\t $4 \t\t\t  $5" >> $ALERT_LOG_FILE
	fi
}

################# Main #####################

if [[ $# -lt 4 ]] || [[ $2 -lt $1 ]]
then
	echo "Please enter 4 arguments in the format: T TP X Y where TP>=T"
	echo "Exiting with error code: 1"
	exit 1
fi

if [ ! -d "$MONITORING_DIR" ]
then
	mkdir $MONITORING_DIR
fi	

echo -e "\n$CPU_CORE CPU cores identified."
echo "Applying X=$X% [$CPU_CORE * $3] and Y=$Y% [$CPU_CORE * $4] thresholds on load average of all cores"
echo -e "\nLogging CPU usage.."
while [ $TP -gt 0 ] && [ $T -gt 0 ]
do
	get_values
	log_cpu_loads
	check_cpu_usage
	sleep $T
	TP=$((TP-T))
done
if [ $FLAG1 -eq 0 ]
then
	echo -e "\nNo HIGH CPU usage seen since $2 seconds"
fi
if [ $FLAG2 -eq 0 ]
then
	echo -e "\nNo Very HIGH CPU usage seen since $2 seconds"
fi
