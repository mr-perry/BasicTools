#!/usr/bin/env python
#
# Import necessary Libraries
#
import os
import urllib2 as request
import json
import csv
#
# Define Main Function
#
def main():
	fname = raw_input('Enter a filename: ')
	if os.path.isfile(fname):
		BASE = 'http://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&eventid=%s'
		DYFIID = [];
		with open(fname) as f:
			content = f.readlines()
		for ii in range(len(content)):
			content[ii] = content[ii][:-1]
			url = BASE % (content[ii])
			fh = request.urlopen(url)
			data = fh.read().decode('utf-8')
			fh.close()
			jdict = json.loads(data)
			DYFIID.append(jdict['properties']['products']['dyfi'][0]['code'])
		with open('DYFI.id','wb') as csvfile:
			spamwriter = csv.writer(csvfile,delimiter=',',quotechar='|', quoting=csv.QUOTE_MINIMAL)
			for ii in range(len(DYFIID)):
				spamwriter.writerow((content[ii],DYFIID[ii]))
	else:
		print('File Not Found')

if __name__ == "__main__":
	main()

