library(terra)
setwd("")
modis = list.files("./BayofFundy/Modis/Daily_Composites_geotiff/chloc3m2/")
modis.date = as.Date( unlist(strsplit(modis,"A"))[seq(2,length(modis )*2,2)], format="%Y%j")
modis = list.files("./BayofFundy/Modis/Daily_Composites_geotiff/chloc3m2/",full.names = T)


for(i in 2003:2021){
  a = grep(i, modis.date)
  modis.ras = rast(modis[a])
  modis.median = app(modis.ras, "median", na.rm=T, filename = paste0("./BayofFundy/Modis/Yearly/chloc3m2/Median",i,".tif"),overwrite=T)
  modis.sd = app(modis.ras, "sd", na.rm=T, filename = paste0("./BayofFundy/Modis/Yearly/chloc3m2/SD",i,".tif"),overwrite=T)
  modis.ras = modis.ras*0
  modis.ras = modis.ras+1
  modis.num = app(modis.ras, "sum", na.rm=T,
                  filename = paste0("./BayofFundy/Modis/Yearly/chloc3m2/NumObs",i,".tif"),overwrite=T)
  plot(modis.median, main=i)
  rm(a, modis.ras,modis.median,modis.sd,modis.num)
  gc()
  }

gc()
modis = list.files("./BayofFundy/Modis/Yearly/chloc3m2/",full.names = T,pattern="Median")
modis.ras = rast(modis)
modis.median = app(modis.ras, "median", na.rm=T, filename = "./BayofFundy/Modis/Yearly/Climatology/Medianchloc3m2200320221.tif",overwrite=T)
modis.median = app(modis.ras, "sd", na.rm=T, filename = "./BayofFundy/Modis/Yearly/Climatology/SDchloc3m2200320221.tif",overwrite=T)
modis.ras = modis.ras*0
modis.ras = modis.ras+1
modis.median = app(modis.ras, "sum", na.rm=T, filename = "./BayofFundy/Modis/Yearly/Climatology/NumObschloc3m2200320221.tif",overwrite=T)



