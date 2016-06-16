#!/bin/bash
dir_name="/Users/mrperry/Documents/PROJECTS/EastRockiesAssessment/OGSMagsVsNEICMags/Data/FAIRVIEW/PHASE_PICKS/US/SPLIT"
hypo_file="NEIC_hypos.csv"
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
	#
#	# See if event file has a line H (more accurate hypocentral information)
	#
#	hypo_info=$(grep '[H]$' $event)
#	if [ ! -z "$hypo_info" ]; then
#	      yy=$(echo "$hypo_info" | cut -c 2-5)
#	      if [ -z $(echo "$hypo_info" | cut -c 7) ]; then
#		      mm=0$(echo "$hypo_info" | cut -c 8)
#	      else
#	              mm=$(echo "$hypo_info" | cut -c 7-8)
#	      fi
#	      if [ -z $(echo "$hypo_info" | cut -c 9) ]; then
#		      dd=0$(echo "$hypo_info" | cut -c 10)
#	      else
#	              dd=$(echo "$hypo_info" | cut -c 9-10)
#	      fi
#	      if [ -z $(echo "$hypo_info" | cut -c 12) ]; then
#		      HH=0$(echo "$hypo_info" | cut -c 13)
#	      else
#	              HH=$(echo "$hypo_info" | cut -c 12-13)
#	      fi
#	      if [ -z $(echo "$hypo_info" | cut -c 14) ]; then
#		      MM=0$(echo "$hypo_info" | cut -c 15)
#	      else
#	      	      MM=$(echo "$hypo_info" | cut -c 14-15)
#	      fi
#	      if [ -z $(echo "$hypo_info" | cut -c 17) ]; then
#		      SS=0$(echo "$hypo_info" | cut -c 18)
#	      else
#              	      SS=$(echo "$hypo_info" | cut -c 17-18)
#	      fi
#	      MS=$(echo "$hypo_info" | cut -c 20-22)
#	      LT=$(echo "$hypo_info" | cut -c 24-32)
#	      LN=$(echo "$hypo_info" | cut -c 34-43)
#	      DP=$(echo "$hypo_info" | cut -c 45-52)
#	      mag_info=$(grep '[1]$' $event)
#	      MG=$(echo "$mag_info" | cut -c 56-59)
#              MT=$(echo "$mag_info" | cut -c 60)	      
#	      if [ "$MT" == "L" ]; then
#		      MT=ML
#	      elif [ "$MT" == "b" ]; then
#		      MT=mb
#	      elif [ "$MT" == "B" ]; then
#		      MT=mB
#	      elif [ "$MT" == "s" ]; then
#		      MT=Ms
#	      elif [ "$MT" == "S" ]; then
#		      MT=MS
#	      elif [ "$MT" == "W" ]; then
#		      MT=MW
#	      elif [ "$MT" == "G" ]; then
#		      MT=MbLg
#	      elif [ "$MT" == "C" ]; then
#		      MT=Mc
#	      else
#		      MT=MT
#	      fi
#	      echo $yy-$mm-$dd $HH:$MM:$SS.$MS,$LT,$LN,$DP,$MG,$MT >> $hypo_file
#	      #
#	      # Now grab phase pick data
#	      # 
#	      phase_file="$yy$mm$dd$HH$MM$SS$MS.phase"
#	      echo "Station,Phase,Quality,PickTime,AOI,TimeResidual,EpiDistance,AzimuthAtSource,Weight" > $phase_file
#	      grep '[ ]$' $event > pick.temp
#	      while read LINE; do
#		      PH=$(echo "$LINE" | cut -c 10)
#		      if [ $PH == "P" ] || [ $PH == "S" ]; then
#			      ST=$(echo "$LINE" | cut -c 1-5)
#			      QU=$(echo "$LINE" | cut -c 9)
#			      WG=$(echo "$LINE" | cut -c 14)
#			      if [ -z $WG ]; then
#				      WG=0
#			      fi
#			      if [ -z $(echo "$LINE" | cut -c 18) ]; then 
#		                  PHH=0$(echo "$LINE" | cut -c 19)
#			      else
#		              	  PHH=$(echo "$LINE" | cut -c 18-19)	
#			      fi
#			      if [ -z $(echo "$LINE" | cut -c 20) ]; then
#				  PMM=0$(echo "$LINE" | cut -c 21)
#			      else
#			          PMM=$(echo "$LINE" | cut -c 20-21)
#			      fi
#			      if [ -z $(echo "$LINE" | cut -c 22) ]; then
#				  PSS=0$(echo "$LINE" | cut -c 23-27)
#			      else
#				  PSS=$(echo "$LINE" | cut -c 22-27)
#			      fi
#			      AIN=$(echo "$LINE" | cut -c 57-59)
#			      TRS=$(echo "$LINE" | cut -c 63-67)
#			      DIS=$(echo "$LINE" | cut -c 71-74)
#			      AZ_S=$(echo "$LINE" | cut -c 76-78)
#			      echo $ST,$PH,$QU,$yy-$mm-$dd $PHH:$PMM:$PSS,$AIN,$TRS,$DIS,$AZ_S,$WG >> $phase_file
#		      fi
#	      done < pick.temp
#	      rm pick.temp
#      fi
#done
#mkdir PICKS
##mv *.phase ./PICKS/.
