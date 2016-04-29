#!/bin/bash
#
# Given an input file of origin times and locations, return a list of event IDs
#
read -p "Enter File Name:   " file
read -p "Enter Time window (seconds):   " time_window
read -p "Enter Distance tolerance (kilometers):     " dist_tol
echo Finding Events
while IFS="," read D T LAT LON; do
	#
	# Get Hour,  minute and Second
	#
	HH=$(echo $T | cut -c 1-2)
	MM=$(echo $T | cut -c 4-5)
	SS=$(echo $T | cut -c 7-8)
	#
	# 5 - seconds before
	#
	let SSS=$((10#$SS))-$time_window
	#
	# if SS <=4, SSS will be negative
	#
        if [[ $((10#$SSS)) -lt 0 ]]; then
		let SSS=SSS+60
		let SMM=$((10#$MM))-1	
		#
		# If on 0th minute, minute will now be negative
		#
		if [[ $SMM -lt 0 ]]; then
			let SMM=SMM+60
			let SHH=SHH-1
		else
			let SHH=$((10#$HH))
		fi
	#
	# If SS > 4, SMM will equal original minutes
	#
	else
		let SMM=$((10#$MM))
		let SHH=$((10#$HH))
	fi
	#
	# Pad single digits with zeros
	#
	if [[ ${#SSS} -eq 1 ]]; then
		SSS=0${SSS}
	fi
	if [[ ${#SMM} -eq 1 ]]; then
		SMM=0${SMM}
	fi
	if [[ ${#SHH} -eq 1 ]]; then
		SHH=0${SHH}
	fi
	#
	# Set Start Time
	#
	ST=$(echo $SHH:$SMM:$SSS)
	#
	# 5- seconds after
	#
	let ESS=$((10#$SS))+$time_window
	#
	# If result is over 60, move to next minute
	#
	if [[ $((10#$ESS)) -ge 60 ]]; then
		let ESS=ESS-60
		let EMM=$((10#$MM))+1
		#
		# If new minute is gt 60
		#
		if [[ $((10#$EMM)) -ge 60 ]]; then
			let EMM=EMM-60
			let EHH=$((10#$HH))+1
		else
			EHH=$((10#$HH))
		fi
	else
		EMM=$((10#$MM))
		EHH=$((10#$HH))
	fi
	#
	# Pad single digits
	#
	if [[ ${#ESS} -eq 1 ]]; then
		ESS=0${ESS}
	fi
	if [[ ${#EMM} -eq 1 ]]; then
		EMM=0${EMM}
	fi
	if [[ ${#EHH} -eq 1 ]]; then
		EHH=0${EHH}
	fi
	#
	# Set end time
	#
	ET=$(echo $EHH:$EMM:$ESS)
	curl -s "http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${D}%20${ST}&endtime=${D}%20${ET}&latitude=${LAT}&longitude=${LON}&maxradiuskm=${dist_tol}&orderby=time-asc" | tail -n +2 >> OUTPUT.csv
done < ${file}
OP_wc=$(wc -l OUTPUT.csv)
IP_wc=$(wc -l ${file}) 
echo Input: $OP_wc
echo Output: $IP_wc
