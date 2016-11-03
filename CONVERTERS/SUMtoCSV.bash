#!/bin/bash
#
# Convert Hypocenter ARC SUM catalog to format readable by QCReport and QCmulti
# NOTE: ALL EVENTS TAKEN AS EARTHQUAKES UNTIL SUCH TIME THAT THERE IS SOME CLARIFICATION
# OR DOCUMENTATION PROVIDED FROM HVO.
#
# NOTE: ALL MAGNITUDE TYPE CODES ARE PRESERVED UNTIL SUCH TIME THAT THERE IS SOME CLARIFICATION
# OR DOCUMENTATION PROVIDED FROM HVO.
#
# Documentation http://pubs.usgs.gov/of/1999/ofr-99-0023/HYPOELLIPSE_Full_Manual.pdf   Chapter 2 -63
#
# Columns (Edited from above reference to reflect fields used
# ID - Event ID					137	146
# KDATE - year, month, day (e.g. 19981231)	1	8	i8
# KHRMN - hour, minute (e.g. 2358) 		9	12	i4
# KSEC - seconds				13	16	F4.2
# LAT (degrees)					17	18	i2
# N or S						19	A1
# LAT (minutes)					20	23	F4.2
# LON (degrees)					24	26	i3
# E or W						27	A1
# LON (minutes)					28	31	F4.2
# DEPTH (km) [negatives allowed]		32	36	F5.2
# Preferred Magnitude				148	150	F2.1
# Event Type: ALL EVENTS TAKEN AS EARTHQUAKE UNTIL CLARIFICATION OF EVENT TYPE CODE 
#
# Written by: Matthew R. Perry
# Last Update: 03 November 2016
####################################################################################################
read -p "Enter File Name:	" sum_file
read -p "Enter New File Name:	" new_file
read -p "Enter catalog abbreviation:     " CT
echo "EventID, OriginTime, Latitude, Longitude, Depth, Magnitude, MagType, EventType" > $new_file
#
# Step through file
#
while read -r LINE; do
	#
	# Get Event ID: CT+Column 137-146
	#
	id=$(echo "$LINE" | cut -c 137-146 | sed 's/ //g')
	id=$(echo $CT$id)
	#
	# Parse Date Time Columns
	#
	yr=$(echo "$LINE" | cut -c 1-4)
	mn=$(echo "$LINE" | cut -c 5-6)
	dy=$(echo "$LINE" | cut -c 7-8)
	hr=$(echo "$LINE" | cut -c 9-10)
	mt=$(echo "$LINE" | cut -c 11-12)
	sc=$(echo "$LINE" | cut -c 13-14)
	ms=$(echo "$LINE" | cut -c 15-16)
	#
	# Construct OriginTime string
	#
	OT=$(echo $yr-$mn-$dy $hr:$mt:$sc.${ms}0)
	#
	# Parse Latitude degrees (lt_d), sign (lt_s), minute (lt_m), 
	# and fractional minute (lt_md) columns
	#
	lt_d=$(echo "$LINE" | cut -c 17-18)
        lt_s=$(echo "$LINE" | cut -c 19)
	if [[ $lt_s == "W" ]]; then
		lt_s=-
	fi
	lt_m=$(echo "$LINE" | cut -c 20-21 | sed 's/ //g')
	lt_md=$(echo "$LINE" | cut -c 22-23 | sed 's/ /0/g')
	TMP=$(echo ${lt_m}.${lt_md})
	LAT=$(echo "$lt_d+$TMP/60" | bc -l)
	#
	# Parse Longitude degrees (ln_d), sign (ln_s), minute (ln_m), 
	# and fractional minute (ln_md) columns
	#
	ln_d=$(echo "$LINE" | cut -c 24-26)
	ln_s=$(echo "$LINE" | cut -c 27)
	if [[ $ln_s == "S" ]]; then
		ln_s=-
	elif [[ $CT == "HV" ]]; then
		ln_s=-
	fi
	ln_m=$(echo "$LINE" | cut -c 28-29 | sed 's/ //g')
	ln_md=$(echo "$LINE" | cut -c 30-31 | sed 's/ /0/g')
	TMP=$(echo ${ln_m}.${ln_md})
	LON=$(echo "$ln_d+$TMP/60" | bc -l)
	#
	# Get Depth Information F5.2
	#
	dp=$(echo "$LINE" | cut -c 32-34 | sed 's/ //g')
	if [ -z "$dp" ]; then
		dp=0
	fi
	dp_d=$(echo "$LINE" | cut -c 35-36 | sed 's/ /0/g') 
	if [ ${#dp_f} -eq "1" ]; then
		dp_p=$(echo 0$dp_d)
	fi
	DP=$(echo $dp.$dp_d)
	#
	# Get Preferred Magnitude
	#
	mg=$(echo "$LINE" | cut -c 148 | sed 's/ /0/g')
	mg_d=$(echo "$LINE" | cut -c 149-150 | sed 's/ /0/g')	
	MG=$(echo $mg.$mg_d)
	if [[ "$MG" == "0.0" ]]; then
		MG=NaN
	fi
	mt=$(echo "$LINE" | cut -c 147)
	#
	# Event type
	#
	et=$(echo "$LINE" | cut -c 81 | sed 's/ /earthquake/g')
	if [[ "$et" == "F" ]]; then
		et="False Trigger"
	elif [[ "$et" == "L" ]]; then
		et="earthquake"
	elif [[ "$et" == "E" ]]; then
		et="earthquake"
	elif [[ "$et" == "T" ]]; then
		et="earthquake"
	elif [[ "$et" == "B" ]]; then
		et="Volcano Long Period"
	elif [[ "$et" == "S" ]]; then
		et="Artifical Source"
	elif [[ "$et" == "O" ]]; then
		et="Other"
	elif [[ "$et" == "R" ]]; then
		et="Regional--Poor"
	elif [[ "$et" == "C" ]]; then
		et="Calibration"
	elif [[ "$et" == "N" ]]; then
		et="Nuclear Explosion"
	elif [[ "$et" == "A" ]]; then
		et="Volcano Tectonic"
	elif [[ "$et" == "G" ]]; then
		et="Glacial Event"
	elif [[ "$et" == "Q" ]]; then
		et="Quarry Blast"
	elif [[ "$et" == "X" ]]; then
		et="Emergent from Volcano"
	elif [[ "$et" == "V" ]]; then
		et="Volcano tremor or eruption"
	elif [[ "$et" == "I" ]]; then
		et="Augustine Volcano"
	elif [[ "$et" == "H" ]]; then
		et="VT-LP"
	fi
	echo $id,$OT,${lt_s}$LAT,${ln_s}$LON,$DP,$MG,$mt,'earthquake' >> $new_file 
	let ii=ii+1
done < $sum_file
