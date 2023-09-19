#library(rnaturalearthhires)
library(rnaturalearth)
#library(rnaturalearthdata)
library(sf)
library(ggplot2)
library(ggspatial)
library(cowplot)
library(terra)
library(pals)
library(gridGraphics)
options(scipen=5)

setwd("")
world = ne_countries(scale = 10, returnclass = "sf")
spm.data = read.csv("./Data/Insitu/MergeFinalSPM.csv")
spm.data = spm.data[spm.data$METHOD!="StAndrew",]
spm.data$Date =as.Date(paste0(spm.data$YEAR, "-", spm.data$MONTH,"-",spm.data$DAY))
spm.data2 = read.csv("./Data/SPMMatchup/Coords20132014.csv")
spm.data2$DATA_VALUe=1
spm.data = merge(spm.data2,spm.data,all=T)
spm.shp = vect(spm.data, geom=c( "LONGITUDE","LATITUDE"),crs = crs(world,proj=T))
spm.shp = st_as_sf(spm.shp)
chl.data = read.csv("./Data/Insitu/MergeFinalChlaturner.csv") 
chl.data$Date =as.Date(chl.data$Date)
chl.shp = vect(chl.data, geom=c( "LONGITUDE","LATITUDE"),crs = crs(world,proj=T))
chl.shp = st_as_sf(chl.shp)
chl.data.hplc = read.csv("./Data/Insitu/MergeFinalChlahplc.csv") 
chl.data.hplc$Date =as.Date(chl.data.hplc$Date)
chl.shp.hplc = vect(chl.data.hplc, geom=c( "LONGITUDE","LATITUDE"),crs = crs(world,proj=T))
chl.shp.hplc = st_as_sf(chl.shp.hplc)
##NS Map

ns.map = ggplot(data = world)+ 
  geom_sf() +
  labs( x = "Longitude", y = "Latitude") +
  coord_sf(xlim = c(-68.8,-63.1), ylim = c(43.1,46.25), expand = FALSE) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         height = unit(0.5, "cm"),
                         width = unit(0.5, "cm"),
                         #pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_orienteering(text_family = "serif", text_size = 6)) +
  theme_bw()  + theme(axis.text.x = element_text(color = "black", size = 8, family = "serif"),
                          axis.text.y = element_text(color = "black", size = 8, family = "serif"),
                          axis.title.x = element_text(color = "black", size = 8, family = "serif"),
                          axis.title.y = element_text(color = "black", size = 8, family = "serif"))
ns.map =ns.map+geom_sf(data=chl.shp,shape=1,aes(color =c("Turner chl-a"))) +
  geom_sf(data=chl.shp.hplc,shape=19,aes(color ="HPLC chl-a"))+
  geom_sf(data=spm.shp,shape=17,aes(color ="SPM"))+
    coord_sf(xlim = c(-68.8,-63.1), ylim = c(43.1,46.25), expand = FALSE)+
  scale_color_manual(name='In Situ Data',
                     breaks=c('Turner chl-a', 'HPLC chl-a', 'SPM'),
                     values=c('Turner chl-a'=rgb(1,0.753,0.796,0.75), 'HPLC chl-a'=rgb(0,0,1,0.75), 'SPM'=rgb(1,0.647,0,0.75)),
                     guide = guide_legend(override.aes = list( shape = c(1,19,17))))+
  theme(legend.position = "right", legend.text = element_text(color = "black", size = 8, family = "serif"),
        legend.title = element_text(color = "black", size = 8, family = "serif"))
