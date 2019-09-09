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
	ONE_MIN=$(echo $LOAD_AVERAGES | awk '{print $1}' | sed 's/,//g')
	FIVE_MIN=$(echo $LOAD_AVERAGES | awk '{print $2}' | sed 's/,//g')
	FIFTEEN_MIN=$(echo $LOAD_AVERAGES | awk '{print $3}')
}

# Log CPU loads onto the log file
log_cpu_loads()
{
	get_file "$CPU_LOG_FILE"
	echo -e " $TIMESTAMP \t  $ONE_MIN \t\t    $FIVE_MIN \t\t  $FIFTEEN_MIN" >> $CPU_LOG_FILE
}

# Check for CPU usage and generate alerts
check_cpu_usage()
{
	echo
	if [[ ${ONEMIN%.*} -ge $X ]]
	then
		echo "HIGH CPU usage [ $ONE_MIN ] recorded at $TIMESTAMP"
		log_alerts "$TIMESTAMP" "HIGH CPU usage" "$ONE_MIN" "$FIVE_MIN" "$FIFTEEN_MIN"
	fi

	if [[ ${FIVE_MIN%.*} -ge $Y ]] && [[ ${ONE_MIN%.*} -ge $Y ]]
	then
		echo "Very HIGH CPU usage [ $FIVE_MIN ] recorded at $TIMESTAMP"
		log_alerts "$TIMESTAMP" "Very HIGH CPU usage" "$ONE_MIN" "$FIVE_MIN" "$FIFTEEN_MIN"
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

if [ ! -d "$MONITORING_DIR" ]
then
	mkdir $MONITORING_DIR
fi	

while [ $TP -gt 0 ] && [ $T -gt 0 ]
do
	get_values
	log_cpu_loads
	check_cpu_usage
	sleep $T
	TP=$((TP-T))
done
