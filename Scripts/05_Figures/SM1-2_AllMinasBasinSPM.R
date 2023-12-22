library(pals)
library(scales)
options(scipen=5)
setwd("C:/Users/wilsonkri/Documents/Bay_of_Fundy_2021_part1_Modis/Data/SPMMatchup/")

# 2012 --------------------------------------------------------------------
modis2012 = read.csv("ModisSPM20125x5.csv")
names(modis2012)[1] = "Date" 
modis2012$Date = as.POSIXct(paste0(modis2012$Date, " 15:00:00"), tz="UTC")

marchmodis = modis2012
march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
march.in = which(march.in=="03")
marchmodis = marchmodis[march.in,]

par(mfrow=c(1,3),mar=c(3,3,1,1),mgp=c(2,1,0))
plot(y=modis2012$spm.median, x=modis2012$Date,ylim=c(0,50) )
abline(v=as.Date("2012-03-29"))

spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm = spm[spm$YEAR==2012,]
spm = spm[spm$Depth<15,]
spm$Depth = round(spm$Depth)
#spm = spm[spm$YEAR==2012,]
in.col = alpha(cubicl(3),0.5)
plot(y=spm$SPM[spm$Depth==0],  x=spm$fulldate[spm$Depth==0], xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0,50))#,log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
points(y=spm$SPM[spm$Depth==10],  x=spm$fulldate[spm$Depth==10],pch=19,col=in.col[3])
legend("bottomleft",c("0m","5m","10m"),col=in.col, pch=19)
points(y = modis2012$spm.median[610], x=spm$fulldate[10])
points(y = modis2012$spm.median[611], x=spm$fulldate[10],col="grey")

boxplot(marchmodis$spm.median,xlab="March Median",ylim=c(1,50))

# 2013 --------------------------------------------------------------------
modis2012 = read.csv("ModisSPM20125x5.csv")
names(modis2012)[1] = "Date" 
modis2012$Date = as.POSIXct(paste0(modis2012$Date, " 15:00:00"), tz="UTC")

marchmodis = modis2012
march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
march.in = which(march.in=="03")
marchmodis = marchmodis[march.in,]

par(mfrow=c(1,3),mar=c(3,3,1,1),mgp=c(2,1,0))
plot(y=modis2012$spm.median, x=modis2012$Date,ylim=c(0,50) )
abline(v=as.Date("2012-03-29"))
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm = spm[spm$YEAR==2013,]
spm = spm[spm$Depth<10,]
spm$Depth = round(spm$Depth)
spm$Depth = ifelse(spm$Depth<=3,3, spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5, spm$Depth)
par(mfrow=c(2,3),mar=c(3,3,1,1),mgp=c(2,1,0))
out.coords = matrix(NA, nrow=length(unique(spm$STATION)),ncol=3)
out.coords = as.data.frame(out.coords)
names(out.coords) =c("STATION", "LATITUDE","LONGITUDE" )
for (i in 1:length(unique(spm$STATION))){
  a = unique(spm$STATION)[i]
 spm.p = spm[spm$STATION==a,]
#spm = spm[spm$YEAR==2012,]
in.col = alpha(cubicl(2),0.5)
plot(y=spm.p$SPM[spm.p$Depth==3],  
     x=spm.p$fulldate[spm.p$Depth==3], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(1,105),log="y")
points(y=spm.p$SPM[spm.p$Depth==5],  x=spm.p$fulldate[spm.p$Depth==5],pch=19,col=in.col[2])
legend("bottomright",c("2m","5m"),col=in.col, pch=19,title=a,horiz = T)
out.coords[i,] =c(spm.p$STATION[1] , apply(spm.p[,14:15],2 ,mean,na.rm=T))
}
out.coords.2013=out.coords
points(y = modis2012$spm.median[610], x=spm$fulldate[10])
points(y = modis2012$spm.median[611], x=spm$fulldate[10],col="grey")

boxplot(marchmodis$spm.median,xlab="March Median",ylim=c(1,50))

# 2014 --------------------------------------------------------------------
modis2012 = read.csv("ModisSPM20125x5.csv")
names(modis2012)[1] = "Date" 
modis2012$Date = as.POSIXct(paste0(modis2012$Date, " 15:00:00"), tz="UTC")

marchmodis = modis2012
march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
march.in = which(march.in=="03")
marchmodis = marchmodis[march.in,]

