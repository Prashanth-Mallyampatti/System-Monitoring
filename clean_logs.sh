#!/bin/bash

set -e

MONITORING_DIR="/var/log/monitoring"

# Remove logs every hour
while true
do
	sleep 1h
	if [ -d "$MONITORING_DIR" ]
	then
		rm -r $MONITORING_DIR
	fi
done
