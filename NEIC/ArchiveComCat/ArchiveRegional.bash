#!/bin/bash
#
# Script to download and archive US regional catalogs
#
home_dir=/Users/mrperry/ComCatArchive/REGIONAL
cd $home_dir
BUD=$(date +%Y%m%d)
CT=monthly
En_Yr=$(date +%Y)
#
# Since all regional agencies have yet to upload their historic catalogs
# the data ranges covered by each region must be updated as the become available
# It is possible to simply download everything from 1900 to present, but this increases
# processing time for null datasets.  It's better to be specific.
#
for Region in $(< RegionalNetworks.txt )
do
	if [ "$Region" == "ci" ]; then
		St_Yr=1932
	elif [ "$Region" == "ld" ]; then
		St_Yr=2001
	elif [ "$Region" == "nc" ]; then
		St_Yr=1985
	elif [ "$Region" == "nm" ]; then
		St_Yr=1974
	elif [ "$Region" == "nn" ]; then
		St_Yr=2003
	elif [ "$Region" == "se" ]; then
		St_Yr=1977
	elif [ "$Region" == "us" ]; then
		St_Yr=1973
	elif [ "$Region" == "uw" ]; then
		St_Yr=1969
	else
		St_Yr=2013
	fi
	YR=$St_Yr
	cd ${Region}
	while [[ $YR -le $En_Yr ]]
	do
		mkdir $YR
		work_dir=$(pwd)
		cd $YR
		ii=1
		while [[ $ii -le 12 ]]
		do
			if [[ $ii == 9 || $ii == 4 || $ii == 6 || $ii == 11 ]]; then
				ed=30
			elif [[ $ii == 2 ]]; then
				lpyr_ck=$(expr $YR % 4)
				if [[ $lpyr_ck == 0 ]]; then
      					ed=29
				else
					ed=28
				fi
			else	
				ed=31
			fi
			fname=$(echo ${CT}${ii}.csv)
			curl -s "http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${Region}&orderby=time-asc" > ${fname}
			#
			# Remove header line from all but the first file
			#
			if [[ $ii !=  1 ]]; then
				sed -i -e "1d" ${fname}
			fi	
			let ii=ii+1
		done
		cat ${CT}1.csv ${CT}2.csv ${CT}3.csv ${CT}4.csv ${CT}5.csv ${CT}6.csv ${CT}7.csv ${CT}8.csv ${CT}9.csv ${CT}10.csv ${CT}11.csv ${CT}12.csv > temp${YR}.csv
		rm *.csv-e
		mv temp${YR}.csv ../.
		cd $work_dir
		rm -rf ${YR}
		if [ -s temp${YR}.csv ]; then
			if [[ $YR -ne $St_Yr ]]; then
				sed -i -e "1d" temp${YR}.csv
			fi
		else
			rm temp${YR}.csv
		fi
		let YR=YR+1
	done
	rm *.csv-e
	cat temp* > ${Region}_${BUD}.csv
	rm temp*.csv
	gzip -f ${Region}_${BUD}.csv
	cd $home_dir
done
