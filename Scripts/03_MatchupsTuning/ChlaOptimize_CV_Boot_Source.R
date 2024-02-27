#this code provides the source functions for ChlaOptimize_CV_Boot


# Note that in lmodel2 (the function used to linearly regress the predicted satellite chla
# against the in situ chla for evaluation), the regression method is set to "3" (SMA, Standard Major Axis),
# because this method assumes there can be error in both the independent and dependent variables
# (i.e. in situ and satellite chlorophyll). Instead of trying to minimize the vertical distance 
# between y and x, it tries to minimize the area of the right triangle formed between the point
# and the 1:1 line.

# x = vector of independent values (e.g. in situ chla)
# y = vector of dependent values (e.g. trained satellite chla)
# x and y have already been logged in the poly4_train function
metric_to_minimize_poly4 <- function(x, y) {
  # OPTION 1: use this to force the model to the 1:1 line
  mod <- suppressMessages(lmodel2::lmodel2(y ~ x))$regression.results[3,]
  line <- mod$Slope * x + mod$Intercept
  return(sum((x - line)^2))
  # # OPTION 2: minimize log rmse
  # x <- 10^x
  # y <- 10^y
  # valid_inds <- y > 0 & !is.na(y)
  # return(rmse(log10(y[valid_inds]), log10(x[valid_inds])))
}


#*******************************************************************************
# POLY4 ####

# Optimize coefs without bootstrapping or k-fold cross-validation
# data = dataframe with columns "bandratio" and "chlorophyll_a" (NOT logged)
poly4_train <- function(data) {
  
  # OPTION 1: Optimize coefs without bootstrapping or k-fold cross-validation
  optim_results <- optim(par = c(a0 = 0.3, a1 = -3.8, a2 = -1, a3 = 1, a4 = 1, aspm=1),
                         fn = function (params, x, y,spm) {
                           params <- as.list(params)
                           ypred <- with(params, (a0 + (a1*x) + (a2*x^2) + (a3*x^3) + (aspm* (log10(spm)))))
                           metric <- metric_to_minimize_poly4(y, ypred)
                           return(metric)
                         },
                         x = log10(data$bandratio),
                         y = log10(data$chlorophyll_a),
                         spm = data$spm)
  cf <- as.numeric(optim_results$par)
  
  return(list(coefs=cf, result=optim_results))
  
}


# Optimize coefs with bootstrapping
# data = dataframe with columns "bandratio" and "chlorophyll_a" (NOT logged)
# num_iters = number of bootstrap iterations
poly4_train_boot <- function(data, num_iters) {
  
  num_iters <- max(num_iters, nrow(data)+1)
  
  stat_boot_fn <- function(data, ind) {
    data <- data[ind,]
    optim_results <- optim(par = c(a0 = 0.3, a1 = -3.8, a2 = -1, a3 = 1, a4 = 1, aspm=1),
                           fn = function (params, x, y,spm) {
                             params <- as.list(params)
                             ypred <- with(params, (a0 + (a1*x) + (a2*x^2) + (a3*x^3) + (aspm* (log10(spm)))))
                             metric <- metric_to_minimize_poly4(y, ypred)
                             return(metric)
                           },
                           x = log10(data$bandratio),
                           y = log10(data$chlorophyll_a),
                           spm = data$spm)
    cf <- as.numeric(optim_results$par)
    return(cf)
  }
  
  boot_results <- boot(data = data,
                       statistic = stat_boot_fn,
                       R = num_iters,
                       weights = df$weight,
                       parallel = "multicore",
                       ncpus = num_cl)
  
  # # extract bootstrapped coefficients
  # cf <- colMeans(boot_results$t, na.rm=TRUE)
  
  # extract the confidence intervals (CI) of the coefficients
  bootCI <- lapply(1:length(boot_results$t0), function(i) {boot.ci(boot_results, index=i)}) %>%
    lapply(FUN="[[", "bca") %>%
    lapply(FUN="[", 4:5) %>%
    do.call(what=rbind) %>%
    as.data.frame() %>%
    #dplyr::mutate(degree=paste0("a",0:4), coef=boot_results$t0) %>%
    dplyr::mutate(degree=c(paste0("a",0:4),"aspm"), coef=boot_results$t0) %>%
    dplyr::rename(coef_CI_lower=1, coef_CI_upper=2) %>%
    dplyr::select(degree, coef, coef_CI_lower, coef_CI_upper)
  colnames(bootCI) <- c("degree","coefficient","lower","upper")
  
  return(list(boot_results=boot_results, bootCI=bootCI))
  
}


