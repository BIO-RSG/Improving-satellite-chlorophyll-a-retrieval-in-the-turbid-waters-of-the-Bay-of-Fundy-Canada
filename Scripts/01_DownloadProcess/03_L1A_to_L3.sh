#!/bin/bash
# Process L2 to daily composites

# IF YOU GET THIS ERROR:
# $'\r': command not found
# ... DO THIS TO THE .SH SCRIPT MISBEHAVING:
# vi -b filename
# esc
# :%s/\r$//
# :x
# Or use dos2unix

###### Bounding box
lonmax=-63.1
lonmin=-68.8
latmax=46.2
latmin=43.1
######

##### Process images to L2: ####
echo "RUNNING NIR-SWIR CORRECTION"
for l1aname in A*L1A_LAC; do
bash ./00_l2genSwir.sh $l1aname;
done

# rm *.anc # Uncomment to remove ancillary data

#### L2 NASA flags, q/c and calculate Chl-a, SPM, etc: ####
echo "FLAGGING AND CALCULATING CHL-A"
for l2name in A*.L2_SWIR; do
python ./00_Filter_ComputeProducts.py ${l2name};
done

#### Grid file in GMT at 300 m resolution ####
echo "GRIDDING"

for ascname in *L2_SWIR.asc; do
echo $ascname;
# gmt xyz2grd -i,0,1,2 $ascname -G${ascname:0:-4}spmhan.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,4 $ascname -G${ascname:0:-4}chloci.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
gmt xyz2grd -i,0,1,5 $ascname -G${ascname:0:-4}spmnec.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
gmt xyz2grd -i,0,1,6 $ascname -G${ascname:0:-4}chloc3.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,7 $ascname -G${ascname:0:-4}rrs443.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,8 $ascname -G${ascname:0:-4}rrs488.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,9 $ascname -G${ascname:0:-4}rrs547.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,10 $ascname -G${ascname:0:-4}rrs667.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,11 $ascname -G${ascname:0:-4}chloc3m1.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
gmt xyz2grd -i,0,1,12 $ascname -G${ascname:0:-4}chloc3m2.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
      
done


#### Make daily composites from L2 GRD files: ####
mkdir -p Daily_Composites

Rscript ./00_MakeDailyComposites_MODISA.R spmnec
Rscript ./00_MakeDailyComposites_MODISA.R chloc3
Rscript ./00_MakeDailyComposites_MODISA.R chloc3m2 #this is OCX-SPMCOR

mv A???????_*grd ./Daily_Composites

# Clean up a bit
rm gmt.conf
rm gmt.history
rm spm.cpt