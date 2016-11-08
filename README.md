# BasicTools
## ArchiveComCat
_Backup.bash_ -- Overall script that runs the Archive scripts \n
_ArchiveComCat.bash_ -- Hypocenter and magnitude back-up of Authoritative ComCat
_ArchiveGlobal.bash_ -- Hypocenter and magnitude back-up of Global Catalogs
_ArchiveRegional.bash_ -- Hypocenter and magnitude back-up of Regional Catalogs
## Converters:
_CNSSReformat.bash_ -- Convert CNSS formatted data to CSV file usable by CatStat
_CNSSReformatv2.bash_ -- Take CNSS formatted data and converts to CSV file readable by CatStat. Looks for preferred hypocenter and magnitude for each entry
_HDFreformat.bash_ -- Convert HDF Format to format readable by CatStat
_ISCtoCSV.bash_ -- ISC to CSV converter which contains both hypocentral and phase pick information CSVs easily read by MATLAB and other programs.
_MLOCtoCSV.bash_ -- MLOC to CSV file converter that returns both hypocenter file and associate phase pick files.
_NORDICtoCSV.bash_ -- Script for converting SEISAN NORDIC formatted files into hypocenter and phase pick CSV files easily read by MATLAB and other programs.
_SUMtoCSV.bash_ -- Convert Hypocenter ARC SUM catalog to CSV formatted file readable by CatStat.  PLEASE REFER TO THE NOTES IN HEADER FOR IMPORTANT INFORMATION.
## Other Tools
_CatCheck.bash_ -- Script that checks whether or not events redirect to other event pages.
_GetDYFIID.py_ -- Python script that reads a list of EventIDs and produces a list of DYFI? IDs associated with EventIDs.
_GetEventID.bash_ -- Script that parses either ComCat or LibComCat query result files for EventIDs
_GetQuakeML.bash_ -- Given a file containing a list of EventIDs, download associated QuakeML files.
_PullEventID.bash_ -- Given an input file of origin times and locations, return a list of potential Event IDs associated with each event.  Requires additional QA/QC after to determine correct event list.
_getCount.bash_ -- Get event counts
_getCounts.py_ -- This python script will create an event count table based on information under "Declare Constants."  This script forms the basis for autoComCatQC.
_getData.bash_ -- Download data from ComCat.  This is quicker than getcsv.py but has less bells and whistles.  Able to download from specific production or dev servers.
_getPhaseData.bash_ -- Same as getData but downloads phase data instead.
