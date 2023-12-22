library(pals)
library(scales)
options(scipen = 5)
#
oc3 = read.csv("./Data/ChlaFocusAreas/P5modisOC3matchups.csv")
oc3 = oc3[,-1]
oc3 = apply(oc3, 2, median, na.rm=T)
m2 = read.csv("./Data/ChlaFocusAreas/P5modism2matchups.csv")
m2= m2[,-1]
m2 = apply(m2, 2, median, na.rm=T)

modis.date=as.Date(unlist(strsplit(names(oc3), "X"))[seq(2,length(names(oc3))*2,2)],format="%Y.%m.%d")

plot.dat = data.frame("oc3" = oc3,"m2"=m2, "modisdate" = modis.date)
plot.dat = plot.dat[which(apply(plot.dat[,1:2] ,1, sum, na.rm=T)>0),]
plot.dat$YEAR = unlist(strsplit(as.character(plot.dat$modisdate), "-"))[seq(1, dim(plot.dat)[1]*3,3)]
plot.dat$MONTH = as.numeric(unlist(strsplit(as.character(plot.dat$modisdate), "-"))[seq(2, dim(plot.dat)[1]*3,3)])
rm(oc3,m2,modis.date)


p5 = read.csv("./Data/Insitu/MergeFinalChlaturner.csv")
p5 = p5[which(p5$COLLECTOR_STATION_NAME %in% c( "P5" ,"Prince 5","Prince_5" ,"Prince5" )==T),]
p5 = p5[p5$START_DEPTH<=10,]
p5 = p5[p5$LATITUDE<44.95,]
p5 = p5[p5$YEAR>=2003,]
p5$Date = as.Date(p5$Date)

png("./Figures//Figure8.png", width=6.5 ,height=6.5,res=300,unit="in", pointsize = 10)
nf=layout(matrix(c(1,2,3,4,4,4,5,5,5),byrow=T,nrow=3))
par(mar=c(2,3,1,1),mgp=c(2,1,0),oma=c(0,0.5,0,0),family="serif",xpd=NA)
boxplot(list(p5$DATA_VALUE[p5$MONTH==1],
             p5$DATA_VALUE[p5$MONTH==2],
             p5$DATA_VALUE[p5$MONTH==3],
             p5$DATA_VALUE[p5$MONTH==4],
             p5$DATA_VALUE[p5$MONTH==5],
             p5$DATA_VALUE[p5$MONTH==6],
             p5$DATA_VALUE[p5$MONTH==7],
             p5$DATA_VALUE[p5$MONTH==8],
             p5$DATA_VALUE[p5$MONTH==9],
             p5$DATA_VALUE[p5$MONTH==10],
             p5$DATA_VALUE[p5$MONTH==11],
             p5$DATA_VALUE[p5$MONTH==12]),
        xlab="", ylab=expression("In situ chl-a (mg/m"^3*")"),pch=20, ylim=c(0.05,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
legend("topleft", "(a)",bty="n")
#OCX
boxplot(list(plot.dat$oc3[plot.dat$MONTH==1],
             plot.dat$oc3[plot.dat$MONTH==2],
             plot.dat$oc3[plot.dat$MONTH==3],
             plot.dat$oc3[plot.dat$MONTH==4],
             plot.dat$oc3[plot.dat$MONTH==5],
             plot.dat$oc3[plot.dat$MONTH==6],
             plot.dat$oc3[plot.dat$MONTH==7],
             plot.dat$oc3[plot.dat$MONTH==8],
             plot.dat$oc3[plot.dat$MONTH==9],
             plot.dat$oc3[plot.dat$MONTH==10],
             plot.dat$oc3[plot.dat$MONTH==11],
             plot.dat$oc3[plot.dat$MONTH==12]),
        xlab="", ylab=expression("Satellite chl-a (mg/m"^3*")"),pch=20, ylim=c(0.05,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
legend("topleft", "(b)",bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
#m2
boxplot(list(plot.dat$m2[plot.dat$MONTH==1],
             plot.dat$m2[plot.dat$MONTH==2],
             plot.dat$m2[plot.dat$MONTH==3],
             plot.dat$m2[plot.dat$MONTH==4],
             plot.dat$m2[plot.dat$MONTH==5],
             plot.dat$m2[plot.dat$MONTH==6],
             plot.dat$m2[plot.dat$MONTH==7],
             plot.dat$m2[plot.dat$MONTH==8],
             plot.dat$m2[plot.dat$MONTH==9],
             plot.dat$m2[plot.dat$MONTH==10],
             plot.dat$m2[plot.dat$MONTH==11],
             plot.dat$m2[plot.dat$MONTH==12]),
        xlab="", ylab=expression("Satellite chl-a (mg/m"^3*")"),pch=20, ylim=c(0.05,100),log="y",
        xaxt="n",xaxs="i",yaxs="i")
axis(1, at=c(1:12), labels=c("Jan","Feb","Mar","Apr","May","June","July",
                             "Aug","Sept","Oct","Nov","Dec"))
legend("topleft", "(c)",bty="n")
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
##
plot(y= plot.dat$oc3 , x= plot.dat$modisdate, xlab="",
     ylab=expression("chl-a (mg/m"^3*")"),pch=20, ylim=c(0.05,100), log="y",col=alpha(cubicl(8)[3]),yaxs="i")
points(x=p5$Date, y=p5$DATA_VALUE,pch=20, col=alpha(cubicl(8)[8]))
legend("topright",legend=c("OC3M", "In situ"), col= c(cubicl(8)[3],cubicl(8)[8]),pch=20,horiz=T)
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
legend("topleft", "(d)",bty="n")
##
plot(y= plot.dat$m2 , x= plot.dat$modisdate, xlab="",ylab=expression("chl-a (mg/m"^3*")"),
     pch=20, ylim=c(0.05,100), log="y",col=alpha(cubicl(8)[3]),yaxs="i")
points(x=p5$Date, y=p5$DATA_VALUE,pch=20, col=alpha(cubicl(8)[8]))
legend("topright",
  legend=c(expression('OC'[X-SPMCor]*''), "In situ"), 
       col= c(cubicl(8)[3],cubicl(8)[8]),pch=20,horiz=T)
abline(h=c(0.1,1,10),lty=2, col="grey",xpd=F)
legend("topleft", "(e)",bty="n")
dev.off()


