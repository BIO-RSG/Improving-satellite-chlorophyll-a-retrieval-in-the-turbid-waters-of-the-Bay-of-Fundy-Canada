library(pals)
library(terra)
library(rnaturalearth)
options(scipen = 5)
setwd("")
world = ne_countries(scale = 10)
world = vect(world)
##
oc3 = rast("./Data/MapsTif/A2016278_chloc3_v3.tif")
m2 = rast("./Data/MapsTif/A2016278_chloc3m2_v3.tif")
spm = rast("./Data/MapsTif/A2016278_spmnec_v3.tif")
##
stjohn = vect("./Data/StJohnHarbour/OuterHarbour_Polygon.shp")
stjohn = project(stjohn,  crs("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
##
horsemussel = vect("./Data/HorseMussel/networksites_proposed_OEM_MPA_v2.shp")
horsemussel = horsemussel[horsemussel$NAME=="Horse Mussel Reefs" ,]
horsemussel = project(horsemussel,  crs("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
##
p5 = read.csv("./Data/Insitu/MergeFinalChlaturner.csv")
p5 = p5[which(p5$COLLECTOR_STATION_NAME %in% c( "P5" ,"Prince 5","Prince_5" ,"Prince5" )==T),]
p5 = p5[p5$START_DEPTH<=10,]
p5 = p5[p5$LATITUDE<44.95,]
p5 = p5[p5$YEAR>=2003,]
p5 = data.frame(cbind( mean(p5$LATITUDE), mean(p5$LONGITUDE)))
#p5= vect(p5, geom=c("LONGITUDE", "LATITUDE"),crs =  crs("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
p5= vect(p5, geom=c("X2", "X1"),crs =  crs("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

chlbreaks = c(seq(0,1,0.1),seq(2,10,1),20,30,40,50)
chl.palette = oceancolouR::gmt_drywet(length(chlbreaks)-1)
nasa_universal_bluered <- function(n = 25) {
  bluered <- rgb(r = c(0,0,0,0,0,0,0,0,0,1,2,4,6,10,15,25,45,70,100,135,165,190,210,227,240,248,
                       253,255,255,255,255,254,251,246,235,220,209,196,183,172,160),
                 g = c(0,0,0,0,3,8,20,39,62,85,109,134,160,185,205,220,231,239,244,246,246,246,244,
                       239,231,220,205,185,160,134,109,85,62,39,20,8,3,0,0,0,0),
                 b = c(130,144,161,182,202,220,235,246,251,254,255,255,255,254,252,248,242,234,224,210,
                       192,170,145,115,80,50,30,18,10,6,4,2,1,0,0,0,0,0,0,0,0),
                 maxColorValue = 255)
  colorRampPalette(bluered)(n)
}
spm.palette = nasa_universal_bluered(length(chlbreaks)-1)
world = crop(world, oc3)
png("./Figures//ExampleMaps.png", width=4.2 ,height=7.5,res=300,unit="in", pointsize = 10)
par(mfrow=c(3,1),family="serif",oma=c(1,0,0,0))
plot(oc3,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,1,1,8),cex=1)
DescTools::ColorLegend(x=-62.5,y=46,cols=chl.palette,width=0.25,height=2.9,xpd=NA,
                       labels=chlbreaks[c(1,seq(2,24,2))],title=expression("Chl-a (mg/m"^3*")"))
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
plot(stjohn,add=T,lwd=3,border="black")
plot(stjohn,add=T,lwd=2,border="red")
plot(horsemussel,add=T,lwd=3,border="black")
plot(horsemussel,add=T,lwd=2,border="purple")
points(p5,pch=21, bg="orange", col="black",cex=1.5)
text(x=-68.5, y=46, "(a)")
##
plot(m2,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,1,1,8))
legend(x=-63.1,y=45.5, c("Prince 5","St John Harbour", "Horse Mussel Reef"), lwd=c(NA,1,1),
       pch=c(21,NA,NA),pt.bg = c("orange",NA,NA),
       col=c("black", "red","purple"),xpd=NA,bty="n")
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
plot(stjohn,add=T,lwd=3,border="black")
plot(stjohn,add=T,lwd=2,border="red")
plot(horsemussel,add=T,lwd=3,border="black")
plot(horsemussel,add=T,lwd=2,border="purple")
points(p5,pch=21, bg="orange", col="black",cex=1.5)
text(x=-68.5, y=46, "(b)")
##
plot(spm,buffer=F,breaks=chlbreaks, col=spm.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,1,1,8))
DescTools::ColorLegend(x=-62.5,y=46,cols=spm.palette,width=0.25,height=2.9,xpd=NA,
                       labels=chlbreaks[c(1,seq(2,24,2))],title=expression("SPM (g/m"^3*")"))
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
plot(stjohn,add=T,lwd=3,border="black")
plot(stjohn,add=T,lwd=2,border="red")
plot(horsemussel,add=T,lwd=3,border="black")
plot(horsemussel,add=T,lwd=2,border="purple")
points(p5,pch=21, bg="orange", col="black",cex=1.5)
text(x=-68.5, y=46, "(c)")
dev.off()