#!/bin/bash
###########################################################
#
#
# MLOC to CSV file converter.  Will return both hypocenter file and associated phase files
#
# Written By: Matthew R. Perry
# Last Edit: 03 November 2016
#               
############################################################

read -p "Enter File Name:   " file
read -p "Enter File Name for Hypocenter Data:   " hypo_file
echo "ID,OT,Lat,Lon,Dep,Mag,MagTy" > $hypo_file
#
# Go through file
#
ii=0
while read -r LINE; do
	FC=$(echo $LINE | awk '{print $1}')
	SC=$(echo $LINE | awk '{print $2}')
	if [ "$FC" == "CLUSTER" ]; then
		YR=9999
		MN=9999
		DY=9999
		HR=9999
		MN=9999
		SC=9999
		MS=9999
		LT=9999
		LN=9999
		DP=9999
		MG=9999
	elif [ "$FC" == "Final" ]; then
		YR=$(echo $LINE | awk '{print $2}')
		MN=$(echo $LINE | awk '{print $3}')
		if [ ${#MN} -eq 1  ]; then
			MN=0$(echo $MN)
		fi
		DY=$(echo $LINE | awk '{print $4}')
		if [ ${#DY} -eq 1 ]; then
			DY=0$(echo $DY)
		fi
		HR=$(echo $LINE | awk '{print $5}')
		if [ ${#HR} -eq 1 ]; then
			HR=0$(echo $HR)
		fi
		MM=$(echo $LINE | awk '{print $6}')
		if [ ${#MM} -eq 1 ];then
			MM=0$(echo $MM)
		fi
		SC=$(echo $LINE | awk '{print $7}')
		if [ ${#SC} -eq 4 ]; then
			SS=$(echo $SC | cut -c 1-2)
			MS=$(echo $SC | cut -c 4)00
		elif [ ${#SC} -eq 3 ]; then
			SS=0$(echo $SC | cut -c 1)
			MS=$(echo $SC | cut -c 3)00
		fi
		LT=$(echo $LINE | awk '{print $8}')
		LN=$(echo $LINE | awk '{print $9}')
		DP=$(echo $LINE | awk '{print $10}')
		MG=$(echo $LINE | awk '{print $11}')
		MT=None
		echo $YR-$MN-$DY $HR:$MM:$SS.$MS,$LT,$LN,$DP,$MG,$MT >> $hypo_file
		phase_file="$YR$MN$DY$HR$MM$SS$MS.phase"
		echo "Station,Phase,Quality,PickTime,AOI,TimeResidual,EpiDistance,AzimuthAtSource,Weight" > $phase_file
	elif [ "$FC" == "CODE" ]; then
		STA=9999
		QUA=9999
		PHA=9999
		WEI=9999
		DIS=9999
		AZ_S=9999
		TRES=9999
		AIN=9999
	elif [ "$SC" == "Pg" ] || [ "$SC" == "Sg" ] || [ "$SC" == "Pn" ] || [ "$SC" == "Sn" ] || [ "$SC" == "S" ] || [ "$SC" == "P" ]; then
		STA=$FC
		QUA=$(echo $LINE | awk '{print $8}')
		PHA=$SC
		WEI=$(echo $LINE | awk '{print $7}')
		DIS=$(echo $LINE | awk '{print $4}')
		AZ_S=$(echo $LINE | awk '{print $5}')
		# For NEIC
#		TRES=$(echo $LINE | awk '{print $14}')
		# For OGS
		TRES=$(echo $LINE | awk '{print $12}')
		echo $STA,$PHA,$QUA,$YR-$MN-$DY $HR:$MM:$SS.$MS,$AIN,$TRES,$DIS,$AZ_S,$WEI >> $phase_file
	fi
done < $file 
mkdir PICKS
mv *.phase ./PICKS/.
echo Finished
