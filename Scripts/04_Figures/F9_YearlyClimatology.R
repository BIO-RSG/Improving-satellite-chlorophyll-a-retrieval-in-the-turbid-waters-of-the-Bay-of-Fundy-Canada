library(pals)
library(terra)
library(rnaturalearth)

yearmed = rast(c(list.files("Data/Modis/Chla/",pattern="MedianYearly", full.names = T ),
               list.files("Data/Modis/SPM/",pattern="MedianYearly", full.names = T)))
names(yearmed) = c("chl", "spm")

chlbreaks = c(seq(0,1,0.1),seq(2,10,0.5),15,20)#,30,40,50)
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
spmbreaks=c(seq(0,1,0.1),seq(2,10,1),20,30,40,50)
spm.palette = nasa_universal_bluered(length(spmbreaks)-1)
world = ne_countries(scale = 10)
world = vect(world)
world = crop(world, yearmed$chl)
png("./Figures//Figure9.png", width=5 ,height=6.5,res=300,unit="in", pointsize = 10)
par(mfrow=c(2,1),family="serif",oma=c(1,0,0,0))
plot(yearmed$chl,buffer=F,breaks=chlbreaks, col=chl.palette,legend=F,xlim = c(-68.8,-63.1), 
     smooth=F, maxcell=floor(ncell(yearmed$chl)*0.85),
     ylim = c(43.1,46.25),mar=c(1,1,1,4),cex=1)
DescTools::ColorLegend(x=-63.5,y=45.7,cols=chl.palette,width=0.25,height=2.6,xpd=NA,
                      # labels=chlbreaks[c(1,seq(2,24,2))],title=expression("Chl-a (mg/m"^3*")"))
                      labels=chlbreaks[c(1,seq(2,30,2))],title=expression("Chl-a (mg/m"^3*")"),frame="black")
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(a)")
##
plot(yearmed$spm ,buffer=F,breaks=spmbreaks, col=spm.palette,legend=F,xlim = c(-68.8,-63.1), 
     smooth=F, maxcell=floor(ncell(yearmed$chl)*0.85),
     ylim = c(43.1,46.25),mar=c(1,1,1,4))
DescTools::ColorLegend(x=-63.5,y=45.7,cols=chl.palette,width=0.25,height=2.6,xpd=NA,
                       labels=spmbreaks[c(1,seq(2,24,2))],title=expression("SPM (g/m"^3*")"),frame="black")
plot(world,xlim = c(-68.8,-63.1), ylim = c(43.1,46.25),add=T,col="grey85")
text(x=-68.5, y=45.5, "(b)")
dev.off()
