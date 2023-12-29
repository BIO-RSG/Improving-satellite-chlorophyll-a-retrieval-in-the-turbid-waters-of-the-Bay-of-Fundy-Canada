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
bash ./l2gen_swir_mumm.sh $l1aname;
done

#### L2 NASA flags, q/c and calculate Chl-a, SPM, etc: ####
echo "FLAGGING AND CALCULATING CHL-A"
for l2name in A*.L2_SWIR; do
python ./02_filter_computespm.py ${l2name};
done

#### Grid file in GMT at 300 m resolution ####
echo "GRIDDING"

for ascname in *L2_SWIR.asc; do
echo $ascname;
gmt xyz2grd $ascname -G${ascname:0:-6}spmhan.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -Vn -fg;
# gmt xyz2grd -i,0,1,3 $ascname -G${ascname:0:-4}spmdox.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -Vn;
# gmt xyz2grd -i,0,1,4 $ascname -G${ascname:0:-6}chloci.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,10 $ascname -G${ascname:0:-6}spmnec.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,11 $ascname -G${ascname:0:-6}chloc3.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,12 $ascname -G${ascname:0:-6}rrs443.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,13 $ascname -G${ascname:0:-6}rrs488.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,14 $ascname -G${ascname:0:-6}rrs547.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,15 $ascname -G${ascname:0:-6}rrs667.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,16 $ascname -G${ascname:0:-6}chloc3m1.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
# gmt xyz2grd -i,0,1,17 $ascname -G${ascname:0:-6}chloc3m2.grd -I300e -R/$lonmin/$lonmax/$latmin/$latmax -V -fg;
done

for i in {2003..2021}; do

cd $i;

Rscript ../../Make_daily_composites_modisa.R spmhan 
Rscript ../../Make_daily_composites_modisa.R kdlee

cd ../

done

#### Make daily composites from L2 GRD files: ####
Rscript ./00_MakeDailyComposites_MODISA.R spmhan 
Rscript ./00_MakeDailyComposites_MODISA.R spmdox 
Rscript ./00_MakeDailyComposites_MODISA.R chloc3 
Rscript ./00_MakeDailyComposites_MODISA.R chloci 
Rscript ./00_MakeDailyComposites_MODISA.R chloc3m1 
Rscript ./00_MakeDailyComposites_MODISA.R chloc3m2 

rm gmt.conf
rm gmt.history
rm spm.cpt