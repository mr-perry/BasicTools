#!/bin/bash
#
# Convert HDF Format to format readable by QCreport and QCmulti 
#
# HDF Format yr mon day hr mn sc.ff lat lon dp dpty dpfrominp mag magty 
read -p "Enter File Name:   " file
newfile="reformat.csv"
echo "ID,OT,Lat,Lon,Dep,Mag,MagTy,EvType" > $newfile
#
# Go through file
#
ii=0
while read -r LINE; do
	yr=$(echo $LINE | awk '{print $1}')
	mn=$(echo $LINE | awk '{print $2}')
	if [ ${#mn} -eq "1" ]; then
		mn=0$(echo $mn)
	fi
	dy=$(echo $LINE | awk '{print $3}')
	if [ ${#dy} -eq "1" ]; then
		dy=0$(echo $dy)
	fi
	HH=$(echo $LINE | awk '{print $4}')
	if [ ${#HH} -eq "1" ]; then
		HH=0$(echo $HH)
	fi
	MM=$(echo $LINE | awk '{print $5}')
	if [ ${#MM} -eq "1" ]; then
		MM=0$(echo $MM)
	fi
	SS=$(echo $LINE | awk '{print $6}')
	if [ ${#SS} -eq "4" ]; then
		SS=0$(echo $SS)0
	else
		SS=$(echo $SS)0
	fi
	LAT=$(echo $LINE | awk '{print $7}')
	LON=$(echo $LINE | awk '{print $8}')
	DEP=$(echo $LINE | awk '{print $9}')
	MAG=$(echo $LINE | awk '{print $12}')
	MAGTY=$(echo $MAG | cut -c 4-5)
        MAG=$(echo $MAG | cut -c 1-3)	
	ID=$(echo $LINE | awk '{print tolower($NF)}')
	TYP="earthquake"
	echo $ID,$yr-$mn-$dy $HH:$MM:$SS,$LAT,$LON,$DEP,$MAG,$TYP >> $newfile 
done < $file 
echo Finished
