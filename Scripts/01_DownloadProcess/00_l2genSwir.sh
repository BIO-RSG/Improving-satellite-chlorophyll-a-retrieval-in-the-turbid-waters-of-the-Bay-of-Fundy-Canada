#!/bin/bash

# Processing params for L1A files using the SWIR atmospheric correction
# THIS IS RUN FROM ANOTHER FILE

# Filename is input on the command line, e.g.:
# bash 00_l2genSwir.sh A2018161180500.L1A_LAC
filename=$1
echo $filename

###### Region:
lonmax_lg=-63.1
lonmin_lg=-68.8
latmax_lg=46.2 #was 46.25??
latmin_lg=43.1
######

# Define the names of various files created
namestring=`echo "$filename" | grep -oP "A[0-9]{13}"`
geoname=${filename:0:15}GEO
l1bname=${filename:0:15}L1B_LAC
l1b_qkm=${filename:0:15}L1B_QKM
l1b_hkm=${filename:0:15}L1B_HKM
l2swir=${filename:0:15}L2_SWIR
  
echo $namestring

# Process to GEO and L1B
echo "Create Geolocation file"
#modis_GEO.py -d -v $filename
modis_GEO -d $filename
echo "Create L1B file"
modis_L1B $filename
echo "Get ancillary data"
getanc $filename

echo "----------------------------"

# Process to L2 using NIR-SWIR switching correction
# the MUMM option was tested, which has the following mods:
# echo "aer_opt=-10" >> L1_to_L2.par

echo "ifile=${l1bname}" > L1_to_L2.par
echo "geofile=${geoname}" >> L1_to_L2.par
echo "ofile1=${l2swir}" >> L1_to_L2.par
echo "l2prod1=chlor_a,chl_gsm,sst,solz,senz,par,Kd_490,Kd_488_lee,l2_flags,Rrs_412,Rrs_443,Rrs_469,Rrs_488,Rrs_531,Rrs_547,Rrs_555,Rrs_645,Rrs_667,Rrs_678,Rrs_748,Rrs_859,Rrs_869,Rrs_1240,Rrs_1640,Rrs_2130" >> L1_to_L2.par
echo "atmocor=1" >> L1_to_L2.par
echo "aer_opt=-9" >> L1_to_L2.par
echo "north=${latmax_lg}" >> L1_to_L2.par # added
echo "south=${latmin_lg}" >> L1_to_L2.par # added
echo "east=${lonmax_lg}" >> L1_to_L2.par # added
echo "west=${lonmin_lg}" >> L1_to_L2.par # added
echo "brdf_opt=0" >> L1_to_L2.par
echo "outband_opt=0" >> L1_to_L2.par
echo "aer_wave_short=748" >> L1_to_L2.par
echo "aer_wave_long=869" >> L1_to_L2.par
echo "aer_swir_short=1240" >> L1_to_L2.par
echo "aer_swir_long=2130" >> L1_to_L2.par
echo "gas_opt=15" >> L1_to_L2.par
echo "resolution=250" >> L1_to_L2.par
echo "proc_sst=1" >> L1_to_L2.par
echo "maskland=1" >> L1_to_L2.par
echo "maskbath=0" >> L1_to_L2.par
echo "maskcloud=1" >> L1_to_L2.par
echo "maskglint=0" >> L1_to_L2.par
echo "masksunzen=0" >> L1_to_L2.par
echo "masksatzen=0" >> L1_to_L2.par
echo "maskhilt=1" >> L1_to_L2.par
echo "maskstlight=0" >> L1_to_L2.par
echo "albedo=0.027" >> L1_to_L2.par

# Run l2gen from par file
l2gen par="L1_to_L2.par"

# Uncomment to remove files created during the process that take up space 
# rm $geoname
# rm $l1bname
# rm $l1b_hkm
# rm $l1b_qkm 
