#!/bin/sh
#
# Shell script that runs logwattson every 5 seconds in an eternal loop. 
# This script assumes that the logwattson executable is located in the 
# parent directory. If you have run 'make install' or otherwise added 
# logwattson to your path, then remove the '../' part.
# If you run this script at system startup, then you probably need to 
# include the absolute path to 'logwattson', as well as the absolute 
# path for the file where you want to store the data. 
#
# Author: Kary Främling, 2010
#
#LogBase="/home/nas/wattson/wattson/wattson_log"
LogBase=`/usr/local/bin/getconf logdir`
LogBase="${LogBase}/wattson_log"
while [ 1 ]
do
  today=`date +%Y_%m_%d_%A`
  #/usr/local/bin/logwattson $LogBase-$today.txt &
  /usr/local/bin/mysqllogwattson &
  sleep 10
done