# Optimize coefs with k-fold cross-validation
# data = dataframe with columns "bandratio" and "chlorophyll_a" (NOT logged)
# num_folds = number of folds in k-fold CV
# stat = type of statistic to calculate final coef over all folds
# how to formulate the code to work with cvms package:
# https://stackoverflow.com/questions/73978623/how-to-implement-k-fold-cross-validation-while-forcing-linear-regression-of-pred
# simple intro to k-fold CV:
# https://machinelearningmastery.com/k-fold-cross-validation/
# cvms vignette - uses repeated k-fold CV:
# https://cran.r-project.org/web/packages/cvms/vignettes/cross_validating_custom_functions.html
poly4_train_kfoldcv <- function(data, k=10, num_fold_cols=10, stat="median", num_cl=1) {
  
  k <- min(floor(nrow(data)/30), k)
  
  registerDoParallel(num_cl)
  do_parallel <- TRUE
  
  # Set seed for reproducibility
  set.seed(2)
  
  # Fold data
  # Will do 10-fold repeated cross-validation (10 reps)
  data <- fold(
    data = data,
    k = k,  # Num folds
    num_fold_cols = num_fold_cols,  # Num times dataset is shuffled and divided into k subsets
    parallel = do_parallel
  )
  
  # Write a model function from your code
  # This ignores the formula and hyperparameters but
  # you could pass values through those if you wanted
  # to try different formulas or hyperparameter values
  model_fn <- function(train_data, formula, hyperparameters){
    out <- optim(par = c(a0 = 0.3, a1 = -3.8, a2 = -1, a3 = 1, a4 = 1, aspm=1),
                 fn = function (params, x, y,spm) {
                   params <- as.list(params)
                   ypred <- with(params, (a0 + (a1*x) + (a2*x^2) + (a3*x^3) + (aspm* (log10(spm)))))
                   library(dplyr)
                   metric_to_minimize_poly4 <- function(x, y) {
                     # OPTION 1: use this to force the model to the 1:1 line
                     mod <- suppressMessages(lmodel2::lmodel2(y ~ x))$regression.results[3,]
                     line <- mod$Slope * x + mod$Intercept
                     return(sum((x - line)^2))
                     # # OPTION 2: minimize log rmse
                     #x <- 10^x
                     #y <- 10^y
                     #valid_inds <- y > 0 & !is.na(y)
                     #return(rmse(log10(y[valid_inds]), log10(x[valid_inds])))
                   }
                   metric <- metric_to_minimize_poly4(y, ypred)
                   return(metric)},
                 x = log10(train_data$bandratio),
                 y = log10(train_data$chlorophyll_a),
                 spm = train_data$spm)
    
    # Convert output to an S3 class
    # so we can extract parameters with coef()
    class(out) <- "OptimModel"
    
    out
  }
  
  # Tell coef() how to extract the parameters
  # This can modified if you need more info from the optim() output
  # Just return a named list
  coef.OptimModel <- function(object) {
    object$par
  }
  
  # Write a predict function from your code
  predict_fn <- function(test_data, model, formula, hyperparameters, train_data){
    cf <- as.numeric(model$par)
    test_data %>%
      dplyr::mutate(
        ypred = 10^(cf[1] + (cf[2]*log10(bandratio)) + (cf[3]*log10(bandratio)^2) + (cf[4]*log10(bandratio)^3) + (cf[5]*log10(bandratio)^4) + (cf[6]*log10(spm)))
      ) %>%
      .[["ypred"]]
  }
  ##
  ##
  rgrlog10 = function(x,y){
    RMSE = round(rmse(x =x, y=y  ),4)
    MAE = Metrics::mae(x,y)
    RAE = Metrics::rae(x,y)
    y = log10(y)
    x = log10(x)
    test = lmodel2::lmodel2(y ~ x)
    tdf = do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) 
    tdf[1:3] = round(tdf[1:3], 4)
    RMSLE = round(rmse(x =x, y=y  ),4)
    tdf = cbind(tdf,RMSE,MAE,RAE,RMSLE)
    return(tdf)
  }
  ##
  cv_results = matrix(NA, nrow=num_fold_cols*k, ncol=9)
  colnames(cv_results)= c("Intercept","Slope", "Rsquared", "pvalue", "num_obs","RMSE","MAE","RAE","RMSLE")
  cv_results = as.data.frame(cv_results)
  cv_results=as.list(matrix(NA, nrow=1, ncol=9))
  for (i in 1:k){
    for(j in 1:num_fold_cols){
      test_set = data[,c(1:3,j+3)]
      test_set = test_set[test_set[,4]==i,]
      train_set = data[,c(1:3,j+3)]
      train_set = train_set[train_set[,4]!=i,]
      chl_model = model_fn(train_set)
      prd_chl = predict_fn(test_set,chl_model)
      xy = rgrlog10(x = test_set$chlorophyll_a, y=prd_chl)
      #
     # png(paste0("Out/cvSPM/i_",i,"_j_",j,".png"),width = 4.5,height=4.5,units="in",res=300)
      #par(mar=c(3,3,1,1),mgp=c(2,1,0),family="serif")
      #in.col = rev(pals::brewer.spectral(15))
      #ind.col.spm = cut(test_set$spm, breaks=seq(0,15,1))
      #ind.col.spm = in.col[ind.col.spm]
      #plot(x = test_set$chlorophyll_a, y=prd_chl,log="xy",xlim=c(0.05,50), ylim=c(0.05,50),
       #    ylab = expression("Sat chl-a (mg/m"^3*")"), xlab=expression("In situ chl-a (mg/m"^3*")"),
        #   col=scales::alpha(ind.col.spm,0.8),pch=20, main= paste0("i = ", i," j = ",j," spm = ", round(max(test_set$spm),1)))
      #legend("bottomright",legend= c(paste0("R^2=", round(xy$Rsquared,2)),paste0("RMSLE = ", round(xy$RMSLE,2))),bty="n")
      #abline(a=0,b=1,col="grey",lty=2)
      #abline(b=xy$Slope, a=xy$Intercept)
      #dev.off()
      #
      cv_results = list(cv_results,xy)
    }
  }
  cv_results= matrix(unlist(cv_results), ncol=9,byrow=T)
  cv_results=cv_results[-1,]
  colnames(cv_results)= c("Intercept","Slope", "Rsquared", "pvalue", "num_obs","RMSE","MAE","RAE","RMSLE")
  #write.csv(cv_results,"Scripts/Revisions/Out/cvnoSPM/cvresults.csv",row.names = F)
  #cv_results_out = apply(cv_results,2,"mean")
  #cv_results_out2 = apply(cv_results,2,"sd")
  #boxplot(cv_results[,c(1:3,7,9)])
  
  ##

  return(cv_results)
  
}

