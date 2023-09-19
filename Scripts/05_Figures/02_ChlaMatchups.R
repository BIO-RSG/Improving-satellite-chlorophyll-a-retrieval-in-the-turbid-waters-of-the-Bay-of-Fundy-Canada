library(oceancolouR)
library(data.table)
library(dplyr)
library(lmodel2)
library(pals)
library(scales)
options(scipen=5)



setwd("")
sat.dat = read.csv("./Data/ChlaTuning/InputTurnerMedian5x5.csv")
tune.file = read.csv("./Data/ChlaTuning/FinalNewCoefficients.csv")

chl_min <- 0.001
chl_max <- 1000

##Data Cleanup
sat.dat = sat.dat[!is.na(sat.dat$insitu_chla),]
sat.dat = sat.dat[sat.dat$Rrs_443>0, ]
sat.dat = sat.dat[sat.dat$validn>=5,]
sat.dat = sat.dat[sat.dat$COLLECTOR_SAMPLE_ID!=445989, ]#low outlier
##

cf = tune.file[tune.file$model=="No 443",3]
br = log10(sat.dat$Rrs_488/sat.dat$Rrs_547)
sat_chl <- 10^(cf[1] + (cf[2]*br) + (cf[3]*br^2) + (cf[4]*br^3) + (cf[5]*br^4) + (cf[6]*(log10(sat.dat$spm))))
sat_chl[sat_chl < chl_min] <- chl_min
sat_chl[sat_chl > chl_max] <- chl_max

##
rrs_wv <- get_ocx_bands(sensor="modisaqua", use_443nm=T)
rrs <- sat.dat %>% dplyr::select(all_of(sort(unlist(rrs_wv))))
rrs <- as.matrix(rrs)
colnames(rrs) <- sort(unlist(rrs_wv))
old.br = get_br(rrs=rrs, blues=rrs_wv$blues, green=rrs_wv$green, use_443nm=T)$rrs_ocx
rm(rrs,rrs_wv)
##

in.col = rev(brewer.spectral(15))
png("./Figures//ChlMatchup.png",pointsize = 10, width=6.5, height= 6.5, units="in",res=300)
par(mfcol=c(2,1), mgp=c(2.2,1,0), mar=c(1,3.5,1,3.5), family="serif",oma=c(2,0,1,2),xpd=NA)
#ind.col.spm = cut(sat.dat$spm, breaks=c(0,0.1,1,seq(2,10,2),max(sat.dat$spm)))
ind.col.spm = cut(sat.dat$spm, breaks=seq(0,15,1))
ind.col.spm = in.col[ind.col.spm]
#plot(x = old.br, y =sat.dat$insitu_chla, ylim=c(0.01,100),xlim = c(0.1,5),log="xy",
 #    ylab = expression("In situ chl-a (mg/m"^3*")"),
  #   xlab=expression("R"["rs"]*"(λ"["blue"]*") / R"["rs"]*"(λ"["green"]*")"),
   #  col=alpha(ind.col.spm,0.5),pch=19)
#legend(x=0.07,y=100,"(a)", bty="n")
#plot(x =10^br, y =sat.dat$insitu_chla, ylim=c(0.01,100),xlim = c(0.1,5),log="xy",
 #    ylab = expression("In situ chl-a (mg/m"^3*")"),
  #   xlab=expression("R"["rs"]*"(λ"["blue"]*") / R"["rs"]*"(λ"["green"]*")"),
   #  col=alpha(ind.col.spm,0.5),pch=19)
#legend(x=0.07,y=100,"(c)", bty="n")
#par(mar=c(3,1,1,3.5))
plot(x = sat.dat$insitu_chla, y = sat.dat$SatMedianChl, xlim=c(0.01,100), ylim=c(0.01,100),pch=19,
     col=alpha(ind.col.spm,0.5),
     log="xy",xlab = "",ylab = expression("Sat chl-a (mg/m"^3*")"))
legend(x=0.0045,y=100,"(a)", bty="n")
abline(a=0,b=1,lty=2,col="grey",xpd=F)
test <- lmodel2::lmodel2(log10(sat.dat$SatMedianChl) ~ log10(sat.dat$insitu_chla))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlm <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(sat.dat$insitu_chla), y=log10(sat.dat$SatMedianChl)  ),4)
rm(test,tdf)
abline(a = oldlm[1,1], b=oldlm[2,1],xpd=F)
oldlm = round(oldlm,2)
legend("bottomright",legend = c(paste0("Slope = ",oldlm$V1[2]),
                                paste0("Y-intercept = ", oldlm$V1[1]),
                                #paste0("R^2 = ",oldlm$V1[3]),
                                parse(text=paste0('R^2','==',oldlm$V1[3])),
                                paste0("RMSE = ", round(oldrmse,2))), bty="n")
plot(x = sat.dat$insitu_chla, y = sat_chl, xlim=c(0.01,100), ylim=c(0.01,100),pch=19,
     col=alpha(ind.col.spm,0.5),
     log="xy",xlab =expression("In situ chl-a (mg/m"^3*")"),ylab =expression("Sat chl-a (mg/m"^3*")"))
legend(x=0.0045,y=100,"(b)", bty="n")
abline(a=0,b=1,lty=2,col="grey",xpd=F)
test <- lmodel2::lmodel2(log10(sat_chl) ~ log10(sat.dat$insitu_chla))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
newlm <- as.data.frame(t(tdf))
newrmse = round(rmse(x =log10(sat.dat$insitu_chla), y=log10(sat_chl)  ),4)
rm(test,tdf)
abline(a=0,b=1,lty=2,xpd=F)
abline(a = newlm[1,1], b=newlm[2,1],xpd=F)
newlm =round(newlm,2)
legend("bottomright",legend = c(paste0("Slope = ",newlm$V1[2]),
                                paste0("Y-intercept = ", newlm$V1[1]),
                                parse(text=paste0('R^2','==',newlm$V1[3])),
                                #paste0("R^2 = ",newlm$V1[3]),
                                paste0("RMSE = ", round(newrmse,2))), bty="n")
shape::colorlegend(posx = c(0.94, 0.99), left = F, col =in.col, 
                   main=expression("SPM (g/m"^3*")"),
                   zlim = c(0, 15), digit = 0, dz = 3,xpd=NA)  
dev.off()