par(mfrow=c(1,3),mar=c(3,3,1,1),mgp=c(2,1,0))
plot(y=modis2012$spm.median, x=modis2012$Date,ylim=c(0,50) )
abline(v=as.Date("2012-03-29"))
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm = spm[spm$YEAR==2014,]
spm = spm[spm$Depth<10,]
spm$Depth = round(spm$Depth)
spm$Depth = ifelse(spm$Depth<=3,1, spm$Depth)
spm$Depth = ifelse(spm$Depth>3,5, spm$Depth)
par(mfrow=c(2,3),mar=c(3,3,1,1),mgp=c(2,1,0))
out.coords = matrix(NA, nrow=length(unique(spm$STATION)),ncol=3)
out.coords = as.data.frame(out.coords)
names(out.coords) =c("STATION", "LATITUDE","LONGITUDE" )
for (i in 1:length(unique(spm$STATION))){
  a = unique(spm$STATION)[i]
  spm.p = spm[spm$STATION==a,]
  #spm = spm[spm$YEAR==2012,]
  in.col = alpha(cubicl(2),0.5)
  plot(y=spm.p$SPM[spm.p$Depth==1],  
       x=spm.p$fulldate[spm.p$Depth==1], 
       xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
       ylim=c(1,105),log="y")
  points(y=spm.p$SPM[spm.p$Depth==5],  x=spm.p$fulldate[spm.p$Depth==5],pch=19,col=in.col[2])
  legend("bottomright",c("2m","5m"),col=in.col, pch=19,title=a,horiz = T)
  out.coords[i,] =c(spm.p$STATION[1] , apply(spm.p[,14:15],2 ,mean,na.rm=T))
}
out.coords.2014=out.coords
out.coords.2013[,2]=as.numeric(out.coords.2013[,2])
out.coords.2013[,3]=as.numeric(out.coords.2013[,3])
out.coords.2014[,2]=as.numeric(out.coords.2014[,2])
out.coords.2014[,3]=as.numeric(out.coords.2014[,3])
a = "ANC3"
tmp.dat = rbind(out.coords.2013[which((out.coords.2013$STATION==a) ==T),],
                out.coords.2014[which((out.coords.2014$STATION==a) ==T),])
tmp.dat = apply(tmp.dat[,2:3],2,"mean")
out.coords.2013[which((out.coords.2013$STATION==a) ==T),2:3] = tmp.dat
a = "ANC4"
tmp.dat = rbind(out.coords.2013[which((out.coords.2013$STATION==a) ==T),],
                out.coords.2014[which((out.coords.2014$STATION==a) ==T),])
tmp.dat = apply(tmp.dat[,2:3],2,"mean")
out.coords.2013[which((out.coords.2013$STATION==a) ==T),2:3] = tmp.dat
a = "ANC1"
tmp.dat = rbind(out.coords.2013[which((out.coords.2013$STATION==a) ==T),],
                out.coords.2014[which((out.coords.2014$STATION==a) ==T),])
tmp.dat = apply(tmp.dat[,2:3],2,"mean")
out.coords.2013[which((out.coords.2013$STATION==a) ==T),2:3] = tmp.dat
#write.csv(out.coords.2013,"./Coords20132014.csv",row.names=F)



# FinalPlots --------------------------------------------------------------
in.col = alpha(cubicl(7),0.5)
coords = read.csv("Coords20132014.csv")
coords[7,] = c("x2012",45.24028 ,-64.26308)
plot(coords[,3:2],col=in.col,pch=19)
legend("bottomright", coords[,1],col=in.col,pch=19,ncol=2)
#Modis data
modis2012 = read.csv("ModisSPM20125x5.csv")
names(modis2012)[1] = "Date" 
modis2012 = modis2012[modis2012$spm.validn>=5,]
modis2012$Date = as.POSIXct(paste0(modis2012$Date, " 15:00:00"), tz="UTC")
anc1 = read.csv("ModisSPM201320145x5-ANC1.csv")
names(anc1)[1] = "Date" 
anc1 = anc1[anc1$spm.validn>=5,]
anc1$Date = as.POSIXct(paste0(anc1$Date, " 15:00:00"), tz="UTC")
anc2 = read.csv("ModisSPM201320145x5-ANC2.csv")
names(anc2)[1] = "Date" 
anc2 = anc2[anc2$spm.validn>=5,]
anc2$Date = as.POSIXct(paste0(anc2$Date, " 15:00:00"), tz="UTC")
anc3 = read.csv("ModisSPM201320145x5-ANC3.csv")
names(anc3)[1] = "Date" 
anc3 = anc3[anc3$spm.validn>=5,]
anc3$Date = as.POSIXct(paste0(anc3$Date, " 15:00:00"), tz="UTC")
anc4 = read.csv("ModisSPM201320145x5-ANC4.csv")
names(anc4)[1] = "Date"
anc4 = anc4[anc4$spm.validn>=5,]
anc4$Date = as.POSIXct(paste0(anc4$Date, " 15:00:00"), tz="UTC")
anc5 = read.csv("ModisSPM201320145x5-ANC5.csv")
names(anc5)[1] = "Date" 
anc5 = anc5[anc5$spm.validn>=5,]
anc5$Date = as.POSIXct(paste0(anc5$Date, " 15:00:00"), tz="UTC")
sc4 = read.csv("ModisSPM201320145x5-SC4.csv")
names(sc4)[1] = "Date" 
sc4 = sc4[sc4$spm.validn>=5,]
sc4$Date = as.POSIXct(paste0(sc4$Date, " 15:00:00"), tz="UTC")
##
par(mfrow=c(4,2),mar=c(3,3,1,1),mgp=c(2,1,0))
plot(y=anc5$spm.median, x=anc5$Date,ylim=c(0.1,200),log="y" ,main="anc5")
plot(y=sc4$spm.median, x=sc4$Date,ylim=c(0.1,200),log="y" ,main="sc4")
plot(y=modis2012$spm.median, x=modis2012$Date,ylim=c(0.1,200),log="y",main="2012" )
plot(y=anc3$spm.median, x=anc3$Date,ylim=c(0.1,200),log="y" ,main="anc3")
plot(y=anc2$spm.median, x=anc2$Date,ylim=c(0.1,200),log="y" ,main="anc2")
plot(y=anc1$spm.median, x=anc1$Date,ylim=c(0.1,200),log="y" ,main="anc1")
plot(y=anc4$spm.median, x=anc4$Date,ylim=c(0.1,200),log="y" ,main="anc4")

