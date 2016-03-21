#!/bin/bash
read -p "Enter catalog:   " CT
read -p "Enter Start year:  " YR
read -p "Enter End year:  " En_YR
P1=$(curl -s "http://prod01-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
P2=$(curl -s "http://prod02-earthquake.cr.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
CC=$(curl -s "http://earthquake.usgs.gov/fdsnws/event/1/count?starttime=${YR}-01-01T00:00:00&endtime=${En_YR}-12-31T23:59:59&catalog=${CT}")
echo Catalog, $CT
echo Years, $YR-$En_YR
echo ComCat, $CC
echo Prod-01, $P1
echo Prod-02, $P2
