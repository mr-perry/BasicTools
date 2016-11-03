#!/bin/bash
#
# The is a basic script to download and archive Authoritative ComCat
#
home_dir=/Users/mrperry/ComCatArchive/AUTHORITATIVE
cd $home_dir
# BUD = Backup Data (Today's Date)
BUD=$(date +%Y%m%d)
CT=monthly
St_Yr=1900
En_Yr=$(date +%Y)
YR=$St_Yr
while [[ $YR -le $En_Yr ]]
do
	mkdir $YR
	cd $YR
	ii=1
	#
	# Determine days per month
	#
	while [[ $ii -le 12 ]]
	do
		if [[ $ii == 9 || $ii == 4 || $ii == 6 || $ii == 11 ]]; then
			ed=30
		elif [[ $ii == 2 ]]; then
			#
			# This is a leap year check; however, it does not consider the millennial leap
			# year rule. 03 Nov 2016 -- Matt Perry
			#
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
		#
		# Using ComCat API to grab data in monthy bins
		#
		curl -s "http://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time-asc" > ${fname}
		#
		# Remove header line from all but the first file
		#
		if [[ $ii !=  1 ]]; then
			sed -i -e "1d" ${fname}
		fi	
		let ii=ii+1
	done
	#
	# Combine year data into one file
	#
	cat ${CT}1.csv ${CT}2.csv ${CT}3.csv ${CT}4.csv ${CT}5.csv ${CT}6.csv ${CT}7.csv ${CT}8.csv ${CT}9.csv ${CT}10.csv ${CT}11.csv ${CT}12.csv > temp${YR}.csv
	mv temp${YR}.csv ../.
	cd $home_dir
	rm -rf ${YR}
	# Remove first line from all but start year CSV file
	if [[ $YR -ne $St_Yr ]]; then
		sed -i -e "1d" temp${YR}.csv
	fi
	let YR=YR+1
done
rm *.csv-e
# Combine all yearly data
cat temp* > ComCat_${BUD}.csv
rm temp*.csv
# Zip it UP!
gzip -f ComCat_${BUD}.csv
