#!/bin/bash
#fname="/Users/mrperry/Documents/CATALOGS/ANSS/AK/ANSS_AK.cnss"
#fname="US.2011.06.cnss"
#fname="AK.1928.02.cnss"
#fname="TEST.cnss"
#fname="TEST_AK.cnss"
#fname="/Users/mrperry/Documents/CATALOGS/ANSS/MB/ANSS_MB.cnss"
fname="/Users/mrperry/Documents/CATALOGS/ANSS/AV/ANSS_AV.cnss"
#
# Get Number of Events
#
newfile="reformat.csv"
echo "ID,OT,Lat,Lon,Dep,Mag,EvType" > $newfile
#
# Step through event list
#
#
# Get Loc and Mag Files
# 
Case1="\$beg"
Case2="\$locP"
Case3="\$loc "
Case4="\$magP"
Case5="\$mag "
Case6="\$end"
ii=0
while read LINE; do	
	line=$(echo $LINE | cut -c 1-5) 
	if [ "$line" = "$Case1" ]; then
		YR=9999
		MN=9999
		DY=9999
		HR=9999
		MM=9999
		SC=9999
		LAT=-9999
		LON=-9999
		DEP=-9999
		MAG=-9999
		ETY=-9999
		ID=-9999
		LOC_SW=0
		MAG_SW=0
	fi
	if [ "$line" = "$Case2" ]  && [ "$LOC_SW" -eq "0" ]; then
		YR=$(echo $LINE | cut -c 6-9)
		if [ -z $(echo $LINE | cut -c 10) ]; then
			MN="0$(echo $LINE | cut -c 11)"
		else
			MN=$(echo $LINE | cut -c 10-11)
		fi
		DY=$(echo $LINE | cut -c 12-13)
		if [ -z $(echo $LINE | cut -c 12) ]; then
			DY="0$(echo $LINE | cut -c 13)"
		else
			DY=$(echo $LINE | cut -c 12-13)
		fi
		if [ -z $(echo $LINE | cut -c 14) ]; then
			HR="0$(echo $LINE | cut -c 15)"
		else
			HR=$(echo $LINE | cut -c 14-15)
		fi
		if [ -z $(echo $LINE | cut -c 16) ]; then
			MM="0$(echo $LINE | cut -c 17)"
		else
			MM=$(echo $LINE | cut -c 16-17)
		fi
		if [ -z $(echo $LINE | cut -c 18) ]; then
			SC="0$(echo $LINE | cut -c 19-23)"
		else
			SC=$(echo $LINE | cut -c 18-23)
		fi
		LAT=$(echo $LINE | cut -c 25-33)
		LON=$(echo $LINE | cut -c 34-43)
		DEP=$(echo $LINE | cut -c 44-50)
		LOC_SW=1
	fi
	if [ "$line" = "$Case3" ] && [ "$LOC_SW" -eq "0" ]; then
                YR=$(echo $LINE | cut -c 6-9)
		if [ -z $(echo $LINE | cut -c 10) ]; then
			MN="0$(echo $LINE | cut -c 11)"
		else
			MN=$(echo $LINE | cut -c 10-11)
		fi 
		if [ -z $(echo $LINE | cut -c 12) ]; then
			DY="0$(echo $LINE | cut -c 13)"
		else
			DY=$(echo $LINE | cut -c 12-13)
		fi
		if [ -z $(echo $LINE | cut -c 14) ]; then
			HR="0$(echo $LINE | cut -c 15)"
		else
			HR=$(echo $LINE | cut -c 14-15)
		fi
		if [ -z $(echo $LINE | cut -c 16) ]; then
			MM="0$(echo $LINE | cut -c 17)"
		else
			MM=$(echo $LINE | cut -c 16-17)
		fi
		if [ -z $(echo $LINE | cut -c 18) ]; then
			SC="0$(echo $LINE | cut -c 19-23)"
		else
			SC=$(echo $LINE | cut -c 18-23)
		fi
                LAT=$(echo $LINE | cut -c 25-33)
                LON=$(echo $LINE | cut -c 34-43)
                DEP=$(echo $LINE | cut -c 44-50)
	fi
	if [ "$line" = "$Case4" ] && [ "$MAG_SW" -eq "0" ]; then
		MAG=$(echo $LINE | cut -c 6-10)
		MTY=$(echo $LINE | cut -c 11-12)
		ETY="earthquake"
		MAG_SW=1
	fi
	if [ "$line" = "$Case5" ] && [ "$MAG_SW" -eq "0" ]; then
		MAG=$(echo $LINE | cut -c 6-10)
		MTY=$(echo $LINE | cut -c 11-12)
		ETY="earthquake"
	fi
	if [ "$line" = "$Case6" ]; then
		let ii=ii+1
		echo "$ii,$YR-$MN-$DY $HR:$MM:$SC,$LAT,$LON,$DEP,$MAG,$ETY" >> $newfile
	fi
done < $fname
