#!/bin/bash
###########################################################
#
# Convert CNSS formatted data to CSV file usable by CatStat
#
# Inputs:
#     fname -- CNSS file name; must be path specific
#     newfile -- Name of output file to be produced.  Please include file extension.
#       
# Outputs:
#	newfile -- CSV file with the following fields: EventID, Origin Time, Latitude,
#			Longitude, Depth, Magnitude, Event Type               
#               
# Written By: Matthew R. Perry
# Last Edit: 03 November 2016
#               
############################################################
read -p "File Name (be path specific): " fname
read -p "Output File name: " newfile
#
# Get Number of Events
#
Locs=$(grep \$loc $fname | wc -l | awk '{print $1}')
echo "ID,OT,Lat,Lon,Dep,Mag,EvType" > $newfile
#
# Step through event list
#
#
# Get Loc and Mag Files
# 
grep \$loc $fname > LOC_FILE 
grep \$mag $fname > MAG_FILE
while read LOC_LINE <&3 && read MAG_LINE <&4; do
	if [ ! -z $(echo $MAG_LINE | cut -c 5) ]; then
		YR=$(echo $LOC_LINE | cut -c 6-9)
		if [ -z $(echo $LOC_LINE | cut -c 10) ]; then
			MN="0$(echo $LOC_LINE | cut -c 11)"
		else
			MN=$(echo $LOC_LINE | cut -c 10-11)
		fi
		if [ -z $(echo $LOC_LINE | cut -c 12) ]; then
			DY="0$(echo $LOC_LINE | cut -c 13)"
		else
			DY=$(echo $LOC_LINE | cut -c 12-13)
		fi
		if [ -z $(echo $LOC_LINE | cut -c 14) ]; then
			HR="0$(echo $LOC_LINE | cut -c 15)"
		else
			HR=$(echo $LOC_LINE | cut -c 14-15)
		fi
		if [ -z $(echo $LOC_LINE | cut -c 16) ]; then
			MM="0$(echo $LOC_LINE | cut -c 17)"
		else
			MM=$(echo $LOC_LINE | cut -c 16-17)
		fi
		if [ -z $(echo $LOC_LINE | cut -c 18) ]; then
			SC="0$(echo $LOC_LINE | cut -c 19-24)"
		else
			SC=$(echo $LOC_LINE | cut -c 18-24)
		fi
		OT="$YR-$MN-$DY $HR:$MN:$SC"
		LAT=$(echo $LOC_LINE | cut -c 25-33)
		LON=$(echo $LOC_LINE | cut -c 34-43)
		DEP=$(echo $LOC_LINE | cut -c 44-50)
		CAT=$(echo $LOC_LINE | cut -c 54-56)
		#Check to see if the third character is blank
		if [ -z $(echo $CAT | cut -c 3) ]; then
			CAT=$(echo $LOC_LINE | cut -c 54-55)
		fi
		MAG=$(echo $MAG_LINE | cut -c 6-10)
       	 MTY=$(echo $MAG_LINE | cut -c 11-12)
		ID="$CAT$YR$MN$DY$HR$MM"
		ETY="earthquake"
		ROW="$ID,$OT,$LAT,$LON,$DEP,$MAG,$ETY"
		echo $ROW >> $newfile
	fi
#		let ii=ii+1
done 3<LOC_FILE 4<MAG_FILE
