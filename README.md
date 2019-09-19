# System-Monitoring

To run the script use the following command:

`bash ./monitoring.sh <T> <TP> <X> <Y>`

Where,

T: seconds granularity to record CPU load averages

TP: total seconds for the script to run

X: One minute CPU threshold (0-100%)

Y: Five minute CPU threshold (0-100%)

Eg: `bash ./monitoring.sh 2 20 30 25`

Here, the script records CPU load averages for every 2 seconds for 20 seconds. The one-minute threshold is 30% and five-minute threshold is 25%


`stress-ng -c 2 -l 100 -t 200`

```
root@t11_vm8:~/System-Monitoring# bash ./monitoring.sh 2 20 30 25

4 CPU cores identified.
Applying X=120% [4 * 30] and Y=100% [4 * 25] thresholds on load average of all cores

Logging CPU usage..

HIGH CPU usage: 120% [1.20 - last 1 min average] recorded at 20:33:09

HIGH CPU usage: 120% [1.20 - last 1 min average] recorded at 20:33:11

HIGH CPU usage: 126% [1.26 - last 1 min average] recorded at 20:33:13

Very HIGH CPU usage: 100% [1.00 - last 5 min average] recorded at 20:33:13
root@t11_vm8:~/System-Monitoring#
```

```
root@t11_vm8:~/System-Monitoring# cat /var/log/monitoring/cpu_log.csv
Timestamp  1 min load average  5 min load average  15 min load average
---------  ------------------  ------------------  -------------------
 20:32:55 	  0.97 		    0.93  		  0.69
 20:32:57 	  0.97 		    0.93  		  0.69
 20:32:59 	  1.05 		    0.95  		  0.70
 20:33:01 	  1.05 		    0.95  		  0.70
 20:33:03 	  1.13 		    0.96  		  0.70
 20:33:05 	  1.13 		    0.96  		  0.70
 20:33:07 	  1.13 		    0.96  		  0.70
 20:33:09 	  1.20 		    0.98  		  0.71
 20:33:11 	  1.20 		    0.98  		  0.71
 20:33:13 	  1.26 		    1.00  		  0.72
root@t11_vm8:~/System-Monitoring# cat /var/log/monitoring/alert_log_file.csv
Timestamp   Alert Message         1 min load average  5 min load average  15 min load average
---------   -------------------   ------------------  ------------------  -------------------
 20:33:09   HIGH CPU usage 		 1.20 		 0.98 			  0.71
 20:33:11   HIGH CPU usage 		 1.20 		 0.98 			  0.71
 20:33:13   HIGH CPU usage 		 1.26 		 1.00 			  0.72
 20:33:13   Very HIGH CPU usage 	 1.26 		 1.00 			  0.72
root@t11_vm8:~/System-Monitoring#
```