#June
png("C:/Users/wilsonkri/Documents/Bay_of_Fundy_2021_part1_Modis//Figures//JuneSPM-SM.png", 
    width=6.5 ,height=6.5,res=300,unit="in", pointsize = 10)
par(mar=c(3,3,1,1),mgp=c(2,1,0),xpd=NA,mfrow=c(3,2),oma=c(0,0.5,0,0),family="serif")
#ANC5
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC5",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),
     pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")#,main="ANC5")
legend("bottomright", bty="n", "(a)")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
#SC4
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="SC4",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(b)")
#ANC3
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC3",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm = spm[spm$MONTH==6,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n",  "(c)")
#ANC2
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC2",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm = spm[spm$MONTH==6,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n",  "(d)")
#ANC1
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC1",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm = spm[spm$MONTH==6,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(e)")
#ANC4
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC4",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm = spm[spm$MONTH==6,]
spm$Depth = ifelse(spm$Depth==3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==6,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomleft",c("2m","5m"),col=in.col, pch=19)
legend("bottomright", bty="n", "(f)")
dev.off()
#March
png("C:/Users/wilsonkri/Documents/Bay_of_Fundy_2021_part1_Modis//Figures//MarchSPM-SM.png", 
    width=6.5 ,height=4.5,res=300,unit="in", pointsize = 10)
par(mar=c(3,3,1,1),mgp=c(2,1,0),xpd=NA,mfrow=c(2,2),oma=c(0,0.5,0,0),family="serif")
#2012
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$YEAR==2012,]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<10,]
spm = spm[spm$MONTH==3,]
spm$Depth = ifelse(spm$Depth==0,2,spm$Depth)
spm$Depth = ifelse(spm$Depth==5,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y",main="")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(a)")
#ANC3
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC3",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<10,]
spm = spm[spm$MONTH==3,]
spm$Depth = ifelse(spm$Depth<3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth>3,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y",main="")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(b)")
#ANC1
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC1",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<15,]
spm = spm[spm$MONTH==3,]
spm$Depth = ifelse(spm$Depth<3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth>3,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y",main=" ")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(c)")
#ANC4
spm = read.csv("EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION=="ANC4",]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<10,]
spm = spm[spm$MONTH==3,]
spm$Depth = ifelse(spm$Depth<3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth>3,5,spm$Depth)
in.col = alpha(cubicl(2),0.5)
plot(y=spm$SPM[spm$Depth==2],  x=spm$fulldate[spm$Depth==2], 
     xlab="Date",ylab=expression("In situ SPM (g/m"^3*")"),pch=19, col=in.col[1],
     ylim=c(0.1,200),log="y",main="")
points(y=spm$SPM[spm$Depth==5],  x=spm$fulldate[spm$Depth==5],pch=19,col=in.col[2])
abline(h=c(1,10),col="grey",lty=2,xpd=F)
legend("bottomright", bty="n", "(d)")
legend("bottomleft",c("2m","5m"),col=in.col, pch=19)
dev.off()


