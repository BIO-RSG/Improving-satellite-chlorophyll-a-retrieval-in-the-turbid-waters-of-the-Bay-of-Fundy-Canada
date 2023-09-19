library(pals)
library(terra)
library(rnaturalearth)
setwd("Bay_of_Fundy_2021_part1_Modis/")

yearmed = rast(list.files("Data/Modis/Yearly/Climatology/",pattern="Median", full.names = T ))
names(yearmed) = c("chl", "spm")

plot(yearmed)               


chlbreaks = c(seq(0,1,0.1),seq(2,10,1),20,30,40,50)
chl.palette = oceancolouR::gmt_drywet(length(chlbreaks)-1)
chl.palette = tol.rainbow(length(chlbreaks)-1)
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
world = ne_countries(scale = 10)
world = vect(world)
world = crop(world, yearmed$chl)
png("./Figures//YearlyClimatology.png", width=5 ,height=6.5,res=300,unit="in", pointsize = 10)
par(mfrow=c(2,1),family="serif",oma=c(1,0,0,0))
plot(yearmed$chl,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     smooth=F, maxcell=floor(ncell(yearmed$chl)*0.85),
     ylim = c(43.1,46.25),mar=c(1,1,1,4),cex=1)
DescTools::ColorLegend(x=-62.5,y=46,cols=chl.palette,width=0.25,height=2.9,xpd=NA,
                       labels=chlbreaks[c(1,seq(2,24,2))],title=expression("Chl-a (mg/m"^3*")"))
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=46, "(a)")
##
plot(yearmed$spm ,buffer=F,breaks=chlbreaks, col=spm.palette,legend=F,xlim = c(-68.8,-63.1), 
     smooth=F, maxcell=floor(ncell(yearmed$chl)*0.85),
     ylim = c(43.1,46.25),mar=c(1,1,1,4))
DescTools::ColorLegend(x=-62.5,y=46,cols=spm.palette,width=0.25,height=2.9,xpd=NA,
                       labels=chlbreaks[c(1,seq(2,24,2))],title=expression("SPM (g/m"^3*")"))
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=46, "(b)")
dev.off()
