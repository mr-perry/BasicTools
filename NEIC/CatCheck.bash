#!/bin/bash
############################################################
#                                                          #
# Authoritative Event Catalog Check                        #
#                                                          #
# This script checks whether or not events redirect to     #
# another event page.  The input file must be in ComCat    #
# format.  There is another script if the input is in      #
# LibComCat format.                                        #
#                                                          #
# Input can be obtained by downloading from the ComCat Web #
# search, or using the getData.bash script found in this   #
# directory.  If the input was obtained using LibComCat    #
# LibCatStat must be used                                  #
#                                                          # 
# Outputs:                                                 # 
# NA.txt - Non-authoritative events                        #
# A.txt - Authoritative events                             #
# curl_OP.txt - Original output from curl                  #
# EventId.csv - List of event IDs processed                #
#                                                          #
# Written by: Matthew R. Perry                             #
# Last Edit: 03 November 2016                              #
#                                                          #
############################################################
clear
#
# Get File Name
#
read -p "Enter File Name:  " file
read -p "Enter Catalog Format [1 for ComCat (EventID in Column 12), 2 for LibComCat (EventID in Column 1)]:  " format
read -p "Enter Host to Check(0-ComCat, 1-Prod01, 2-Prod02):  " SY
if [ $SY -eq 1 ]; then
	SERV=prod01
elif [ $SY -eq 2 ]; then
	SERV=prod02
fi
#
# Parse Event IDs
#
echo Getting Event IDs
if [ $format -eq 1 ]; then
	awk -v F1="$file" -F "\"*,\"*" '{print $12}' "${file}" > EventId.csv
elif [ $format -eq 2 ]; then
	awk -v F1="$file" -F "\"*,\"*" '{print $1}' "${file}" > EventId.csv
elif [ $format -eq 3 ]; then
	echo "EventIDs already parsed"
	mv $file EventId.csv
else
	echo "Format Not Recognized"
fi
#
# Getting information from Server
#
echo Pulling information from server
for event in $(<EventId.csv)
do
	if [ $SY -eq 1 ] || [ $SY -eq 2 ]; then
		OP=$(curl -s -I "http://${SERV}-earthquake.cr.usgs.gov/earthquakes/eventpage/${event}" | grep HTTP)
	else
		OP=$(curl -s -I "http://earthquake.usgs.gov/earthquakes/eventpage/${event}" | grep HTTP)
	fi
	if [ -z "$OP" ]; then
		OP=BLANK
	fi
	echo $event $OP  >> TMP.txt
done
echo Parsing according to status message
#
# Moved Permanently means the event is not authoritative
#
grep "Moved Permanently" TMP.txt | awk '{print $1}' > NonAuthoritative_output.txt
#
# 200 OK means the event IS authoritative
#
grep "200 OK" TMP.txt | awk '{print $1}'  > Authoritative_output.txt
#
# Service Unavailable means the server timed out
#
grep "Service Unavailable" TMP.txt | awk '{print $1}' > ServiceUA_output.txt
#
# Black is sort of the same as Service Unavailable
#
grep "BLANK" TMP.txt | awk '{print $1}' >> ServiceUA_output.txt
#
# Rerun those events that timed-out
#
UA=0
UAfile=ServiceUA_output.txt
while [ -s "$UAfile" ]
do
	echo Rerunning Service Unavailable Events
	for UA in $(<ServiceUA_output.txt)
	do
		if [ $SY -eq 1 ] || [ $SY -eq 2 ]; then
			UA_OP=$(curl -s -I "http://${SERV}.earthquake.cr.usgs.gov/earthquakes/eventpage/${UA}" | grep HTTP)
		else
			UA_OP=$(curl -s -I "http://earthquake.usgs.gov/earthquakes/eventpage/${UA}" | grep HTTP)
		fi
		if [ -z "$UA_OP" ]; then
			UA_OP=BLANK
		fi
		echo $UA $UA_OP >> SUA_OP.txt
	done
	rm ServiceUA_output.txt
	grep "Moved Permanently" SUA_OP.txt | awk '{print $1}' >> NonAuthoritative_output2.txt
	grep "200 OK" SUA_OP.txt | awk '{print $1}'  >> Authoritative_output2.txt
	grep "Service Unavailable" SUA_OP.txt | awk '{print $1}' >> ServiceUA_output.txt
	grep "BLANK" SUA_OP.txt | awk '{print $1}' >> ServiceUA_output.txt
	rm SUA_OP.txt
	UA=1
