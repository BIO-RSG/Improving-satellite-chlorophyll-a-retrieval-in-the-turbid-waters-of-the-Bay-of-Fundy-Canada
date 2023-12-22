library(oceancolouR)
library(data.table)
library(dplyr)
library(lmodel2)
source("./Scripts/04_MatchupsTuning/ChlaOptimize_CV_Boot_Source.R")

# for bootstrapping to test model
library(boot)
library(parallel)
# num_iters is the number of bootstrap iterations for training
# MUST BE LARGER THAN THE NUMBER OF DATA ROWS, or you will get the following error:
#   Error in bca.ci(boot.out, conf, index[1L], L = L, t = t.o, t0 = t0.o,  :
#   estimated adjustment 'a' is NA
# As a precaution, this is updated to max(num_iters, nrow(df)+1))
num_iters <- 2000

# for k-fold CV to test model
library(groupdata2)
library(cvms)
library(doParallel)
k <- 10 # Number of subsets (i.e. train on k-1 sets, test on the remaining set, ...)
# will be adjusted to min(floor(nrow(data)/30), k)
num_fold_cols <- 10 # Number of times dataset is shuffled and divided into k subsets

# Number of CPUs to use in bootstrap parallel processing (will be minimum of num_cl and detectCores()-1)
num_cl <- 2#10


# sensor name (modisaqua or olci) for get_ocx_bands() function below
sensor <- "modisaqua"

# matchup filename (should contain column names "insitu_chla", "spm", and "Rrs_*", where the * is each of the wavebands required for OCx for that sensor)
input_file <- "./Data/ChlaTuning/InputTurnerMedian5x5.csv"

# base for output filenames ("_satchla.csv" and "_trainedparams.csv" will be appended to it)
output_file <- "Data/CrossValidateStats/1to1YesSPM"

# min/max allowed calculated satellite chl (values outside this range will be set to the extremes)
chl_min <- 0.001
chl_max <- 1000


#*******************************************************************************

# Read data and get rid of matchups with invalid in situ chla
df <- fread(input_file)
df <- df[!is.na(df$insitu_chla),]
###added data subsetting for Turner
df = df[df$Rrs_443>0, ]
df = df[df$validn>=5,]
df = df[df$COLLECTOR_SAMPLE_ID!=445989, ]#low outlier
#
#df = df[df$spm>=1,]
#
# Get Rrs bands for OCx/POLY4 with the selected sensor
rrs_wv <- get_ocx_bands(sensor=sensor, use_443nm=F)
rrs <- df %>% dplyr::select(all_of(sort(unlist(rrs_wv))))
rrs <- as.matrix(rrs)
colnames(rrs) <- sort(unlist(rrs_wv))

# Calculate band ratio and add it to the input df
df$bandratio <- get_br(rrs=rrs, blues=rrs_wv$blues, green=rrs_wv$green, use_443nm=F)$rrs_ocx

# Remove NA Rrs and band ratios so training doesn't break
good_inds <- is.finite(df$bandratio) & rowSums(is.finite(rrs))==ncol(rrs)
df <- df[good_inds,]
rrs <- rrs[good_inds,]

# CODE THAT INCLUDES BOOTSTRAPPING AND K-FOLD CV, AND AN OPTI0N TO OPTIMZIE BY LOG RMSE INSTEAD OF FORCING TO 1:1 LINE

which(names(df)== "insitu_chla")
names(df)[12] = "chlorophyll_a"
# Optimize coefficients
#res <- poly4_train(data = df %>% dplyr::select(bandratio, chlorophyll_a))
res <- poly4_train(data = df %>% dplyr::select(bandratio, chlorophyll_a,spm))
cf <- res$coefs
#trained_params <- data.frame(degree=0:4, coef=cf)
trained_params <- data.frame(degree=0:5, coef=cf)
write.csv(trained_params, file=paste0(output_file,"_allcoef.csv"),row.names = F)

# Test model with bootstrapping, save results for future reference
# This will give you confidence intervals for the coefficients
num_cl <- min(num_cl, detectCores()-1)
#bootres <- poly4_train_boot(data = df %>% dplyr::select(bandratio, chlorophyll_a), num_iters = num_iters)
bootres <- poly4_train_boot(data = df %>% dplyr::select(bandratio, chlorophyll_a,spm), num_iters = num_iters)
boot_results <- bootres[[1]]
bootCI <- bootres[[2]]
write.csv(bootCI, file=paste0(output_file,"_bootresultsCI.csv"),row.names = F)
saveRDS(boot_results , file=paste0(output_file,"_bootresults.rds"))

# Test model with k-fold cross-validation, save results for future reference
# This will give you a good measure of the model's overall performance
num_cl <- min(num_cl, detectCores()-1)
cv_results <- poly4_train_kfoldcv(#data = df %>% dplyr::select(bandratio, chlorophyll_a),
                                  data = df %>% dplyr::select(bandratio, chlorophyll_a,spm),
                                  k = k,
                                  num_fold_cols=num_fold_cols,
                                  #stat = kfoldcv_stat,
                                  num_cl = num_cl)
write.csv(cv_results, file=paste0(output_file,"_cvresults.csv"),row.names = F)


# Get the optimized coefs
out.data = poly4_calc(df,cf)
write.csv(out.data, file=paste0(output_file,"_outchla.csv"),row.names = F)
#layout(matrix(c(1,1,1,2),1, 4, byrow = FALSE),widths=c(1,1),  heights=c(1,1))
png(paste0(output_file,"_plot.png"), width=6.5 ,
    height=4,res=300,unit="in", pointsize = 10)
par(mar=c(3,3.5,1,1),mgp=c(2,1,0),family="serif")
plot(y=out.data$SatMedianChl, x = out.data$chlorophyll_a,log="xy",ylim=c(0.01,20),xlim=c(0.01,20),
     col=rgb(1,0,0,0.5),pch=20,
     xlab=expression("In situ Chl-a (mg/m"^3*")"),
     ylab=expression("Satellite situ Chl-a (mg/m"^3*")"))
abline(a=0,b=1,col="grey", lty=2)
points(y=out.data$sat_chla, x =out.data$chlorophyll_a,col=rgb(0,0,1,0.5),pch=20 )
legend("bottomright", c("Original","New"),pch=20,col=c(rgb(1,0,0,0.5),rgb(0,0,1,0.5)))
old = rgrlog10(y=out.data$SatMedianChl, x = out.data$chlorophyll_a)
new = rgrlog10(y=out.data$sat_chla, x = out.data$chlorophyll_a)
tab = rbind(old,new)
tab = t(tab)
tab = tab[c(1:3,5:9),]
tab = cbind(tab,unlist((c(rep(NA,4),cv_results[c(2,3,6,7)]))))
colnames(tab)=c("old", "new","CV")
tab = round(tab,3)
plotrix::addtable2plot(0.008,1.5,tab,bty="o",display.rownames=T,hlines=TRUE, cex=0.8)
plotrix::addtable2plot(0.008,0.008,round(trained_params,3),bty="o",display.rownames=F,hlines=TRUE, cex=0.8)
dev.off()