spm.data = read.csv("./Data/Insitu/MergeFinalSPM.csv") 
spm.data$Date =as.Date(paste0(spm.data$YEAR, "-", spm.data$MONTH,"-",spm.data$DAY))
spm.data = spm.data[spm.data$DATA_VALUE>0,]
spm.data = spm.data[spm.data$METHOD!="StAndrew",]
spm.data2 = read.csv("./Data/SPMMatchup/EdMinasBasin20112014.csv")
spm.data2 = spm.data2[spm.data2$Confidence=="High",]
spm.data2 = spm.data2[spm.data2$Depth<10,]
abc = function(){
par(mar=c(1,3,0,0.5),mgp=c(2,1,0),mfrow=c(1,3),oma=c(2,0,0,0),xpd=F,family="serif")
#par(mar=c(1,3,1,0.5),mgp=c(2,1,0),mfrow=c(3,1),oma=c(2,0,0,0),xpd=F,family="serif")
plot(y=chl.data$DATA_VALUE, x=chl.data$MONTH, col=cubicl(20)[chl.data$YEAR-2001], 
     #ylab=bquote("In situ chl-a (" * mg/m^3 * ")"), 
     ylab=expression("In situ chl-a (mg/m"^3*")"),
     xlab="Month", pch=20, ylim=c(0.05,200),log="y",
     xlim =c(1,12),xaxt="n",yaxs="i",xpd=NA)
axis(1, at=c(1:12),labels=c("Jan","","Mar","","May","","July","","Sept","","Nov",""))
#legend("top", legend=2002:2021, col=cubicl(20),pch=20, ncol=10,bty="n",cex=0.9)
legend(x=0.2,y=100,  "(b)", bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey")
plot(y=chl.data.hplc$DATA_VALUE, x=chl.data.hplc$MONTH, col=cubicl(20)[chl.data$YEAR-2001], 
     #ylab=bquote("In situ chl-a (" * mg/m^3 * ")"), 
     ylab=expression("In situ chl-a (mg/m"^3*")"),
     xlab="Month", pch=20, ylim=c(0.05,200),log="y",
     xlim =c(1,12),xaxt="n",yaxs="i",xpd=NA)
legend(x=0.2,y=100,  "(c)", bty="n")
axis(1, at=c(1:12),labels=c("Jan","","Mar","","May","","July","","Sept","","Nov",""))
abline(h=c(0.1,1,10),lty=2, col="grey")
#
plot(y=spm.data$DATA_VALUE, x=spm.data$MONTH, col=cubicl(20)[spm.data$YEAR-2001], 
     xlab="Month", #ylab=bquote("In situ SPM (" * g/m^3 * ")"),
     ylab=expression("In situ SPM (g/m"^3*")"),
     pch=20, ylim=c(0.05,200),
     log="y",
     xlim =c(1,12),xaxt="n",yaxs="i",xpd=NA)
points(y=spm.data2$SPM, x =spm.data2$MONTH,col=cubicl(20)[spm.data2$YEAR-2001], 
       xlab="Month", 
       #ylab=bquote("In situ SPM (" * g/m^3 * ")"),
       pch=20, 
       xlim =c(1,12),xaxt="n",yaxs="i",xpd=NA)
axis(1, at=c(1:12),labels=c("Jan","","Mar","","May","","July","","Sept","","Nov",""))
legend(x=0.2,y=100, "(d)", bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey")
}
library(ggplotify)
library(patchwork)
lgl = function(){
  library(plotrix)
  par(mar=c(0.2,0,0.2,0),mfrow=c(1,3),family="serif")
  plot.new()#(1,1, main='', axes=FALSE)
  plot.new()#emptyPlot(1,1, main='', axes=FALSE)
  color.legend(0.2,
               0.4,
               0.9,
               1,
               legend = c(2002,2021),cubicl(20),gradient="x",align="rb",cex=0.8)
  plot.new()#emptyPlot(1,1, main='', axes=FALSE)
}
##
png("./Figures//MapInsitu.png",pointsize = 10, width=6.5, height= 5, units="in",res=300)
#plot_grid(ns.map, abc, nrow=1, ncol=2, rel_widths = c(3,3.5))
a=plot_grid(ns.map, abc, nrow=2, ncol=1, labels=c("(a)",""),label_size = 9,
            label_x = 0.12, label_y = 0.9, label_fontface ="plain",label_fontfamily = "serif" )
plot_grid(a, lgl,nrow=2, rel_heights = c(0.92,0.08))
a = a+ theme(plot.background = element_rect(fill = "white"))#, rel_widths = c(3,3.5))
dev.off()
save_plot("./Figures//MapInsitu.png", plot=a, base_height = 6, base_width = 6.5,dpi=300)
