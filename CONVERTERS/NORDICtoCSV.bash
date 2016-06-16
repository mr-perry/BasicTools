#!/bin/bash
###########################################################
#
# Script for converting SEISAN NORDIC formatted files, which
# contain both hypocentral and phase pick information into CSV
# files easily read by MATLAB and other programs.
#
#
# Inputs:
#     dir_name -- Directory path to the NORDIC files
#     hypo_file -- Name of the CSV containing hypocentral information
#     PHRASE -- Phrase or extension that will help identify all NORDIC files in the directory
#
# Outputs:
#     hypo_file -- CSV file containing hypocentral information for all events
#             format: Origin Time, Latitude, Longitude, Depth, Magnitude, Magnitude Type
#     phase_file -- name of the file is determined by the origin time of the associate hypocenter.  
#                   Will be located in ./PICK under the specified directory
#             format: Station, Phase, Quality, Pick Time, Angle of Incidence, Time Residual, Distance, Azimuth at Sourcei, Weight
#
#
# Written By: Matthew R. Perry
# Last Edit: 14 June 2016
#
############################################################
#
# Begin Script
#
read -p "Enter Directory Path Containing the NORDIC Files:     " dir_name
read -p "Enter the Name of the Hypocenter CSV File:    " hypo_file
read -p "Enter the extension or common phrase needed to identify all NORDIC files:    " PHRASE
echo "OriginTime,Latitude,Longitude,Depth,Magnitude,MagnitudeType" > $hypo_file
#
# For each file, grab and record the hypocentral information
#
for event in $(ls ${PHRASE}*)
do
	#
	# See if event file has a line H (more accurate hypocentral information)
	#
	hypo_info=$(grep '[H]$' $event)
	if [ ! -z "$hypo_info" ]; then
	      yy=$(echo "$hypo_info" | cut -c 2-5)
	      if [ -z $(echo "$hypo_info" | cut -c 7) ]; then
		      mm=0$(echo "$hypo_info" | cut -c 8)
	      else
	              mm=$(echo "$hypo_info" | cut -c 7-8)
	      fi
	      if [ -z $(echo "$hypo_info" | cut -c 9) ]; then
		      dd=0$(echo "$hypo_info" | cut -c 10)
	      else
	              dd=$(echo "$hypo_info" | cut -c 9-10)
	      fi
	      if [ -z $(echo "$hypo_info" | cut -c 12) ]; then
		      HH=0$(echo "$hypo_info" | cut -c 13)
	      else
	              HH=$(echo "$hypo_info" | cut -c 12-13)
	      fi
	      if [ -z $(echo "$hypo_info" | cut -c 14) ]; then
		      MM=0$(echo "$hypo_info" | cut -c 15)
	      else
	      	      MM=$(echo "$hypo_info" | cut -c 14-15)
	      fi
	      if [ -z $(echo "$hypo_info" | cut -c 17) ]; then
		      SS=0$(echo "$hypo_info" | cut -c 18)
	      else
              	      SS=$(echo "$hypo_info" | cut -c 17-18)
	      fi
	      MS=$(echo "$hypo_info" | cut -c 20-22)
	      LT=$(echo "$hypo_info" | cut -c 24-32)
	      LN=$(echo "$hypo_info" | cut -c 34-43)
	      DP=$(echo "$hypo_info" | cut -c 45-52)
	      mag_info=$(grep '[1]$' $event)
	      MG=$(echo "$mag_info" | cut -c 56-59)
              MT=$(echo "$mag_info" | cut -c 60)	      
	      if [ "$MT" == "L" ]; then
		      MT=ML
	      elif [ "$MT" == "b" ]; then
		      MT=mb
	      elif [ "$MT" == "B" ]; then
		      MT=mB
	      elif [ "$MT" == "s" ]; then
		      MT=Ms
	      elif [ "$MT" == "S" ]; then
		      MT=MS
	      elif [ "$MT" == "W" ]; then
		      MT=MW
	      elif [ "$MT" == "G" ]; then
		      MT=MbLg
	      elif [ "$MT" == "C" ]; then
		      MT=Mc
	      else
		      MT=MT
	      fi
	      echo $yy-$mm-$dd $HH:$MM:$SS.$MS,$LT,$LN,$DP,$MG,$MT >> $hypo_file
	      #
	      # Now grab phase pick data
	      # 
	      phase_file="$yy$mm$dd$HH$MM$SS$MS.phase"
	      echo "Station,Phase,Quality,PickTime,AOI,TimeResidual,EpiDistance,AzimuthAtSource,Weight" > $phase_file
	      grep '[ ]$' $event > pick.temp
	      while read LINE; do
		      PH=$(echo "$LINE" | cut -c 10)
		      if [ $PH == "P" ] || [ $PH == "S" ]; then
			      ST=$(echo "$LINE" | cut -c 1-5)
			      QU=$(echo "$LINE" | cut -c 9)
			      WG=$(echo "$LINE" | cut -c 14)
			      if [ -z $WG ]; then
				      WG=0
			      fi
			      if [ -z $(echo "$LINE" | cut -c 18) ]; then 
		                  PHH=0$(echo "$LINE" | cut -c 19)
			      else
		              	  PHH=$(echo "$LINE" | cut -c 18-19)	
			      fi
			      if [ -z $(echo "$LINE" | cut -c 20) ]; then
				  PMM=0$(echo "$LINE" | cut -c 21)
			      else
			          PMM=$(echo "$LINE" | cut -c 20-21)
			      fi
			      if [ -z $(echo "$LINE" | cut -c 22) ]; then
				  PSS=0$(echo "$LINE" | cut -c 23-27)
			      else
				  PSS=$(echo "$LINE" | cut -c 22-27)
			      fi
			      AIN=$(echo "$LINE" | cut -c 57-59)
			      TRS=$(echo "$LINE" | cut -c 63-67)
			      DIS=$(echo "$LINE" | cut -c 71-74)
			      AZ_S=$(echo "$LINE" | cut -c 76-78)
			      echo $ST,$PH,$QU,$yy-$mm-$dd $PHH:$PMM:$PSS,$AIN,$TRS,$DIS,$AZ_S,$WG >> $phase_file
		      fi
	      done < pick.temp
	      rm pick.temp
      fi
done
mkdir PICKS
mv *.phase ./PICKS/.
#
# END OF SCRIPT
#
