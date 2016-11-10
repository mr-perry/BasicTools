#!/bin/bash
#
# Given a file with a list of EventIDs, download associated QuakeMLs
#
read -p "Input File:   " file
for event in $(<$file)
do
	wget http://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/$event.xml -nv
done
