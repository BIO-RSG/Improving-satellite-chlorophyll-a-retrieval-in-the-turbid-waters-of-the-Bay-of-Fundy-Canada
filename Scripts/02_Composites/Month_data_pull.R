# Climatology maps from the .grd files
# Andrea Hilborn in September 2021

library(ggplot2)
library(dplyr)
library(stringr)
library(lubridate)
library(oceancolouR)
library(ncdf4)

### VAR NAME - GRD FILE NAME
# var = "chl_oci" # options are chl_oci and sst and spm_han so far
var="spm_han"
atm = "NIR" # MUMM or SWIR or NIR
#########

if (var == "chl_oci") {
  filevar="chloci"
  folder="chl"
  llim = 0
  ulim = 40
} else if (var == "sst") {
  filevar <- folder <- "sst"
  llim = -1.89
  ulim = 50
} else if (var == "spm_han") {
  filevar <- "spmhan"
  folder = "spm"
  llim = 0
  ulim = 1000
}

# Month dates
month_dates = yday(seq.Date(as.Date("2003-01-01"),as.Date("2003-12-31"),by="1 month"))
month_end = as.numeric(c(month_dates[2:12]-1, "366"))
spring = month_dates[c(3,4,5)]
summer = month_dates[c(6,7,8)]
fall = month_dates[c(9,10,11)]
winter = month_dates[c(12,1,2)]

# MONTHLY COMPOSITES - MUMM ####

lifi_atm = list.files(paste0("./data/MODISA/",folder), 
                       pattern = paste0(atm,filevar,".grd"), full.names = T)
date_atm = str_extract(lifi_atm, pattern = "[0-9]{13}")
date_atm = as.POSIXct(date_atm, format="%Y%j%H%M%S", tz = "UTC")

nc = nc_open(lifi_atm[1])
lat = ncvar_get(nc, "lat")
lon = ncvar_get(nc, "lon")
latlon <- expand.grid(lon, lat, KEEP.OUT.ATTRS = F, stringsAsFactors = F)
nc_close(nc)

for (i in 1:12) {
  print(month.name[i])
  dateidx = which(yday(date_atm)>= month_dates[i] & yday(date_atm) <= month_end[i])
  filesub = lifi_atm[dateidx]
  datesub = date_atm[dateidx]
  # LIST STORING DATA FROM MONTH
  dateunique = unique(yday(datesub))
  chlmonth = list()
  cm=1
  for (j in 1:length(dateunique)) {
    print(paste("Day of year:",dateunique[j]))
    numsame = which(yday(datesub) == dateunique[j])
    # LIST STORING DATA FROM SAME DAY
    chlday = list()
    ck = 1
    for (k in 1:length(numsame)) {
      cat("...")
      n = nc_open(filesub[numsame[k]])
      c = ncvar_get(n, "z")
      nc_close(n)
      c[c<=llim] <- NA
      c[c>ulim] <- NA
      c = as.vector(c)
      chl = data.frame(lon=latlon$Var1, lat=latlon$Var2, data=c)
      chl=chl %>% filter(!is.na(data))
      if (nrow(chl) > 0) {
        chlday[[ck]] <- chl
        ck=ck+1
      }
    }
    chlday = do.call("rbind",chlday)
    chlmonth[[cm]] = chlday
    cm=cm+1
  }
  chlmonth = do.call("rbind", chlmonth)
  cat("Month composite")
  if (var == "chl_oci") {
    chlmonth = chlmonth %>% group_by(lon, lat) %>% 
      summarise(chl_median = median(data, na.rm=T),
                chl_geosd = geoSD(data, na.rm=T),
                chl_n = sum(!is.na(data), na.rm=T)) %>% ungroup()
  } else if (var == "sst") {
    chlmonth = chlmonth %>% group_by(lon, lat) %>% 
      summarise(sst_median = median(data, na.rm=T),
                sst_sd = sd(data, na.rm=T),
                sst_n = sum(!is.na(data), na.rm=T)) %>% ungroup()
  } else if (var == "spm_han") {
    chlmonth = chlmonth %>% group_by(lon, lat) %>% 
      summarise(han_median = median(data, na.rm=T),
                han_geosd = geoSD(data, na.rm=T),
                han_n = sum(!is.na(data), na.rm=T)) %>% ungroup()
  }
  cat("Saving...")
  saveRDS(chlmonth, file = paste0("./data/MODISA/rda_files/Month_",atm,
                                  "_",var,"_", str_pad(i, width = 2, side = "left", 
                                                       pad = "0"), ".rds"))
 rm(chlday, chl, c, chlmonth)
 gc()
}
beepr::beep()
