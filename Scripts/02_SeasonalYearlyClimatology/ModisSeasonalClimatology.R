library(terra)

setwd("")
#this script will calculate the median, standard deviation, and number of input images for each season by year
#the breakdown of season by month number with January being month 1 is on Lines 11 to 38
#Line 42 can be changed to mean as needed
#Line 56 to ends calculates the seasonal stats across all years
for(j in c("winter","spring","summer","fall")){
  print(j)
for(i in 2003:2021){
  modis = list.files("./BayofFundy/Modis/Daily_Composites_geotiff/chloc3m2/",pattern=as.character(i))
  modis.date = as.Date( unlist(strsplit(modis,"A"))[seq(2,length(modis )*2,2)], format="%Y%j")
  if (j =="winter"){
  b = grep("-01-", modis.date)
  c = grep("-02-", modis.date)
  d = grep("-03-", modis.date)
  seas = c(b,c,d)
  rm(b,c,d)
  }
  if (j =="spring"){
    b = grep("-04-", modis.date)
    c = grep("-05-", modis.date)
    d = grep("-06-", modis.date)
    seas = c(b,c,d)
    rm(b,c,d)
  }
  if (j =="summer"){
    b = grep("-07-", modis.date)
    c = grep("-08-", modis.date)
    d = grep("-09-", modis.date)
    seas = c(b,c,d)
    rm(b,c,d)
  }
  if (j =="fall"){
    b = grep("-10-", modis.date)
    c = grep("-11-", modis.date)
    d = grep("-12-", modis.date)
    seas = c(b,c,d)
    rm(b,c,d)
  }
  print(modis.date[seas])
  modis = list.files("./BayofFundy/Modis/Daily_Composites_geotiff/chloc3m2/",full.names = T,pattern=as.character(i))
  modis.ras = rast(modis[seas])
  modis.median = app(modis.ras, "median", na.rm=T, filename = paste0("./BayofFundy/Modis/Seasonal/chloc3m2/Median",j,i,".tif"),overwrite=T)
  modis.sd = app(modis.ras, "sd", na.rm=T, filename = paste0("./BayofFundy/Modis/Seasonal/chloc3m2/SD",j,i,".tif"),overwrite=T)
  modis.ras = modis.ras*0
  modis.ras = modis.ras+1
  modis.num = app(modis.ras, "sum", na.rm=T,
                  filename = paste0("./BayofFundy/Modis/Seasonal/chloc3m2/NumObs",j,i,".tif"),overwrite=T)
  plot(modis.median, main=i)
  rm(modis.ras,modis.median,modis.sd,modis.num,seas,modis,modis.date)
  gc()
  }
}
gc()

for(j in c("winter","spring","summer","fall")){
  print(j)
modis = list.files("./BayofFundy/Modis/Seasonal/chloc3m2/",full.names = T,pattern=paste0("Median", j))
modis.ras = rast(modis)
modis.median = app(modis.ras, "median", na.rm=T, 
                   filename = paste0("./BayofFundy/Modis/Seasonal/Climatology/Medianchloc3m2" ,j, "200320221.tif"),overwrite=T)
modis.median = app(modis.ras, "sd", na.rm=T, 
                   filename = paste0("./BayofFundy/Modis/Seasonal/Climatology/SDchloc3m2" ,j, "200320221.tif"),overwrite=T)
modis.ras = modis.ras*0
modis.ras = modis.ras+1
modis.median = app(modis.ras, "sum", na.rm=T, 
                   filename = paste0("./BayofFundy/Modis/Seasonal/Climatology/NumObschloc3m2" ,j, "200320221.tif"),overwrite=T)
}


