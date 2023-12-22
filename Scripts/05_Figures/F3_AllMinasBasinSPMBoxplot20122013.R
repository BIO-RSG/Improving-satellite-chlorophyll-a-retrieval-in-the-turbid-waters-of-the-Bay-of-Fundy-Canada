library(pals)
library(scales)
options(scipen=5)
##
modis2012 = read.csv("Data/MinasBasinSPM/ModisSPM20125x5.csv")
names(modis2012)[1] = "Date" 
modis2012 = modis2012[modis2012$spm.validn>=5,]
modis2012$Date = as.POSIXct(paste0(modis2012$Date, " 15:00:00"), tz="UTC")
anc1 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-ANC1.csv")
names(anc1)[1] = "Date" 
anc1 = anc1[anc1$spm.validn>=5,]
anc1$Date = as.POSIXct(paste0(anc1$Date, " 15:00:00"), tz="UTC")
anc2 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-ANC2.csv")
names(anc2)[1] = "Date" 
anc2 = anc2[anc2$spm.validn>=5,]
anc2$Date = as.POSIXct(paste0(anc2$Date, " 15:00:00"), tz="UTC")
anc3 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-ANC3.csv")
names(anc3)[1] = "Date" 
anc3 = anc3[anc3$spm.validn>=5,]
anc3$Date = as.POSIXct(paste0(anc3$Date, " 15:00:00"), tz="UTC")
anc4 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-ANC4.csv")
names(anc4)[1] = "Date"
anc4 = anc4[anc4$spm.validn>=5,]
anc4$Date = as.POSIXct(paste0(anc4$Date, " 15:00:00"), tz="UTC")
anc5 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-ANC5.csv")
names(anc5)[1] = "Date" 
anc5 = anc5[anc5$spm.validn>=5,]
anc5$Date = as.POSIXct(paste0(anc5$Date, " 15:00:00"), tz="UTC")
sc4 = read.csv("Data/MinasBasinSPM/ModisSPM201320145x5-SC4.csv")
names(sc4)[1] = "Date" 
sc4 = sc4[sc4$spm.validn>=5,]
sc4$Date = as.POSIXct(paste0(sc4$Date, " 15:00:00"), tz="UTC")
##
png("./Figures//Figure3.png", 
    width=6.5 ,height=6.5,res=300,unit="in", pointsize = 10)
par(mar=c(1,3.5,1,1),mgp=c(2,1,0),mfrow=c(2,1),oma=c(2,0,0,0),family="serif")
#
getjuneinsitu = function(station = "ANC4"){
  spm = read.csv("Data/Insitu/EdMinasBasin20112014.csv")
  spm = spm[spm$Confidence=="High",]
  spm = spm[spm$STATION==station,]
  spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
  spm$Depth = round(spm$Depth)
  spm = spm[spm$Depth<15,]
  spm = spm[spm$MONTH==6,]
   return(spm$SPM)}
anc5.insitu =getjuneinsitu(station = "ANC5")
anc3.insitu =getjuneinsitu(station = "ANC3")
anc2.insitu =getjuneinsitu(station = "ANC2")
anc1.insitu =getjuneinsitu(station = "ANC1")
anc4.insitu =getjuneinsitu(station = "ANC4")
sc4.insitu =getjuneinsitu(station = "SC4")
##
getjune20132013 = function(marchmodis){
  march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
  march.in = which(march.in=="06")
  out.dat = marchmodis[march.in,]
  if (length(out.dat[,1])>0){
    march.in = unlist(strsplit(as.character(out.dat$Date),"-"))[seq(1,length(out.dat[,1])*3,3)]
    march.in1 = which(march.in=="2012")
    march.in2 = which(march.in=="2013")
    march.in3 = which(march.in=="2014")
    march.in = c (march.in1, march.in2,march.in3)
    out.dat = out.dat[march.in,]
  }
  return(out.dat)}
p5 = getjune20132013(anc5)
s4 = getjune20132013(sc4)
p3 = getjune20132013(anc3)
p2 = getjune20132013(anc2)
p1 = getjune20132013(anc1)
p4 = getjune20132013(anc4)
p2012 = getjune20132013(modis2012)
#
##
getjuneall = function(marchmodis){
  march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
  march.in = which(march.in=="06")
  out.dat = marchmodis[march.in,]
  return(out.dat)}
