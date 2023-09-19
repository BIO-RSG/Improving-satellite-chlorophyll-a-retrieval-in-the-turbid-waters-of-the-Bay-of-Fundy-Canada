library(ncdf4)
library(raster)
library(doParallel)
library(foreach)

in.fold = "/home/kwilson/disk2/FUNDY_2021/MODISA/L3/Daily/chloc3m2"
out.fold = "/home/kwilson/disk4/BayofFundy/Modis/Daily_Composites_geotiff/chloc3m2/"

nc.names = list.files(in.fold,recursive=T,pattern="v3.grd$")
name.paste = paste0(in.fold,"/", nc.names)

UseCores = 25
cl  = makeCluster(UseCores)
registerDoParallel(cl) 

foreach (i=1:length(nc.names)) %dopar% {
  library(raster)
  library(ncdf4)
nc =nc_open(name.paste[i])
lon = ncvar_get(nc, "lon")
lat = ncvar_get(nc, "lat")
nc = ncvar_get(nc, nc$var$z)

nc1 = raster(nc)
nc1 = t(raster(nc))
nc2 = flip(nc1)
proj4string(nc2)  = "+proj=longlat +datum=WGS84 +no_defs"
extent(nc2) = c(min(lon),max(lon),min(lat),max(lat))
writeRaster(nc2,
            paste0(out.fold,  unlist(strsplit(nc.names[i],".grd")),".tif"),
            format="GTiff",NAflag = NaN,overwrite=T,options = c("COMPRESS=DEFLATE"))

}
stopCluster(cl)

test = stack(paste0(out.fold, list.files(out.fold)))
plot(test[[16]])
rm(test)          
rm(in.fold, out.fold,nc.names,name.paste, UseCores, cl)
   