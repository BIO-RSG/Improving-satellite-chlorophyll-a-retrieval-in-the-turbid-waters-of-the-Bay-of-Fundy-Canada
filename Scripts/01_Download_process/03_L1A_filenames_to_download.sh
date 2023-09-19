# Following on 02_download_l2.sh

# Once all those have successfully run, to get the list of files that have enough coverage:

l2imgfolder=/home/hilborna/disk2/FUNDY_2021/MODISA/L2/
for i in {2003..2021}; do
ls $l2imgfolder$i/A*L2_LAC_OC.nc | xargs -n 1 basename > BF_${i}_L1A.txt;
done

mkdir 03_l1a_files
mv BF*L1A.txt 03_l1a_files

# Note that these still have the L2 filename, but that is accounted for in the L1A download script :)