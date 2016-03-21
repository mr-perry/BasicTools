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
# Last Edit: 17 March 2016                                 #
#                                                          #
############################################################
clear
#
# Get File Name
#
read -p "Enter File Name:  " file
echo Getting Event IDs
awk -v F1="$file" -F "\"*,\"*" '{print $12}' "${file}" > EventId.csv
echo Pulling information from server
for event in $(<EventId.csv)
do
	OP=$(curl -s -I "http://earthquake.usgs.gov/earthquakes/eventpage/${event}" | grep HTTP)
	if [ -z "$OP" ]; then
		OP=BLANK
	fi
	echo $event $OP  >> TMP.txt
done
echo Parsing according to status message
grep "Moved Permanently" TMP.txt | awk '{print $1}' > NonAuthoritative_output.txt
grep "200 OK" TMP.txt | awk '{print $1}'  > Authoritative_output.txt
grep "Service Unavailable" TMP.txt | awk '{print $1}' > ServiceUA_output.txt
grep "BLANK" TMP.txt | awk '{print $1}' >> ServiceUA_output.txt
echo Rerunning Service Unavailable Events
UAfile=ServiceUA_output.txt
while [ -s "$UAfile" ]
do
	for UA in $(<ServiceUA_output.txt)
	do
		UA_OP=$(curl -s -I "http://earthquake.usgs.gov/earthquakes/eventpage/${UA}" | grep HTTP)
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
done
rm ServiceUA_output.txt
# Concatenate Output
cat NonAuthoritative_output.txt NonAuthoritative_output2.txt > NA_output.txt
cat Authoritative_output.txt Authoritative_output2.txt > A_output.txt
rm NonAuthoritative_output.txt NonAuthoritative_output2.txt Authoritative_output.txt Authoritative_output2.txt > DEBUG
rm DEBUG
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
# Remove New line characters
sed 's///' NAtmp.txt > NA.txt
sed 's///' Atmp.txt > A.txt
rm NAtmp.txt Atmp.txt NA_output.txt A_output.txt 
mv TMP.txt curl_OP.txt
wc -l NA.txt
wc -l A.txt
wc -l EventId.csv
mkdir OUTPUT
mv NA.txt ./OUTPUT/.
mv A.txt ./OUTPUT/.
mv curl_OP.txt ./OUTPUT/.
mv EventId.csv ./OUTPUT/.
echo done

