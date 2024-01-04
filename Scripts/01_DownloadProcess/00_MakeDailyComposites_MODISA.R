# Make daily composite images
# Here we make daily composites using the median of all images available

# How to use: 
# Rscript Make_daily_composites_modisa.R spmnec

library(ncdf4)
library(stringr)
library(lubridate)
library(sp)

##First read in the arguments listed at the command line
args=(commandArgs(TRUE))
print(args)
if(length(args) < 1){
  print("Not enough arguments supplied.")
} else if (length(args) == 1) {
  varname = as.character(args[1])
} else if (length(args) > 1) {
  message("Too many arguments")
}
var_code <- varname # Options: chloci, sst, chlgsm, spmdox, spmhan, spmnec, kdlee, kd490, par, chloc3m1, chloc3m2
grdpath = "./"

print(paste("PROCESSING DAILY COMPOSITES FOR:",var_code))
###########
#To loop through years, uncomment following and closing bracket
# for (iyear in 2003:2021) {
  lifiday = list.files(grdpath, pattern = var_code, full.names = T)
  
  if (var_code == "chloc3") {
    idx_rm = grep("m1.grd", lifiday)
    # lifiday=lifiday[-idx_rm]
    if (length(idx_rm) > 0 ){ 
      lifiday = lifiday[-idx_rm]
      }
    idx_rm = grep("m2.grd", lifiday)
    if (length(idx_rm) > 0 ){ 
      lifiday = lifiday[-idx_rm]
      }
  }

  lifiday = lifiday[grep(".grd",lifiday)]
  nbday=length(lifiday)
  message(paste("num imgs:",nbday))

  #Open the first image in the list to retrieve lat/lon info
  # we go from vector to matrices for lat and lon
  ncf = nc_open(lifiday[1])
  longi = ncvar_get(ncf,"lon")
  lati = ncvar_get(ncf,"lat")
  nc_close(ncf)

  matlon = matrix(rep(longi,length(lati)),length(longi),length(lati))
  matlat = t(matrix(rep(lati,length(longi)),length(lati),length(longi)))
  dim(matlon)
  filename = str_extract(lifiday, pattern = "A[0-9]{13}")
  yrnum = as.numeric(substr(filename, 2, 5))
  daynum = as.numeric(substr(filename, 6, 8))
  timestamp = (substr(filename,9,12))
  
  justdate = as.Date(paste(yrnum, daynum, sep = "-"), format = "%Y-%j")
  nbday = unique(justdate)
  
  for (i in 1:length(nbday))
  {
    # print(paste(iyear, ":", i,"of", length(nbday), sep = " "))
    lifim_sub = lifiday[justdate == nbday[i]]
    message(nbday[i])
    message(lifim_sub)
    # lifim_sub = lifiday[daynum == nbday[i]]

    if (length(lifim_sub)>0) {
      cubespm = array(NaN,c(length(longi),length(lati),length(lifim_sub)))
      for (j in 1:length(lifim_sub))
        {
          #Open file
          ncf = nc_open(lifim_sub[j])
          geovar=ncvar_get(ncf,"z")
          nc_close(ncf)
          print(dim(geovar))
          
          #Remove data out of range for variable
          if ((var_code == "spmnec") || (var_code == "spmdox") || (var_code == "spmhan")) {
            geovar[geovar <= 0] <- NA # Remove SPM pixels <- 0
          } else if ((var_code == "chloci") || (var_code == "chloc3" || (var_code == "chloc3m1") || (var_code == "chloc3m2") )) {
            # geovar[geovar < 0.01] <- NA # Remove chl pixels out of range
            geovar[geovar > 50] <- NA
          } else if (var_code == "sst") {
            geovar[geovar < -1.89] <- NA
          } else if ((var_code == "kd490") || (var_code == "kdlee")) {
            geovar[geovar <= 0] <- NA
            geovar[geovar >= 100] <- NA
          } else if (var_code == "gsm") {
            geovar[geovar <= 0] <- NA
            geovar[geovar >= 100] <- NA
          } else if (var_code == "kdlee") {
            geovar[geovar <= 0] <- NA
            geovar[geovar >= 100] <- NA
          } 
          cubespm[,,j] = geovar
        }
        if (length(lifim_sub) == 1) {
          medgeovar = cubespm
        } else {
          medgeovar=apply(cubespm,c(1,2),"median",na.rm=T)
        }
        
        indk=is.finite(medgeovar)
        yearday = paste0(year(nbday[i]), str_pad(as.character(yday(nbday[i])),width = 3,side = "left",pad = "0"))
        outfile=paste0("A",yearday,"_",var_code,".asc")
        write.table(cbind(matlon[indk],matlat[indk],medgeovar[indk]),outfile,row.names=F,col.names=F,quote=F)
        
        grdfile=paste0("A",yearday,"_",var_code,".grd")
        # cmdgrd=paste("gmt xyz2grd ",outfile," -G",grdfile," -I300e -R/-68.8/-63.1/43.1/46.2 -V -fg",sep="")
        cmdgrd=paste0("gmt xyz2grd ",outfile," -G",grdfile," -I300e -R/-68.8/-63.1/43./46.2 -V -fg")
        system(cmdgrd)
     
      } else {
        print("No images in time frame")
      }
    }
# }
