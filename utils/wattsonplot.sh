#!/bin/sh
# Shell script that takes a logwattson log file and 
# creates a set of PNG files with a date-time vs. power plot. 
# Parameters
# - Name of log file (compulsory)
# - Name of 1st PNG file to create (compulsory) (for col 4 data)
# - Name of 2nd PNG file to create (compulsory) (for col 5 data)
# - Name of 3rd PNG file to create (compulsory) (for difference between col4 and col 5 data)
# (obsoleted)- Number of rows to include from the end of the file (optional; default is 8640)
# The 'ploticus' package is required for this script to work 
# (do 'sudo apt-get ploticus' or similar if needed). 
#
# Author: Kary Främling, 2010
#         Alan Wood, 2015
#

# Verify that we have at least four command line parameters.
if [ $# -lt 4 ]; then
	echo "Usage: ./wattsonplot logfile gen_pngfile solar_pngfile diff_pngfile {date to plot}"
	exit 0
fi

tmpdir=`/usr/local/bin/getconf temp`
if [ $# -lt 5 ]; then 
  Yest=`date +%Y-%b-%d --date=yesterday`
else
  Yest=$5
fi
All_Yest="${Yest}.00:00:00 ${Yest}.23:59:59"

# Set variable accordingly
logfile=$1
pngfile=$2
pngfile2=$3
pngfile3=$4
#if [ $# -eq 5 ]; then
#	nrows=$5
#else
#	nrows=15000
#	#nrows=8640
#fi

# Do the job
echo "Time Used Generated Grid_Given" > $tmpdir/wattsonplot.tmp
cat $logfile | awk '{ split($0, arr);print arr[2] "." arr[3] " " arr[4] " " arr[5] " " arr[5]-arr[4];}' >> $tmpdir/wattsonplot.tmp

ploticus -png -o $pngfile -pagesize 11.6,8.2 -pixsize 1024,768 -prefab chron data=$tmpdir/wattsonplot.tmp x=1 y=2 datefmt=yyyy-mmm-dd mode=line unittype=datetime rectangle="1 1 10 8" xrange="$All_Yest" ygrid=yes header=yes x=Time y=Used
ploticus -png -o $pngfile2 -pagesize 11.6,8.2 -pixsize 1024,768 -prefab chron data=$tmpdir/wattsonplot.tmp x=1 y=2 datefmt=yyyy-mmm-dd mode=line unittype=datetime rectangle="1 1 10 8" xrange="$All_Yest" ygrid=yes header=yes x=Time y=Generated
ploticus -png -o $pngfile3 -pagesize 11.6,8.2 -pixsize 1024,768 -prefab chron data=$tmpdir/wattsonplot.tmp x=1 y=2 datefmt=yyyy-mmm-dd mode=line unittype=datetime rectangle="1 1 10 8" xrange="$All_Yest" ygrid=yes header=yes x=Time y=Grid_Given
