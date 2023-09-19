#! /usr/bin/env python
# Emmanuel Devred, 2019
# Modified by Andrea Hilborn Feb. 2020

from numpy import *
import sys, os

sys.dont_write_bytecode = True
#sys.path.insert(0, '/Users/emmanueldevred/python/utilities')

import numpy as np
from netCDF4 import Dataset
np.warnings.filterwarnings('ignore')
#from hdf_utilities import *

#
# defaults
#
def main(*args):
  
  #### Define L2 flags and other q/c ####
  l2_flags_to_use = ["LAND","HISATZEN","HISOLZEN","CLDICE","HILT","STRAYLIGHT","MAXAERITER"]
  solz_layer=False
  solz_max=74 # Filtering solz layer created in L2 processing, if exists. Use HISOLZEN FLAG if no solz layer
  ####
  
  ifile=str(sys.argv[1]) #+'.L2'
  print(ifile)
  ofile=str(sys.argv[1])+'_v2.asc'
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
  # Subset flag layer.
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
  chla = asarray(gd_group.variables['chlor_a']) # OCI algorithm chl-a
  chl_gsm = asarray(gd_group.variables['chl_gsm'])
  kd490 = asarray(gd_group.variables['Kd_490']) # KD4 algorithm Kd490
  sst = asarray(gd_group.variables['sst'])
  kdlee = asarray(gd_group.variables['Kd_488_lee'])
  par = asarray(gd_group.variables['par'])
  
  # print(np.max(rrs_748))
  print('Size of array: '+str(np.shape(latitude)))
  
  if solz_layer==True:
      print("solz layer in file")
      solz = asarray(gd_group.variables['solz'])
      #### Rm masked pixels, <=0 at 555 and 667 nm and solz > 74 deg ####
      ind=np.where( (masked == 0) & (rrs_555 > 0.) & (rrs_667 > 0.) & (solz <= solz_max) & (longitude >= minlon) & (longitude <= maxlon) & (latitude >= minlat) & (latitude <= maxlat) )
  else:
      ind=np.where( (masked == 0) & (rrs_555 > 0.) & (rrs_667 > 0.) & (longitude >= minlon) & (longitude <= maxlon) & (latitude >= minlat) & (latitude <= maxlat) )
  
  # Filter to ind values
  longikeep = longitude[ind]
  latikeep = latitude[ind]
  chl_data = chla[ind]
  chlgsm_data = chl_gsm[ind]
  kd490_data = kd490[ind]
  sst_data = sst[ind]
  kdlee_data = kdlee[ind]
  par_data = par[ind]
  # rrs_443 = rrs_443[ind]
  # rrs_488 = rrs_488[ind]
  # rrs_547 = rrs_547[ind]
  # rrs_555 = rrs_555[ind]
  # rrs_667 = rrs_667[ind]
  # rrs_748 = rrs_748[ind]
  
  # Chla Ratio: ####
  
  # rrs_443[rrs_443<=0] = NaN
  # rrs_488[rrs_488<=0] = NaN
  # rrs_547[rrs_547<=0] = NaN
  print(np.nanmin(rrs_488))
  print(np.nanmin(rrs_443))
  print(np.nanmin(rrs_547))
    
  ind_488=np.where(rrs_488 > rrs_443)
  rrs_ratio_chl=rrs_443/rrs_547
  rrs_ratio_chl_488=rrs_488/rrs_547
  rrs_ratio_chl[ind_488]=rrs_ratio_chl_488[ind_488]
  rrs_ratio_chl=np.log10(rrs_ratio_chl)
  
  # OC5 coefficients
  chla_oc3=np.power(10, (0.2424 + ( rrs_ratio_chl*-2.7423 ) + ( np.square(rrs_ratio_chl)*1.8017) + ( np.power(rrs_ratio_chl,3)*0.0015) + ( np.power(rrs_ratio_chl,4)*-1.228) ) )
  chla_oc3 = chla_oc3[ind]
  print(np.min(chla_oc3)) 
  print(np.max(chla_oc3))
  chla_oc3[chla_oc3>100] = nan
  chla_oc3[chla_oc3 <= 0] = nan
  
  print(np.nanmin(chla_oc3)) 
  print(np.nanmax(chla_oc3))
  
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

  # TSM Nechad 2010
  ap_coeff = 362.09 # for 667 nm, AP
  cp_coeff = 0.1736 # for MODISA 667 nm, 10 CP
  
  # Upper limit - copied from Acolite code https://github.com/acolite/acolite script acolite_l2w.py
  # 0.5 for modisa
  maskout = np.where(rhow_667 >= (0.5*cp_coeff))
  numerator = ap_coeff*rhow_667
  denominator = (1 - (rhow_667*cp_coeff))
  spmnechad = numerator / denominator
  spmnechad[maskout] = nan
  

  # Keeping indices with valid SPM Han range
  # indmes = np.where ( (spmhan > 0.00) & (spmhan < 1000.) )
  # indmes= np.where ( (spm > 0.05) & (spm < 1000.) ) # Before ...raised to 0.05
    
  nb_good_pxl=longikeep.size
  print('Valid pixels: '+str(longitude.size))
  # print(nb_good_pxl)
  
  if nb_good_pxl>0:
      print(nb_good_pxl,"valid pixels in file")
      #### Save Data ####
      out_data=np.zeros((nb_good_pxl,12))-999.
      out_data[:,0]=longikeep
      out_data[:,1]=latikeep
      out_data[:,2]=spmhan[ind] # Here we store the new SPM in column 3 to generate grd spm
      out_data[:,3]=spmdox[ind]
      out_data[:,4]=chl_data
      out_data[:,5]=chlgsm_data
      out_data[:,6]=kdlee_data
      out_data[:,7]=kd490_data
      out_data[:,8]=sst_data
      out_data[:,9]=par_data
      out_data[:,10]=spmnechad[ind]
      out_data[:,11]=chla_oc3
  
      print('Max Han SPM: '+str(np.nanmax(spmhan)))
      print('Max Nechad SPM: '+str(np.nanmax(spmnechad)))
      print('Max OC3 Chl: '+str(np.nanmax(chla_oc3)))
  
      #    #    print(rrs_748[ind])
      #
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
