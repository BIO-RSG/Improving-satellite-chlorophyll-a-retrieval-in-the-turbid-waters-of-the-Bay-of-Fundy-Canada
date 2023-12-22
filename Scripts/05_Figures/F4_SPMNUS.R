library(oceancolouR)
library(data.table)
library(dplyr)
library(lmodel2)
library(pals)
library(scales)
options(scipen=5)

sat.dat = read.csv("./Data/SPMNUS/ModisSPM.csv")
##Data Cleanup
sat.dat = sat.dat[sat.dat$validn>=5,]

in.col = rev(brewer.spectral(15))
png("./Figures//Figure4.png",pointsize = 10, width=6.5, height= 3.5, units="in",res=300)
par(mgp=c(2.2,1,0), mar=c(3,4,1,1), family="serif",xpd=NA)
plot(x = sat.dat$DATA_VALUE , y = sat.dat$median, xlim=c(0.01,100), ylim=c(0.01,100),pch=19,
     log="xy",xlab = expression("In situ SPM (g/m"^3*")"),ylab = expression("Satellite (g/m"^3*")"))

abline(a=0,b=1,lty=2,col="grey",xpd=F)
test <- lmodel2::lmodel2(log10(sat.dat$median) ~ log10(sat.dat$DATA_VALUE))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlm <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(sat.dat$DATA_VALUE), y=log10(sat.dat$median)  ),4)
rm(test,tdf)
abline(a = oldlm[1,1], b=oldlm[2,1],xpd=F)
oldlm = round(oldlm,2)
a = oldlm$V1[3]
legend("bottomright",legend = c(paste0("Slope = ",oldlm$V1[2]),
                                paste0("Y-intercept = ", oldlm$V1[1]),
                                #paste0(expression("R"^2*""),oldlm$V1[3]),
                                parse(text=paste0('R^2','==',a)),
                            
                                paste0("RMSLE = ", round(oldrmse,2))), bty="n")

dev.off()

