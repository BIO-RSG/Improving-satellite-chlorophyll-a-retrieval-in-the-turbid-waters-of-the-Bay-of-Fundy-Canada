#! /usr/bin/env python
# Emmanuel Devred, 2019
# Modified by Andrea Hilborn Feb. 2020
# Modified January 2023: adding 443, 488, 555, and 667 bands to output

from numpy import *
import sys, os

sys.dont_write_bytecode = True

import numpy as np
from netCDF4 import Dataset
np.warnings.filterwarnings('ignore')

def main(*args):
  
  #### Define L2 flags and other q/c ####
  l2_flags_to_use = ["LAND","HISATZEN","HISOLZEN","CLDICE","HILT","STRAYLIGHT","MAXAERITER","TURBIDW"]
  solz_layer=False # Filtering solz layer created in L2 processing, if exists. Use HISOLZEN FLAG if no solz layer
  solz_max=74 
  ####
  
  ifile=str(sys.argv[1])
  print(ifile)
  nc = Dataset(ifile,'r')
  gd_group = nc.groups['geophysical_data']
  nav_group = nc.groups['navigation_data']
  longitude = asarray(nav_group.variables['longitude'])
  latitude = asarray(nav_group.variables['latitude'])
  # Lat and lon bounds
  maxlat = 46.2
  minlat = 43.1
  maxlon = -63.1
  minlon = -68.8
  # Flagging and q/c 
  print("USING FLAGS:", l2_flags_to_use)
  flaglayer = asarray(gd_group.variables['l2_flags'])
  all_l2_flags = {"ATMFAIL": 1,
                "LAND": 2,
                "PRODWARN": 4,
                "HIGLINT": 8,
                "HILT": 16,
                "HISATZEN": 32,
                "COASTZ": 64,
                "spare": 128,
                "STRAYLIGHT": 256,
                "CLDICE": 512,
                "COCCOLITH": 1024,
                "TURBIDW": 2048,
                "HISOLZEN": 4096,
                "spare": 8192,
                "LOWLW": 16384,
                "CHLFAIL": 32768,
                "NAVWARN": 65536,
                "ABSAER": 131072,
                "spare": 262144,
                "MAXAERITER": 524288,
                "MODGLINT": 1048576,
                "CHLWARN": 2097152,
                "ATMWARN": 4194304,
                "spare": 8388608,
                "SEAICE": 16777216,
                "NAVFAIL": 33554432,
                "FILTER": 67108864,
                "spare": 134217728,
                "BOWTIEDEL": 268435456,
                "HIPOL": 536870912,
                "PRODFAIL": 1073741824,
                "spare": 2147483648}
  # Get the values of the user-selected flags.
  if len(l2_flags_to_use)==0:
      l2_flags = {}
  else:
      flags = l2_flags_to_use
      l2_flags = {}
      for flag in flags:
          # If too many commas used, ignore blank space between them.
          if not flag or flag.isspace(): continue
          flag = flag.strip()
          # Ignore duplicate flags.
          if flag in l2_flags.keys(): continue
          # Check if input is a valid l2 flag.
          if not flag in all_l2_flags.keys():
              sys.exit("".join(["Input error: unrecognized flag: ", flag]))
          l2_flags[flag] = all_l2_flags[flag]
  # Get the final value representing all selected flags.
  user_mask = sum(list(l2_flags.values()))
  #flaglayer.astype(int)
  
  # Find mask based on selected user flags.
  masked = (flaglayer & user_mask) != 0  
  print('Masked pixels: '+str(np.max(masked)))
  
  #### Load Bands ####
  # Chla bands:
  rrs_443 = asarray(gd_group.variables['Rrs_443'])#*2.0e-6+0.05
  rrs_488 = asarray(gd_group.variables['Rrs_488'])#*2.0e-6+0.05
  rrs_547 = asarray(gd_group.variables['Rrs_547'])#*2.0e-6+0.05
  # SPM Bands:
  rrs_555 = asarray(gd_group.variables['Rrs_555'])#*2.0e-6+0.05
  rrs_667 = asarray(gd_group.variables['Rrs_667'])#*2.0e-6+0.05
  rrs_748 = asarray(gd_group.variables['Rrs_748'])#*2.0e-6+0.05
  # Other:
  chlor_a = asarray(gd_group.variables['chlor_a']) # OCI algorithm chl-a
  
  # print(np.max(rrs_748))
  print('Size of array: '+str(np.shape(latitude)))
  
  if solz_layer==True:
      print("solz layer in file")
      solz = asarray(gd_group.variables['solz'])
      #### Rm masked pixels, <0 at 555 and 667 nm and solz above angle above ####
      ind=np.where( (masked == 0) & (rrs_555 > 0.) & (rrs_667 > 0.) & (solz <= solz_max) & (longitude >= minlon) & (longitude <= maxlon) & (latitude >= minlat) & (latitude <= maxlat) )
  else:
      #### Rm masked pixels, <0 at 555 and 667 nm ####
      ind=np.where( (masked == 0) & (rrs_555 > 0.) & (rrs_667 > 0.) & (longitude >= minlon) & (longitude <= maxlon) & (latitude >= minlat) & (latitude <= maxlat) )
  
  # Filter to ind values
  longikeep = longitude[ind]
  latikeep = latitude[ind]
  chlor_a = chlor_a[ind]
  rrs_443 = rrs_443[ind]
  rrs_488 = rrs_488[ind]
  rrs_547 = rrs_547[ind]
  rrs_555 = rrs_555[ind]
  rrs_667 = rrs_667[ind]
  rrs_748 = rrs_748[ind]
  
  # Remove negative rrs from chl bands
  indnegbandratio = np.where( (rrs_443 < 0) | (rrs_488 < 0.) | (rrs_547 < 0.) )
  chlor_a[indnegbandratio] = nan
  rrs_443[indnegbandratio] = nan
  rrs_488[indnegbandratio] = nan
  rrs_547[indnegbandratio] = nan
  rrs_555[indnegbandratio] = nan
  rrs_667[indnegbandratio] = nan
  rrs_748[indnegbandratio] = nan
  
  print(np.nanmin(rrs_488))
  print(np.nanmin(rrs_443))
  print(np.nanmin(rrs_547))

  #### SPM ####
  # SPM Ratio algorithm, Doxaran et al., Biogeosciences 2012, 2015: 
  rrs_ratio=rrs_748/rrs_555*100
  spmdox = 0.8386*rrs_ratio
  indgt2 = np.where( (rrs_ratio >= 87.) & (rrs_ratio <= 94.) )
  spmdox[indgt2]=70.+0.1416*rrs_ratio[indgt2]+2.9541*np.exp(0.4041*(rrs_ratio[indgt2]-87.)/1.9321)
  indgt3 = np.where(rrs_ratio > 94.)
  spmdox[indgt3]=3.922*rrs_ratio[indgt3]-285.4  

  # SPM Han et al. Remote Sensing 2016:
  rhow_667 = rrs_667 * np.pi
  spmL = 404.4 * rhow_667 / (1. - rhow_667 / 0.5)
  spmH = 1214.669 * rhow_667 / (1. - rhow_667 / 0.3394)
  WL = np.log10(0.04) - np.log10(rrs_667)
  WL[rrs_667 >= 0.04] = 0.
  WL[rrs_667 <= 0.03] = 1.
  WH = np.log10(rrs_667) - np.log10(0.03)
  WH[rrs_667 >= 0.04] = 1.
  WH[rrs_667 <= 0.03] = 0.
  spmhan = (WL * spmL + WH * spmH) / (WL + WH)

  # TSM Nechad 2010:
  ap_coeff = 362.09 # for 667 nm, AP
  cp_coeff = 0.1736 # for MODISA 667 nm, 10 CP
  
  # Upper limit - same as Acolite code https://github.com/acolite/acolite/blob/main/acolite/acolite/acolite_l2w.py
  # 0.5 for modisa
  maskout = np.where(rhow_667 >= (0.5*cp_coeff))
  numerator = ap_coeff*rhow_667
  denominator = (1 - (rhow_667*cp_coeff))
  spmnechad = numerator / denominator
  spmnechad[maskout] = nan
  
  
  # CHL-A #### 
  # Make sure rrs and chla where SPM Nechad is NaN are also NaN
  rrs_443[np.isnan(spmnechad)] = nan
  rrs_488[np.isnan(spmnechad)] = nan
  rrs_547[np.isnan(spmnechad)] = nan
  chlor_a[np.isnan(spmnechad)] = nan
  
  # Do typical Rrs oc3m ratio
  ind_488=np.where(rrs_488 > rrs_443)
  rrs_ratio_chl=rrs_443/rrs_547
  rrs_ratio_chl_488=rrs_488/rrs_547
  rrs_ratio_chl[ind_488]=rrs_ratio_chl_488[ind_488] 
  rrs_ratio_chl=np.log10(rrs_ratio_chl) 
  rrs_ratio_chl_488=np.log10(rrs_ratio_chl_488)
  
  # OC3 coefficients
  chla_oc3=np.power(10, (0.2424 + ( rrs_ratio_chl*-2.7423 ) + ( np.square(rrs_ratio_chl)*1.8017) + ( np.power(rrs_ratio_chl,3)*0.0015) + ( np.power(rrs_ratio_chl,4)*-1.228) ) )
  print(np.min(chla_oc3)) 
  print(np.max(chla_oc3))
  # Specify allowed range of values
  chla_oc3[chla_oc3>100] = nan
  chla_oc3[chla_oc3 <= 0] = nan
  print('OC3 min: '+str(np.nanmin(chla_oc3)))
  print('OC3 max: '+str(np.nanmax(chla_oc3)))
  
  # Modified chl algorithms
  # Formula 1:
  chla_oc3v1=np.power(10, (-0.2236212 + ( rrs_ratio_chl*-2.8525053) + ( np.square(rrs_ratio_chl)*-0.9345813) + ( np.power(rrs_ratio_chl,3)*1.9194721) + ( np.power(rrs_ratio_chl,4)*1.312857) + (np.log10(spmnechad)*-0.9826757) ) )
  # chla_oc3v1[np.isinf(chla_oc3v1)] = nan
  chla_oc3v1[chla_oc3v1 > 100] = nan
  chla_oc3v1[chla_oc3v1 <= 0] = nan
  print('OC3 v1 min: '+str(np.nanmin(chla_oc3v1)))
  print('OC3 v1 max: '+str(np.nanmax(chla_oc3v1)))
  
  # Formula 2: OCX-SPMCOR
  # rrs_ratio_chl_488=np.log10( rrs_ratio_chl_488 )
  chla_oc3v2=np.power(10, (-0.2307818 + ( rrs_ratio_chl_488*-2.8174856) + ( np.square(rrs_ratio_chl_488)*-0.9109887) + ( np.power(rrs_ratio_chl_488, 3)*1.9070607) + ( np.power(rrs_ratio_chl_488, 4)*1.3149395) + (np.log10(spmnechad)*-1.0019175) ) )
  chla_oc3v2[chla_oc3v2 > 100] = nan
  chla_oc3v2[chla_oc3v2 <= 0] = nan
  print('OC3 v2 min: '+str(np.nanmin(chla_oc3v2)))
  print('OC3 v2 max: '+str(np.nanmax(chla_oc3v2)))
  
  # Make sure valid pixels in file
  nb_good_pxl=longikeep.size
  if nb_good_pxl>0:
      print(nb_good_pxl,"valid pixels in file")
      #### Save Data ####
      out_data=np.zeros((nb_good_pxl,18))-999.
      out_data[:,0]=longikeep
      out_data[:,1]=latikeep
      out_data[:,2]=spmhan
      out_data[:,3]=spmdox
      out_data[:,4]=chlor_a #oc3/oci chl
      out_data[:,5]=chlgsm_data # Need to remove all these extra products and not mess up code later on
      out_data[:,6]=kdlee_data
      out_data[:,7]=kd490_data
      out_data[:,8]=sst_data
      out_data[:,9]=par_data
      out_data[:,10]=spmnechad
      out_data[:,11]=chla_oc3
      out_data[:,12]=rrs_443
      out_data[:,13]=rrs_488
      out_data[:,14]=rrs_547
      out_data[:,15]=rrs_667
      out_data[:,16]=chla_oc3v1
      out_data[:,17]=chla_oc3v2
  
      print('Max Nechad SPM: '+str(np.nanmax(spmnechad)))
      print('Max OC3 Chl: '+str(np.nanmax(chla_oc3)))
      print('Max OC3 v1 Chl: '+str(np.nanmax(chla_oc3v1)))
      print('Max OC3 v2 Chl: '+str(np.nanmax(chla_oc3v2)))
  
      f = open(ofile, 'w')
      np.savetxt(ofile, out_data, fmt='%15.10f')
      f.close()
  else:
      print("Zero valid pixels in file")
      
  print("-------")

#--------------------------
#       Command Line
#--------------------------
if __name__=='__main__':
  main(*sys.argv[1:])
