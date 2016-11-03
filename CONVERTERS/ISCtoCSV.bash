#!/bin/bash
###########################################################
#
#
# ISC to CSV converter, 
# which contain both hypocentral and phase pick information into CSV
# files easily read by MATLAB and other programs. 
#
# Written By: Matthew R. Perry
# Last Edit: 03 November 2016
#               
############################################################
read -p "Enter path to directory:    " dir_name
read -p "Enter name of hypocenter file to be created:    " hypo_file
echo "OriginTime,Latitude,Longitude,Depth,Magnitude,MagnitudeType" > $hypo_file
#
# For each file, grab and record the hypocentral information
#
for event in $(ls FAIRVIEW_US*)
do
	LINES=$(wc -l $event | awk '{print $1}')
	ii=1
	while [ $ii -lt $LINES ]
	do
		FC=$(awk -v L="$ii" 'NR==L {print $1}' $event) 
		if [ "$FC" == "Date" ]; then
			let ii=ii+1 # Advance Line number by 1
			Date_Line=$(awk -v L="$ii" 'NR==L {print $0}' $event)
			yy=$(echo "$Date_Line" | cut -c 1-4)
			mm=$(echo "$Date_Line" | cut -c 6-7)
			dd=$(echo "$Date_Line" | cut -c 9-10)
			HH=$(echo "$Date_Line" | cut -c 12-13)
			MM=$(echo "$Date_Line" | cut -c 15-16)
			SS=$(echo "$Date_Line" | cut -c 18-19)
			MS=$(echo "$Date_Line" | cut -c 21-22)0
			LT=$(awk -v L="$ii" 'NR==L {print $5}' $event)
			LN=$(awk -v L="$ii" 'NR==L {print $6}' $event)
			DP=$(awk -v L="$ii" 'NR==L {print $10}' $event)
			let ii=ii+1 # Advance line number by 1
		elif [ "$FC" == "Magnitude" ]; then
			let ii=ii+1 # Advance line by 1
			MG=$(awk -v L="$ii" 'NR==L {print $2}' $event)
			MT=$(awk -v L="$ii" 'NR==L {print $1}' $event)
			#
			# Once Magnitude has been recorded, print to output file
			#
			echo $yy-$mm-$dd $HH:$MM:$SS.$MS,$LT,$LN,$DP,$MG,$MT >> $hypo_file
		#
		# Once the magnitude line has been reached, initial phase file and continue increasing ii until Sta is reached
		#
		elif [ "$FC" == "Sta" ]; then
			let ii=ii+1
			phase_file="$yy$mm$dd$HH$MM$SS$MS.phase"
			STA=$(awk -v L="$ii" 'NR==L {print $1}' $event)
			while [ ! -z  "$STA" ];
			do
				PH=$(awk -v L="$ii" 'NR==L {print $4}' $event)
				QU=999
				WG=999
				PT=$(awk -v L="$ii" 'NR==L {print $5}' $event)
				DIS=$(awk -v L="$ii" 'NR==L {print $2}' $event)
				AZ_S=$(awk -v L="$ii" 'NR==L {print $3}' $event)
				TRS=$(awk -v L="$ii" 'NR==L {print $6}' $event)
				AIN=999
				echo $STA,$PH,$QU,$yy-$mm-$dd $PT,$AIN,$TRS,$DIS,$AZ_S,$WG >> $phase_file
				let ii=ii+1
				STA=$(awk -v L="$ii" 'NR==L {print $1}' $event)
			done
		fi
		let ii=ii+1
	done 	
done
mkdir PICKS
mv *.phase ./PICKS/.
