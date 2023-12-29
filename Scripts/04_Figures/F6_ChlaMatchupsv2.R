library(oceancolouR)
library(dplyr)
library(lmodel2)
library(pals)
library(scales)
library(plotrix)
options(scipen=5)

sat.dat = read.csv("./Data/ChlaTuning/ModisChlaturner5x5m2.csv")
oc3.dat = read.csv("./Data/ChlaTuning/ModisChlaturner5x5oc3.csv")
spm.dat = read.csv("./Data/ChlaTuning/ModisChlaturner-spmpoints.csv")
spm.dat = spm.dat[,c("COLLECTOR_SAMPLE_ID","median")]
names(spm.dat)[2]="spm"
sat.dat = merge(y=sat.dat, x= spm.dat, by="COLLECTOR_SAMPLE_ID")
oc3.dat = merge(y=oc3.dat, x= spm.dat, by="COLLECTOR_SAMPLE_ID")

in.col = rev(brewer.spectral(15))
png("./Figures//Figure6.png",pointsize = 10, width=6.5, height= 6.5, units="in",res=300)
par(mfcol=c(2,1), mgp=c(2.2,1,0), mar=c(1,3.5,1,0.1),#3.5), 
    family="serif",oma=c(2,0,1,0.1),xpd=NA)
ind.col.spm = cut(oc3.dat$spm, breaks=seq(0,15,1))
ind.col.spm = in.col[ind.col.spm]
plot(NULL ,xlim=c(0.05,50), ylim=c(0.05,50),pch=19,log="xy",xlab = "",ylab = expression("Sat chl-a (mg/m"^3*")"))
plotCI(x = oc3.dat$DATA_VALUE, y = oc3.dat$median, sfrac=0,pch=19,col=alpha(ind.col.spm,0.5),
       uiw = oc3.dat$mad,liw = oc3.dat$mad, add=T,lwd=1.5)
legend(x=0.05,y=50,"(a)", bty="n")
abline(a=0,b=1,lty=2,col="grey",xpd=F)
test <- lmodel2::lmodel2(log10(oc3.dat$median) ~ log10(oc3.dat$DATA_VALUE))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlm <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(oc3.dat$DATA_VALUE), y=log10(oc3.dat$median)  ),4)
rm(test,tdf)
abline(a = oldlm[1,1], b=oldlm[2,1],xpd=F)
##
ind.col.spm = cut(sat.dat$spm, breaks=seq(0,15,1))
ind.col.spm = in.col[ind.col.spm]
plot(NULL ,xlim=c(0.05,50), ylim=c(0.05,50),pch=19,log="xy",
     xlab = expression("In situ chl-a (mg/m"^3*")"),ylab = expression("Sat chl-a (mg/m"^3*")"))
plotCI(x = sat.dat$DATA_VALUE, y = sat.dat$median, sfrac=0,pch=19,col=alpha(ind.col.spm,0.5),
       uiw = sat.dat$mad,liw = sat.dat$mad, add=T,lwd=1.5,xpd=F)
legend(x=0.05,y=50,"(b)", bty="n")
abline(a=0,b=1,lty=2,col="grey",xpd=F)
test <- lmodel2::lmodel2(log10(sat.dat$median) ~ log10(sat.dat$DATA_VALUE))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlm <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(sat.dat$DATA_VALUE), y=log10(sat.dat$median)  ),4)
rm(test,tdf)
abline(a = oldlm[1,1], b=oldlm[2,1],xpd=F)
##
shape::colorlegend(posx = c(0.90, 0.94),
                   posy = c(0.04, 0.6),
                   left = F, col =in.col, 
                   main=expression("SPM (g/m"^3*")"),
                   zlim = c(0, 15), digit = 0, dz = 3,xpd=NA)  
dev.off()

