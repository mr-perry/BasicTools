#!/bin/bash
clear
#
# Get File Name
#
read -p "Enter File Name:  " file
read -p "Enter Catalog Format [1 for ComCat (EventID in Column 12), 2 for LibComCat (EventID in Column 1)]:  " format
#
# Parse Event IDs
#
echo Getting Event IDs
if [ $format -eq 1 ]; then
	awk -v F1="$file" -F "\"*,\"*" '{print $12}' "${file}" > EventId.csv
elif [ $format -eq 2 ]; then
	awk -v F1="$file" -F "\"*,\"*" '{print $1}' "${file}" > EventId.csv
else
	echo "Format Not Recognized"
fi
