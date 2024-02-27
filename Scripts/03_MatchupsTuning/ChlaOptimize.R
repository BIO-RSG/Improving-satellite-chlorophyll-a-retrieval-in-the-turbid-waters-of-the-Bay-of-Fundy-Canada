library(oceancolouR)
library(data.table)
library(dplyr)
library(lmodel2)
options(scipen=5)

##
#this code will optimize the polynomial coefficients of OCx-SPMCor based on your in situ data set
#This does not perform any validation or bootstrapping

#*******************************************************************************
# VARIABLES TO CHANGE

# sensor name (modisaqua or olci) for get_ocx_bands() function below
sensor <- "modisaqua"

# matchup filename (should contain column names "insitu_chla", "spm", and "Rrs_*", where the * is each of the wavebands required for OCx for that sensor)
input_file <- "./Data/ChlaTuning/InputTurnerMedian5x5.csv"


# base for output filenames ("_satchla.csv" and "_trainedparams.csv" will be appended to it)
output_file <- "modisaqua_ocx_bof"

# min/max allowed calculated satellite chl (values outside this range will be set to the extremes)
chl_min <- 0.001
chl_max <- 1000


#*******************************************************************************

# Read data and get rid of matchups with invalid in situ chla
df <- fread(input_file)
df <- df[!is.na(df$insitu_chla),]
df = df[df$Rrs_443>0, ]
df = df[df$validn>=5,]
df = df[df$COLLECTOR_SAMPLE_ID!=445989, ]#low outlier
##


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

##

# Optimize coefficients using band ratio + an extra SPM term
term <- c("a0","a1","a2","a3","a4","aspm")
optim_results <- optim(par = c(a0=0.3, a1=-3.8, a2=-1, a3=1, a4=1, aspm=1),
                       fn = function (params, x, y, spm) {
                           params <- as.list(params)
                           ypred <- with(params, (a0 + (a1*x) + (a2*x^2) + (a3*x^3) + (a4*x^4) + (aspm* (log10(spm)))))
                           mod <- suppressMessages(lmodel2(ypred ~ y))$regression.results[3,]
                           line <- mod$Slope * y + mod$Intercept
                           return(sum((y-line)^2))
                       },
                       x = log10(df$bandratio),
                       y = log10(df$insitu_chla),
                       spm = df$spm)

# Get the optimized coefs
cf <- as.numeric(optim_results$par)
trained_params <- data.frame(term=term, coef=cf)
br <- log10(df$bandratio)
sat_chl <- 10^(cf[1] + (cf[2]*br) + (cf[3]*br^2) + (cf[4]*br^3) + (cf[5]*br^4) + (cf[6]*(log10(df$spm))))
               
# sat_chl <- 10^(cf[1] + (cf[2]*br) + (cf[3]*br^2) + (cf[4]*br^3) + (cf[5]*br^4)) # without spm term
sat_chl[sat_chl < chl_min] <- chl_min
sat_chl[sat_chl > chl_max] <- chl_max
df <- df %>% dplyr::mutate(sat_chla=sat_chl)

#