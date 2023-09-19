#!/bin/bash

# Downloading L1A files for a given year to get them ready for processing
#############
inputfile="BF_2018_L1A.txt"
#############
while read line
do
  echo "$line"
  urlname=$line
  #TEST FILE: #urlname="https://oceandata.sci.gsfc.nasa.gov/cmr/getfile/A2003039204500.L2_LAC_OC.nc"
  namestring=`echo "$urlname" | grep -oP "A[0-9]{13}"`
  filename="${namestring}.L1A_LAC"
  
  wget -q --show-progress --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/${filename}.bz2
  bunzip2 ${filename}.bz2
  
done < "$inputfile"