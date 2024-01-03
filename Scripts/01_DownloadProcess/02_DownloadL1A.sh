#!/bin/bash

# Downloading L1A files for a given year 

#!/bin/bash

# Download files from lists retrieved from NASA CMR site
# Test for coverage in study area and save in text file. Also saves list of files to download.
# Deletes file if lower than 5% coverage in study region (of what is in the L2 image)
# This was done as a time-saving step as many L1As have no valid data but a long time to download and process

d=$(date +%Y-%m-%d_%H%M)

# Full study region
lonmax_lg=-63.1
lonmin_lg=-68.8
latmax_lg=46.2
latmin_lg=43.1

for i in BF_*_download_L1A.csv ; # Specify individual file, or all 
do
  echo $i
  iname=`echo "$i" | grep -oP "BF_[0-9]{4}"`
  
  while IFS=$' %0D' read -r line
  do
    echo "$line"
    urlname=$line
    imgname=`echo "$filename" | grep -oP "A[0-9]{13}"`
    wget -q --show-progress --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition $urlname
  # bunzip2 ${filename}.bz2
  done < "$i"
done

  