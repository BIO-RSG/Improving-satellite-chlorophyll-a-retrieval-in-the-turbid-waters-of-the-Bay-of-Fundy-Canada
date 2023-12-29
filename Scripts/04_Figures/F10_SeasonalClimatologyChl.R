library(pals)
library(terra)
library(rnaturalearth)
yearmed =  rast(list.files("Data/Modis/Chla/",pattern="Median", full.names = T )[1:4])
names(yearmed) = c("fall" , "spring","summer" , "winter")
yearmed = ifel(yearmed > 20, 20, yearmed)
chlbreaks = c(seq(0,1,0.1),seq(2,10,0.5),15,20)#,30,40,50)
chl.palette = oceancolouR::gmt_drywet(length(chlbreaks)-1)
chl.palette = tol.rainbow(length(chlbreaks)-1)
world = ne_countries(scale = 10)
world = vect(world)
world = crop(world, yearmed$fall)
png("./Figures/Figure10.png", width=6.7 ,height=4.5,res=300,unit="in", pointsize = 10)
par(mfrow=c(2,2),family="serif",oma=c(1,0,0,0))
plot(yearmed$spring,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,4.5,1,1),cex=1)
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(a)")
##
plot(yearmed$summer,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,1,1,4.5),cex=1)
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(b)")
plot(yearmed$fall,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,4.5,1,1),cex=1)
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(c)")
##
plot(yearmed$winter,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     ylim = c(43.1,46.25),mar=c(1,1,1,4.5),cex=1,xpd=NA)
DescTools::ColorLegend(x=-63.5,y=45.7,cols=chl.palette,width=0.25,height=2.6,xpd=NA,
                       #labels=chlbreaks[c(1,seq(2,24,2))],title=expression("Chl-a (mg/m"^3*")"))
                       labels=chlbreaks[c(1,seq(2,30,2))],title=expression("Chl-a (mg/m"^3*")"),frame="black")
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(d)")
dev.off()