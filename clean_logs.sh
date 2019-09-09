#!/bin/bash

set -e

MONITORING_DIR="/var/log/monitoring"

if [ -d "$MONITORING_DIR" ]
then
#	sleep 10
	rm -r $MONITORING_DIR
fi
