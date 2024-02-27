library("raster")
library("oceancolouR")

#This codes reads in your .tif satellite files and the matchup datatset in a .csv file
#It uses the date to find files with the same date in both the satellite and in situ data
#It then extracts the pixels in a 5x5 box around the matchup point, change line 49 for a different box size
#Median, mean, geometric mean, n, standard deviation, filtered mean, and coefficient of variation are all returned

#Get Modis data
modis.dates.in = list.files("./Modis/Daily_Composites_geotiff/chloc3",recursive=T,pattern=".tif")
modis.dat = stack(paste0("./Modis/Daily_Composites_geotiff/chloc3/", modis.dates.in))

#Turner matchup
turnerchl = read.csv("./Data/Matchups/MergeFinalChlaturner.csv")

#S2 chl matchups
modis.date = as.Date( unlist(strsplit(names(modis.dat),"A"))[seq(2,dim(modis.dat)[3]*2,2)], format="%Y%j")
s2.dates = as.Date(modis.date)
###
match.biochem.dates = as.Date(turnerchl$Date)
#find matching dates
index.match = match.biochem.dates %in% s2.dates
#Make spatial points
turnerchl = turnerchl[index.match==T,]
turnerchl.shp = SpatialPointsDataFrame(coords=turnerchl[,7:6],data=turnerchl,
                                       proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs" ))
turnerchl.shp.prj = spTransform(turnerchl.shp, modis.dat@crs)
#
index.match = s2.dates%in%match.biochem.dates
modis.dat = modis.dat[[which(index.match==T)]]
s2.dates = s2.dates[which(index.match==T)]

#Add in metrics
turnerchl$median = NA
turnerchl$mean = NA
turnerchl$geomean = NA
turnerchl$validn = NA
turnerchl$sd = NA
turnerchl$filtmean = NA
turnerchl$cv = NA


for (i in 1:length(turnerchl[,1])){
  print(i)
  a = which((s2.dates) %in%as.Date(turnerchl$Date)[i]==T)
  shp.in2 = extract(modis.dat[[a]], turnerchl.shp.prj[i,],df=T, cellnumbers=T)
  if(is.na(shp.in2$cells)==F){
    xy = as.data.frame(rowColFromCell(modis.dat[[a]], cell = shp.in2$cells))
    outvals_3 = box_fun(r = modis.dat[[a]], boxsize = c(5,5), rowcol = xy)
    turnerchl$median[i]= median(outvals_3, na.rm=T) 
    turnerchl$mean[i]= mean(outvals_3, na.rm=T) 
    turnerchl$geomean[i]= geoMean(outvals_3, na.rm=T) 
    turnerchl$validn[i] = sum(is.na(outvals_3)==F)
    turnerchl$sd[i] = sd(outvals_3,na.rm=T)
    turnerchl$filtmean[i] = filtered_mean(outvals_3)[1]
    turnerchl$cv[i] = filtered_mean(outvals_3)[3]
    rm(xy,outvals_3)}
  if(is.na(shp.in2$cells)==T){
    turnerchl$median[i]= NA 
    turnerchl$mean[i]= NA 
    turnerchl$geomean[i]= NA
    turnerchl$validn[i] = NA
    turnerchl$sd[i] = NA
    turnerchl$filtmean[i] = NA
    turnerchl$cv[i] = NA
  }  
  rm(a,shp.in2)} 
turnerchl = turnerchl[is.na(turnerchl$median)==F,]
turnerchl = turnerchl[is.na(turnerchl$sd)==F,]
turnerchl$filtmean = unlist(turnerchl$filtmean)
turnerchl$cv = unlist(turnerchl$cv)
write.csv(turnerchl,"./Data/Matchups/ModisChlaturner.csv",row.names = F)


