#!/bin/bash
#
# Script to download and archive Global catalogs such as ISC_GEM and GCMT
#
home_dir=/Users/mrperry/ComCatArchive/GLOBAL
cd $home_dir
# BUD = Backup Date
BUD=$(date +%Y%m%d)
CT=monthly
En_Yr=$(date +%Y)
for Region in $(< GlobalCatalogs.txt )
do
	if [ "$Region" == "iscgemsup" ]; then
		St_Yr=1904
	elif [ "$Region" == "atlas" ]; then
		St_Yr=1923
	elif [ "$Region" == "choy" ]; then
		St_Yr=1979
	elif [ "$Region" == "gcmt" ]; then
		St_Yr=1976
	elif [ "$Region" == "official" ]; then
		St_Yr=2004
		En_Yr=2004
	else
		St_Yr=1900
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
