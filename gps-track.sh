#!/bin/ash 
#Specify location path and name of the file and frequency how often data should be written to the file 

if [ $# -ne 3 ]; then
	echo "Usage $0: <frequency> <min_speed> <file_dir>"
	exit 254
fi

FREQUENCY=$1 
MIN_SPEED=$2
FILE_DIR=$3
DATE=$(date +%Y%m%d)
FILE=$FILE_DIR/${DATE}-gps-indie.txt

if [ ! -f $FILE ]; then   # Checks if file exists. If not, creates it 
    echo -e 'Latitude \tLongitude \tDatetime \tAltitude \tSpeed \tCourse over ground' > $FILE 
fi 

while [ 1 ]; do         # Infinite while loop 

NEWDATE=$(date +%Y%m%d)                          
if [ "$DATE" != "$NEWDATE" ]; then
	#check if there was a current file, if so upload it
	if [ -f $FILE ]; then
		gzip $FILE
		rclone copy $FILE.gz backblaze:/cngovanduc-NAS-backup/van/
	fi                                                                   
        DATE=$NEWDATE                                                                            
        FILE=$FILE_DIR/${DATE}-gps-indie.txt                                                
        echo -e 'Datetime \tLatitude \tLongitude \tAltitude \tSpeed' > $FILE
fi  

if [ $(gpsctl -s) -eq 1 ]; then   # Checks for GPS fix
	if [ $(echo "$(gpsctl -v) $MIN_SPEED" | awk '{print ($1 >= $2)}') -eq 1 ]; then 
    		echo -e $(gpsctl -e) '\t' $(gpsctl -i) '\t' $(gpsctl -x) '\t' $(gpsctl -a) '\t' $(gpsctl -v) >> $FILE
	fi
fi 
sleep $FREQUENCY
#handle the case of a date change
 
done