p5all = getjuneall(anc5)
s4all = getjuneall(sc4)
p3all = getjuneall(anc3)
p2all = getjuneall(anc2)
p1all = getjuneall(anc1)
p4all = getjuneall(anc4)
p2012all = getjuneall(modis2012)
#
in.col = alpha(cubicl(3),0.5)
boxplot(list(s4$spm.median,  s4all$spm.median, sc4.insitu,
             p5$spm.median,  p5all$spm.median,anc5.insitu, 
             p2012$spm.median, p2012all$spm.median,0,
             p3$spm.median,  p3all$spm.median, anc3.insitu,
             p1$spm.median,  p1all$spm.median,anc1.insitu,
             p2$spm.median,  p2all$spm.median,anc2.insitu,
             p4$spm.median,  p4all$spm.median,anc4.insitu),
        ylim=c(0.01,200),log="y",
        col=in.col,pch=20,
        ylab=expression("SPM (g/m"^3*")"),xaxt="n")
for (i in seq(0.5,24.5,6)){
  polygon(x=c(i,i+3,i+3,i), y=c(0.001,0.001,500,500), col=rgb(0,0,0,0.05),border=NA)}
legend("topleft", "(a)",bty="n")
abline(h=c(1,10),col="grey",lty=2)
##March
spm = read.csv("Data/Insitu/EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$YEAR==2012,]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<10,]
spm = spm[spm$MONTH==3,]
s2012.insitu = spm$SPM
#ANC1
getmarchinsitu = function(station = "ANC4"){
  spm = read.csv("Data/Insitu/EdMinasBasin20112014.csv")
spm = spm[spm$Confidence=="High",]
spm = spm[spm$STATION==station,]
spm$fulldate = as.POSIXct(paste0(spm$YEAR, "-", spm$MONTH,"-", spm$DAY, " ",spm$Time.UTC), tz="UTC")
spm$Depth = round(spm$Depth)
spm = spm[spm$Depth<10,]
spm = spm[spm$MONTH==3,]
spm$Depth = ifelse(spm$Depth<3,2,spm$Depth)
spm$Depth = ifelse(spm$Depth>3,5,spm$Depth)
return(spm$SPM)}
anc3.insitu =getmarchinsitu(station = "ANC3")
anc1.insitu =getmarchinsitu(station = "ANC1")
anc4.insitu =getmarchinsitu(station = "ANC4")
###
getmarch20132013 = function(marchmodis){
  march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
  march.in = which(march.in=="03")
  out.dat = marchmodis[march.in,]
  if (length(out.dat[,1])>0){
  march.in = unlist(strsplit(as.character(out.dat$Date),"-"))[seq(1,length(out.dat[,1])*3,3)]
  march.in1 = which(march.in=="2012")
  march.in2 = which(march.in=="2013")
  march.in3 = which(march.in=="2014")
  march.in = c (march.in1, march.in2,march.in3)
  out.dat = out.dat[march.in,]
  }
  return(out.dat)}
p2012 = getmarch20132013(marchmodis = modis2012)
p3 = getmarch20132013(marchmodis = anc3)
p1 = getmarch20132013(marchmodis = anc1)
p4 = getmarch20132013(marchmodis = anc4)
p2 = getmarch20132013(marchmodis = anc2)
p5 = getmarch20132013(marchmodis = anc5)
s4 = getmarch20132013(marchmodis = sc4)
###
getmarchall = function(marchmodis){
  march.in = unlist(strsplit(as.character(marchmodis$Date),"-"))[seq(2,length(marchmodis[,1])*3,3)]
  march.in = which(march.in=="03")
  out.dat = marchmodis[march.in,]
  return(out.dat)}
p2012all = getmarchall (marchmodis = modis2012)
p3all = getmarchall(marchmodis = anc3)
p1all = getmarchall(marchmodis = anc1)
p4all = getmarchall(marchmodis = anc4)
p2all = getmarchall(marchmodis = anc2)
p5all = getmarchall(marchmodis = anc5)
s4all = getmarchall(marchmodis = sc4)
##
boxplot(list(s4$spm.median,s4all$spm.median,0,
             p5$spm.median,p5all$spm.median,0,
             p2012$spm.median, p2012all$spm.median, s2012.insitu,
             p3$spm.median, p3all$spm.median, anc3.insitu,
             p1$spm.median,p1all$spm.median,anc1.insitu,
             p2$spm.median,p2all$spm.median,0,
             p4$spm.median,p4all$spm.median,anc4.insitu),
        ylim=c(0.01,200),log="y", col=in.col,pch=20,
        ylab=expression("SPM (g/m"^3*")"), xaxt="n")
  axis(1, c(  "SC4","ANC5","A5", "ANC3","ANC1", "ANC2", "ANC4"), at=seq(2,20.5,3))
for (i in seq(0.5,20.5,6)){
polygon(x=c(i,i+3,i+3,i), y=c(0.001,0.001,500,500), col=rgb(0,0,0,0.05),border=NA)}
legend("topleft", "(b)",bty="n")
abline(h=c(1,10),col="grey",lty=2)
#abline(v=seq(0.5,15.5,2))
legend("bottomright", c("Satellite (2012-2014)","Satellite (2003-2021)", "In situ (2012-2014)"), fill=in.col)
dev.off()