poly4_calc = function(df,cf){
  # Add optimized sat_chl to dataframe
  br <- log10(df$bandratio)
  sat_chl <- 10^(cf[1] + (cf[2]*br) + (cf[3]*br^2) + (cf[4]*br^3) + (cf[5]*br^4) + (cf[6]*log10(df$spm))) # with spm term
  #sat_chl <- 10^(cf[1] + (cf[2]*br) + (cf[3]*br^2) + (cf[4]*br^3) + (cf[5]*br^4)) # without spm term
  sat_chl[sat_chl < chl_min] <- chl_min
  sat_chl[sat_chl > chl_max] <- chl_max
  df <- df %>% dplyr::mutate(sat_chla=sat_chl)
  return(df)
}
rgrlog10 = function(x,y){
  RMSE = round(rmse(x =x, y=y  ),4)
  MAE = Metrics::mae(x,y)
  RAE = Metrics::rae(x,y)
  y = log10(y)
  x = log10(x)
  test = lmodel2::lmodel2(y ~ x)
  tdf = do.call(dplyr::bind_cols, oceancolouR::get_lm_stats(test,method="SMA")) 
  tdf[1:3] = round(tdf[1:3], 4)
  RMSLE = round(rmse(x =x, y=y  ),4)
  tdf = cbind(tdf,RMSE,MAE,RAE,RMSLE)
  return(tdf)
}
