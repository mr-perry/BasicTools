#!/bin/bash
#
# Same as getData but pulls off local DEV API
#
read -p "Enter catalog:   " CT
read -p "Enter Start year:  " St_Yr
read -p "Enter End year:   " En_Yr
read -p "Enter system [0 - Prod, 1 - Prod1, 2 - Prod2, 3 - Dev, 4 - Dev1, 5 - Dev2]:   " SY
if [ $SY -eq 1 ]; then
	SERV=prod01
elif [ $SY -eq 2 ]; then
	SERV=prod02
elif [ $SY -eq 3 ]; then
	SERV=dev
elif [ $SY -eq 4 ]; then
	SERV=dev01
elif [ $SY -eq 5 ]; then
	SERV=dev02
fi
YR=$St_Yr
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
			if [ $SY -eq 0 ]; then
               			curl -s "http://localhost:9062/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time-asc" > ${fname}
			else
				curl -s "http://http://localhost:9062/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&orderby=time-asc" > ${fname}
			fi
		else
			fname=$(echo ${CT}${ii}.csv)
			if [ $SY -eq 0 ]; then
               			curl -s "http://localhost:9062/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time-asc" > ${fname}
			else
				curl -s "http://localhost:9062/fdsnws/event/1/query.csv?starttime=${YR}-${ii}-1%2000:00:00&endtime=${YR}-${ii}-${ed}%2023:59:59&catalog=${CT}&orderby=time-asc" > ${fname}
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
	cat ${CT}1.csv ${CT}2.csv ${CT}3.csv ${CT}4.csv ${CT}5.csv ${CT}6.csv ${CT}7.csv ${CT}8.csv ${CT}9.csv ${CT}10.csv ${CT}11.csv ${CT}12.csv > ${CT}${YR}.csv
	rm *.csv-e
	mv ${CT}${YR}.csv ../.
	let YR=YR+1
	cd $home_dir
done
YR=$St_Yr
while [[ $YR -le $En_Yr ]]
do
	if [[ $YR -ne $St_Yr ]]; then
		tail -n +2 ${CT}${YR}.csv > cut_${CT}${YR}.csv
	else
		cp ${CT}${YR}.csv cut_${CT}${YR}.csv
	fi
	let YR=YR+1
done
if [ -z "$CT" ]; then
	cat cut_* > data.csv
else
	cat cut_* > ${CT}.csv
fi
rm -rf 19*
rm -rf 20*
rm -rf cut_*
