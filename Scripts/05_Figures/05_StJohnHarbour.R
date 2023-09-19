library(pals)
library(scales)
options(scipen = 5)
setwd(" ")
#
oc3 = read.csv("./Data/StJohnHarbour/OCXOuter.csv")
oc3 = oc3[,-1]
oc3 = oc3[,-1]
a= apply(oc3, 2, sum, na.rm=T)
a=which(a>0)
oc3 = oc3[,a]
m2 = read.csv("./Data/StJohnHarbour/M2Outer.csv")
m2= m2[,-1]
m2= m2[,-1]
m2=m2[,a]
insitu = read.csv("./Data/StJohnHarbour/Matchup15kmOuter.csv")
insitu$Date = as.Date(insitu$Date)

#Median
m2.med = apply(m2, 2, median, na.rm=T)
oc3.med = apply(oc3, 2, median, na.rm=T)
modis.date=as.Date(unlist(strsplit(names(oc3), "X"))[seq(2,length(names(oc3))*2,2)],format="%Y.%m.%d")
plot.dat.med = data.frame("oc3" = oc3.med,"m2"=m2.med, "modisdate" = modis.date)
plot.dat.med$YEAR = unlist(strsplit(as.character(plot.dat.med$modisdate), "-"))[seq(1, dim(plot.dat.med)[1]*3,3)]
plot.dat.med$MONTH = as.numeric(unlist(strsplit(as.character(plot.dat.med$modisdate), "-"))[seq(2, dim(plot.dat.med)[1]*3,3)])
rm(m2.med,oc3.med,modis.date)

png("./Figures//StJohnHarbour.png", width=6.5 ,height=4.5,res=300,unit="in", pointsize = 10)
#nf=layout(matrix(c(1,2,3,4,4,4,5,5,5),byrow=T,nrow=3))
nf=layout(matrix(c(1,2,3,4,4,4),byrow=T,nrow=2))
par(mar=c(2,3,1,1),mgp=c(2,1,0),oma=c(0,0.5,0,0),family="serif",xpd=NA)
boxplot(list(insitu$DATA_VALUE[insitu$MONTH==1],
             insitu$DATA_VALUE[insitu$MONTH==2],
             insitu$DATA_VALUE[insitu$MONTH==3],
             insitu$DATA_VALUE[insitu$MONTH==4],
             insitu$DATA_VALUE[insitu$MONTH==5],
             insitu$DATA_VALUE[insitu$MONTH==6],
             insitu$DATA_VALUE[insitu$MONTH==7],
             insitu$DATA_VALUE[insitu$MONTH==8],
             insitu$DATA_VALUE[insitu$MONTH==9],
             insitu$DATA_VALUE[insitu$MONTH==10],
             insitu$DATA_VALUE[insitu$MONTH==11],
             insitu$DATA_VALUE[insitu$MONTH==11]),
        xlab="", ylab=expression("In situ chl-a (mg/m"^3*")"),pch=20, ylim=c(0.03,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
legend("topleft", "(a)",bty="n")
#OCX
boxplot(list(plot.dat.med$oc3[plot.dat.med$MONTH==1],
             plot.dat.med$oc3[plot.dat.med$MONTH==2],
             plot.dat.med$oc3[plot.dat.med$MONTH==3],
             plot.dat.med$oc3[plot.dat.med$MONTH==4],
             plot.dat.med$oc3[plot.dat.med$MONTH==5],
             plot.dat.med$oc3[plot.dat.med$MONTH==6],
             plot.dat.med$oc3[plot.dat.med$MONTH==7],
             plot.dat.med$oc3[plot.dat.med$MONTH==8],
             plot.dat.med$oc3[plot.dat.med$MONTH==9],
             plot.dat.med$oc3[plot.dat.med$MONTH==10],
             plot.dat.med$oc3[plot.dat.med$MONTH==11],
             plot.dat.med$oc3[plot.dat.med$MONTH==11]),
        xlab="", ylab=expression("Satellite chl-a (mg/m"^3*")"),pch=20, ylim=c(0.03,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
legend("topleft", "(b)",bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
#m2
boxplot(list(plot.dat.med$m2[plot.dat.med$MONTH==1],
             plot.dat.med$m2[plot.dat.med$MONTH==2],
             plot.dat.med$m2[plot.dat.med$MONTH==3],
             plot.dat.med$m2[plot.dat.med$MONTH==4],
             plot.dat.med$m2[plot.dat.med$MONTH==5],
             plot.dat.med$m2[plot.dat.med$MONTH==6],
             plot.dat.med$m2[plot.dat.med$MONTH==7],
             plot.dat.med$m2[plot.dat.med$MONTH==8],
             plot.dat.med$m2[plot.dat.med$MONTH==9],
             plot.dat.med$m2[plot.dat.med$MONTH==10],
             plot.dat.med$m2[plot.dat.med$MONTH==11],
             plot.dat.med$m2[plot.dat.med$MONTH==11]),
        xlab="", ylab=expression("Satellite chl-a (mg/m"^3*")"),pch=20, ylim=c(0.03,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
legend("topleft", "(c)",bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
#plot(y= plot.dat.med$oc3 , x= plot.dat.med$modisdate, xlab="",ylab=expression("chl-a (mg/m"^3*")"),
 #    pch=20, ylim=c(0.03,100), log="y",col=alpha(cubicl(8)[3]),yaxs="i")
#points(x=insitu$Date, y=insitu$DATA_VALUE,pch=20, col=alpha(cubicl(8)[8]))
#legend("topright",legend=c("OCX", "In situ"), col= c(cubicl(8)[3],cubicl(8)[8]),pch=20,horiz=T)
#abline(h=c(0.1,1,10),lty=2, col="grey")
#legend("topleft", "(d)",bty="n")
plot(y= plot.dat.med$m2 , x= plot.dat.med$modisdate, xlab="",ylab=expression("chl-a (mg/m"^3*")"),
     pch=20, ylim=c(0.03,100), log="y",col=alpha(cubicl(8)[3]),yaxs="i")
points(x=insitu$Date, y=insitu$DATA_VALUE,pch=20, col=alpha(cubicl(8)[8]))
legend("topright",
       legend=c(expression('OC'[X-SPMCor]*''), "In situ"), 
       col= c(cubicl(8)[3],cubicl(8)[8]),pch=20,horiz=T)
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
legend("topleft", "(d)",bty="n")
dev.off()