done
rm ServiceUA_output.txt
#
# Concatenate Output
#
if [ $UA -eq 1 ]; then
	cat NonAuthoritative_output.txt NonAuthoritative_output2.txt > NA_output.txt
	cat Authoritative_output.txt Authoritative_output2.txt > A_output.txt
	rm NonAuthoritative_output.txt NonAuthoritative_output2.txt Authoritative_output.txt Authoritative_output2.txt
else
	cat NonAuthoritative_output.txt > NA_output.txt
	cat Authoritative_output.txt > A_output.txt
	rm NonAuthoritative_output.txt Authoritative_output.txt
fi
#
# Format the Output Files
#
echo Formatting Output Files
for NA in $(<NA_output.txt)
do
	NAU=$(curl -s -I "http://earthquake.usgs.gov/earthquakes/eventpage/${NA}" | grep Location: | awk '{print $2}' | awk -F "\"*/\"*" '{print $4}')
	NAU_OT=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $1}')
	NAU_LT=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $2}')
	NAU_LN=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $3}')
	NAU_DP=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $4}')
	NAU_MG=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $5}')
#	NAU_ET=$(grep -w ${NA} ${file} | awk -F "\"*,\"*" '{print $15}')
	echo $NA,$NAU_OT,$NAU_LT,$NAU_LN,$NAU_DP,$NAU_MG,earthquake,$NAU,Associated,Yes >> NAtmp.txt
done
# Fill outputs
for A in $(<A_output.txt)
do
	AU_OT=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $1}')
	AU_LT=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $2}')
	AU_LN=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $3}')
	AU_DP=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $4}')
	AU_MG=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $5}')
#	AU_ET=$(grep -w ${A} ${file} | awk -F "\"*,\"*" '{print $15}')
	echo $A,$AU_OT, $AU_LT, $AU_LN, $AU_DP, $AU_MG, earthquake >> Atmp.txt
done
#
# Remove New line characters
#
if [ -f NAtmp.txt ]; then
	sed 's///' NAtmp.txt > NA.txt
	rm NAtmp.txt
fi
if [ -f Atmp.txt ]; then
	sed 's///' Atmp.txt > A.txt
	rm Atmp.txt
fi
#
# Remove temporary files
#
rm NA_output.txt A_output.txt 
#
# Rename TMP.txt to the original output of curl
#
mv TMP.txt curl_OP.txt
#
# Print the line count
#
if [ -f NA.txt ];then
	NA_Count=$(wc -l NA.txt | awk '{print $1}')
else
	NA_Count=0
fi
if [ -f A.txt ];then
	A_Count=$(wc -l A.txt | awk '{print $1}')
else
	A_Count=0
fi
Event_Count=$(wc -l EventId.csv | awk '{print $1}')
echo "$Event_Count events were analyzed"
echo "There are $NA_Count non-authoritative events"
echo "There are $A_Count authoritative events"
#
# Move all files to OUTPUT Director
#
mkdir OUTPUT
mv curl_OP.txt ./OUTPUT/.
mv EventId.csv ./OUTPUT/.
if [ -f NA.txt ]; then
	mv NA.txt ./OUTPUT/.
fi
if [ -f A.txt ]; then
	mv A.txt ./OUTPUT/.
fi
echo done
