#!/bin/bash
read -p "Enter catalog:   " CT
read -p "Enter Start year:  " St_Yr
read -p "Enter End year:   " En_Yr
read -p "Enter system [0 - normal, 1 - Prod1, 2 - Prod2]:   " SY
YR=$St_Yr
#
# Set WebURL Format up here, then call it later
#
#if [ -z "$CT" ]; then
#	CT=CC
#	if [[ $SY == 1 ]]; then
#		WebURL="http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time"
#	elif [[ $SY == 2 ]]; then
#		WebURL="http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time"
#	else
#		WebURL="http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time"
#	fi
#else
#	if [[ $SY == 1 ]]; then
#		WebURL="http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time"
#	elif [[ $SY == 2 ]]; then
#		WebURL="http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time"
#	else
#		WebURL="http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time"
#	fi
#fi
#
# MATT FINISH FIXING THIS IN THE MORNING!!!!!!!
#
home_dir=$(pwd)
while [[ $YR -le $En_Yr ]]
do
	mkdir $YR
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
		if [ -z "$CT" ]; then
			if [[ $SY == 1 ]]; then
				curl -s "http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time" > ${fname}
			elif [[ $SY == 2 ]]; then
				curl -s "http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time" > ${fname}
			else
               			curl -s "http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time" > ${fname}
			fi
		else
			fname=$(echo ${CT}${ii}.csv)
			if [[ $SY == 1 ]]; then
				curl -s "http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time" > ${fname}
			elif [[ $SY == 2 ]]; then
				curl -s "http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time" > ${fname}
			else
               			curl -s "http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time" > ${fname}
			fi
		fi
		#
		# Remove header line from all but the first file
		#
		if [[ $ii !=  1 ]]; then
			sed -i -e "1d" ${fname}
		fi	
		let ii=ii+1
	done
	#cat ${CT}1.csv ${CT}2.csv ${CT}3.csv ${CT}4.csv ${CT}5.csv ${CT}6.csv ${CT}7.csv ${CT}8.csv ${CT}9.csv ${CT}10.csv ${CT}11.csv ${CT}12.csv > ${CT}${YR}.csv
	cat ${CT}1.csv ${CT}2.csv ${CT}3.csv ${CT}4.csv ${CT}5.csv ${CT}6.csv ${CT}7.csv ${CT}8.csv ${CT}9.csv ${CT}10.csv ${CT}11.csv ${CT}12.csv > ${CT}${YR}.csv
	rm *.csv-e
	mv ${CT}${YR}.csv ../.
	let YR=YR+1
	cd $home_dir
done
