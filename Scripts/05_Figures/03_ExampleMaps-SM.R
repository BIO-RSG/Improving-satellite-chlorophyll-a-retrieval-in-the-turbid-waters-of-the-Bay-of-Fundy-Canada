library(pals)
library(terra)
library(hexbin)
#library(rnaturalearth)
options(scipen = 5)
setwd("")
#world = ne_countries(scale = 10)
#world = vect(world)
##
modis = rast(c("./Data/Modis/DailyComposites/OCX/A2016278_chloc3_v3.tif",
           "./Data/Modis/DailyComposites/OCX-SPM/A2016278_chloc3m2_v3.tif",
           "./Data/Modis/DailyComposites/Nechad/A2016278_spmnec_v3.tif"))
names(modis) = c("ocx", "ocx.spm", "spm")
modis = values(modis,df=T, na.rm=T)




X =  modis[,3]
Y   = modis[,1]
data   =data.frame(X, Y)
##
test <- lmodel2::lmodel2(log10(Y) ~ log10(X))
library(dplyr)
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlmb <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(X), y=log10(Y)  ),4)
oldlm2 = data.frame(paste0(c(row.names(oldlmb),"RMSE"), " = ", c(oldlmb$V1,oldrmse)))
colnames(oldlm2) = "Statistics"
rm(test,tdf)
library(scico)
library(ggpp)
library(gridExtra)
p1 = ggplot(data, aes(x=X, y=Y)) + stat_binhex(bins=80)+scale_x_log10(limits=c(0.001,50)) +scale_y_log10(limits=c(0.001,50))+
  scale_fill_gradientn(colours=c("#EEEEEE",rev(scico(10, palette = 'roma'))), na.value="#000000FF")+
  theme_bw()+labs(y = expression("chl-a (mg/m"^3*")"), x =expression("SPM (g/m"^3*")"))+
  geom_abline(aes(slope=oldlmb$V1[2],intercept=oldlmb$V1[1],col="Regression"))+
  geom_abline(aes(slope=1, intercept=0, colour="1:1"),lty=2)+
  scale_color_manual(values=c("black","black"), name=" ")+
  guides(colour = guide_legend(override.aes = list(linetype = c(5,1))))+
  annotate(geom = "table", x = 1, y = 0.1, label = list(oldlm2), 
           vjust = 1, hjust = 0)+theme(text = element_text(color = "black", size = 10, family = "serif"))

X =  modis[,3]
Y   = modis[,2]
data   =data.frame(X, Y)
##
test <- lmodel2::lmodel2(log10(Y) ~ log10(X))
tdf <- do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) %>% dplyr::select(-pvalue)
tdf[1:3] = round(tdf[1:3], 4)
oldlm <- as.data.frame(t(tdf))
oldrmse = round(rmse(x =log10(X), y=log10(Y)  ),4)
oldlm3 = data.frame(paste0(c(row.names(oldlm),"RMSE"), " = ", c(oldlm$V1,oldrmse)))
colnames(oldlm3) = "Statistics"
rm(test,tdf)

p2 = ggplot(data, aes(x=X, y=Y)) + stat_binhex(bins=80)+scale_x_log10(limits=c(0.001,50)) +scale_y_log10(limits=c(0.001,50))+
  scale_fill_gradientn(colours=c("#EEEEEE",rev(scico(10, palette = 'roma'))), na.value="#000000FF")+
  theme_bw()+labs(y = expression("chl-a (mg/m"^3*")"), x =expression("SPM (g/m"^3*")"))+
  geom_abline(aes(slope=oldlm$V1[2],intercept=oldlm$V1[1],col="Regression"))+
  geom_abline(aes(slope=-1, intercept=0, colour="1:1"),lty=2)+
  scale_color_manual(values=c("black","black"), name=" ")+
  guides(colour = guide_legend(override.aes = list(linetype = c(5,1))))+
  annotate(geom = "table", x = .001, y = 0.1, label = list(oldlm3), 
           vjust = 1, hjust = 0)+theme(text = element_text(color = "black", size = 10, family = "serif"))


library(cowplot)
png("./Figures//DailyHexBinSuppl.png",pointsize = 10, width=6.5, height= 6.5, units="in",res=300)  
plot_grid(p1, p2, nrow=2, ncol=1, labels=c("(a)","(b)"),label_size = 9,
              label_x = 0.15, label_y = 0.9, label_fontface ="plain",label_fontfamily = "serif" )
  
dev.off()



