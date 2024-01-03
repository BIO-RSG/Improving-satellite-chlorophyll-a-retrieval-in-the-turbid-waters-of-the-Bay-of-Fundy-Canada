#!/bin/bash

# Download L2 files from lists retrieved from NASA site
# Test for coverage in study area and save in text file. Also saves list of files to download.
# Deletes file if lower than 5% coverage in study region (of what is in the L2 image)
# This was done as a time-saving step as many L1As have no valid data but a long time to download and process

d=$(date +%Y-%m-%d_%H%M)

# Full study region
lonmax_lg=-63.1
lonmin_lg=-68.8
latmax_lg=46.2
latmin_lg=43.1

# Loop through the yearly lists of L2 files and retrieve coverage from smaller and larger areas 
for i in BF_*_download_l2.csv ; # Specify individual file, or all 
do
  echo $i
  iname=`echo "$i" | grep -oP "BF_[0-9]{4}"`
  
  # Empty file to store good URL list in ####
  resultsfile="${iname}_${d}_DOWNLOAD_LIST.csv"
  touch $resultsfile
  
  # Make .csv to save coverage info in
  echo "$d"
  echo "URL, Imgname, Npixl" > "${iname}_${d}_Img_coverage.csv"

  while IFS=$' %0D' read -r line
  do
    echo "$line"
    filename=$line
    imgname=`echo "$filename" | grep -oP "A[0-9]{13}"`
    wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition https://oceandata.sci.gsfc.nasa.gov/cmr/getfile/${imgname}.L2_LAC_OC.nc # -O $imgname.L2_LAC_OC.nc
    
    year=${imgname:1:4}
    day=${imgname:5:3}
    granule=${imgname:8:6}
    
    Rscript 00_Check_nb_pixel_in_image.R ${imgname}.L2_LAC_OC.nc $lonmax_lg $lonmin_lg $latmax_lg $latmin_lg
    
    # read -r nbvalpix < nbvalpxl.asc
    nbvalpix=$(head -1 nbvalpxl.asc)
    nbpixtot=$(head -2 nbvalpxl.asc | tail -1)
    perccov=$(head -3 nbvalpxl.asc | tail -1)
    
    echo "$filename, $imgname, $nbvalpix, $nbpixtot, $perccov" >> "${iname}_${d}_Img_coverage.csv"
    
    rm nbvalpxl.asc
    echo $perccov
    
    cov_test=$(echo $perccov'>'5.0 | bc -l)
    if [ $cov_test == 1 ]; then
      echo "$filename" >> $resultsfile
      mv ${imgname}.L2_LAC_OC.nc ./L2
    else
      echo "--NOT ENOUGH PIXELS IN NASA IMAGE, <= 5%--"
      rm ${imgname}.L2_LAC_OC.nc
    fi
    nbvalpix=""
    nbpixtot=""
    perccov=""
    
  done < "$i"
done
