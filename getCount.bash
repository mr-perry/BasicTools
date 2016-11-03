#!/bin/bash
#
# Get counts!!!!
#
read -p "Enter catalog:   " CT
read -p "Enter Start year:  " YR
read -p "Enter End year:  " En_YR
P1=$(curl -s "http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
P2=$(curl -s "http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
D1=$(curl -s "http://dev01-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
D2=$(curl -s "http://dev02-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
echo Catalog, $CT
echo Years, $YR-$En_YR
echo Prod-01, $P1
echo Prod-02, $P2
echo Dev-01, $D1
echo Dev-02, $D2
