#!/bin/bash

set -e

MONITORING_DIR="/var/log/monitoring"

while true
do
	sleep 2m
	if [ -d "$MONITORING_DIR" ]
	then
		rm -r $MONITORING_DIR
	fi
done
