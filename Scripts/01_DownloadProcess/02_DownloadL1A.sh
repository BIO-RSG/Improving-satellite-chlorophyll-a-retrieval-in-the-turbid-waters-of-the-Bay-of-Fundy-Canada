#!/bin/bash

# Downloading L1A files for a given year 
# Get the list of files that have enough coverage:

l2imgfolder=./
for i in {2003..2021}; do
ls $l2imgfolder$i/A*L2_LAC_OC.nc | xargs -n 1 basename > BF_${i}_L1A.txt;
done

#############
inputfile="BF_*_L1A.txt"
#############
while read line
do
  echo "$line"
  urlname=$line
  namestring=`echo "$urlname" | grep -oP "A[0-9]{13}"`
  filename="${namestring}.L1A_LAC"
  
  wget -q --show-progress --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/${filename}.bz2
  bunzip2 ${filename}.bz2
  
done < "$inputfile"