#!/Users/mrperry/anaconda/bin/python
# This code will create an event count table for ComCat
#
import sys
import datetime as dt
import os
import math
import numpy as np
import urllib2 as urll
import pandas
import smtplib
#
# Declare constants
#
firstYear = 1990
lastYear = 2015 #dt.date.today().year
stepYear = 1
firstMag = 5.0
lastMag = 8.0
stepMag = 0.99999
binsYear = (lastYear - firstYear)+1
sizeYears = binsYear
binsMag = ((lastMag - firstMag)+1);
sizeMags = binsMag*2
sizeCounts = binsYear*binsMag
#
# Contstruct File name
#
TD = dt.date.today()
YR = str(TD.year)
MN = str(TD.month)
DY = str(TD.day)
ED = str('.csv')
fname = YR+MN+DY+ED
#
# Initialize Array Sizes
#
Years = np.arange(sizeYears)
Mags = np.arange(sizeMags).reshape(binsMag,2)
Counts = np.arange(sizeCounts).reshape(binsMag,binsYear)
stringYears = [None]*int(binsYear) 
stringMags = [None]*int(binsMag)
#
# Create year vector 
#
countYear = 0
startYear = firstYear
while ( startYear <= lastYear ):
	Years[countYear] = startYear
	stringYears[countYear] = "%d" % (Years[countYear])
	startYear = startYear + 1
	countYear = countYear + 1
#
# Create Magnitude Vector
#
countMag = 0
startMag = firstMag
while ( startMag <= lastMag ):
	endMag = startMag + stepMag
	if ( endMag > lastMag ):
		endMag = 0
	Mags[countMag,0] = startMag
	Mags[countMag,1] = endMag
	if ( endMag != 0 ):
		stringMags[countMag] = "%d-%1.1f" % (Mags[countMag,0], Mags[countMag,1])
	else:
		stringMags[countMag] = "> %d" % (Mags[countMag,0])
	startMag = startMag + 1
	countMag = countMag + 1
#
# Back counters up by one and flip Mags
#
countMag = countMag - 1
countYear = countYear - 1
Mags = np.flipud(Mags)
stringMags = stringMags[::-1]
#
# Get Counts
#
ii = 0
while ( ii <= countYear ):
	jj = 0 
	while ( jj <= countMag ):
		if ( jj != 0 ):
			print Years[ii], Mags[jj,0], Mags[jj,1]
			query="http://earthquake.usgs.gov/fdsnws/event/1/count?starttime=%d-01-01T00:00:00&endtime=%d-12-31T23:59:59&minmagnitude=%1.1f&maxmagnitude=%1.1f&eventtype=earthquake"\
					% (Years[ii], Years[ii],Mags[jj,0],Mags[jj,1])
#			print query
		else:
			print Years[ii], Mags[jj,0],"inf" 
			query="http://earthquake.usgs.gov/fdsnws/event/1/count?starttime=%d-01-01T00:00:00&endtime=%d-12-31T23:59:59&minmagnitude=%1.1f&eventtype=earthquake"\
					% (Years[ii], Years[ii],Mags[jj,0])
#			print query
		req = urll.Request(query)
		response = urll.urlopen(req)
		the_page = response.read()
		Counts[jj,ii] = int(the_page)
		jj = jj + 1
	ii = ii + 1
#
# Today's Count
np.savetxt(fname,Counts, delimiter=',') # Raw Counts
sys.exit()
