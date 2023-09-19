# This script cross-references the lists of MODISA files to make sure none missed during downloading L2 files
# The L2 files were checked for coverage, then any with > 5% pixel coverage are downloaded as L1A and processed with NIR-SWIR atmospheric correction
# Andrea 2021

library(stringr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(oce)
theme_set(theme_bw())

# 1. Web scraped L2 list: ####
# years <- na.omit(unique(year(metadata$date)))
years <- seq(2003,2020,1)
yearfiles <- list.files("./scripts/MODISA/01_Download_process/01_l2_files/", 
                        pattern = ("download_l2.+csv"), 
                        recursive = T, full.names = T) # the .+ is a regex "and"
yeardata <- list()
# for (j in 1:length(years)) {
#   file <- yearfiles[which(as.numeric(str_extract(yearfiles, pattern = "[0-9]{4}"))==years[j])]
#   yeardata[[j]] <- read.csv(file, header = F)
# }
for (j in 1:length(yearfiles)) {
  yeardata[[j]] <- read.csv(yearfiles[j], header = F)
}
yeardata <- do.call(rbind, yeardata)
yeardata$str <- str_extract(yeardata$V1, pattern = "A[0-9]{13}")
yeardata <- yeardata %>% distinct()
yeardata$Imgname <- yeardata$str

yeardata$dectime <- as.numeric(substr(yeardata$str, 9,10))+(as.numeric(substr(yeardata$str, 11,12))/60)
yeardata$year <- as.numeric(substr(yeardata$str, 2,5))
yeardata %>% filter(year < 2021) %>% 
  ggplot(aes(x = dectime, group = year)) + geom_density()

# 2. L2 COVERAGE - L2 files that have had coverage checked ####
# Load files with "Img_coverage" in the name
donefiles <- list.files("./scripts/MODISA/01_Download_process/02_l2_file_coverage/", "Img_coverage|Img_coverage.+.csv", full.names = T, recursive = T)
print(paste(length(donefiles),"INPUT FILES"))
metadata <- list()
for (i in 1:length(donefiles)) {
  print(i)
  sub <- read.csv(donefiles[i], skip = 2, header = F)
  colnames(sub) <- c("URL", "Imgname", "Npixl", "Npixltot", "Perccov")
  sub <- sub %>% select(-URL) %>% distinct() %>% filter(Imgname != "")
  metadata[[i]] <- sub
}
metadata <- do.call(rbind, metadata)
# CARRIAGE RETURN GETTING INCLUDED ARGH FIX LATER
metadata$URL <- NULL
metadata$Imgname <- stringr::str_trim(metadata$Imgname)
metadata$Npixl <- as.numeric(metadata$Npixl)
metadata$Npixltot <- as.numeric(metadata$Npixltot)
metadata$Perccov <- as.numeric(metadata$Perccov)
metadata <- metadata %>% distinct()
# Find files that were checked twice (IF ANY)
metadata <- metadata %>% group_by(Imgname) %>% mutate(Npixl=max(Npixl,na.rm=T),
                                                           n_checked = n()) %>% 
  ungroup() %>% distinct()
test <- metadata %>% filter(n_checked > 1)

metadata$cat <- if_else(metadata$Npixl < 100, "0-100", 
                        if_else(metadata$Npixl < 1000, "100-1000",
                                if_else(metadata$Npixl < 10000, "1000-10 000", 
                                        if_else(metadata$Npixl < 100000, "10 000-100 000", 
                                                if_else(metadata$Npixl >=100000, "100 000+", NA_character_)))))
metadata$date <- str_sub(metadata$Imgname, 2, -1)
metadata$date <- as.POSIXct(metadata$date, tz = "UTC", format = "%Y%j%H%M%S")

year_list <- yeardata %>% select(Imgname) %>% distinct() %>% mutate(type="Listed")

#plot(metadata$date, metadata$Npixl, col=alpha(1,0.2), pch=20)
test <- metadata$date - lag(metadata$date)
units(test) <- "days"
idx_gap <- which(test > 1)
print(paste(length(idx_gap), "DAYS WITH GREATER THAN 1 DAY GAP"))
days_gap <- data.frame(date1=(metadata$date[idx_gap-1]),date2=metadata$date[idx_gap])

ggplot(data = metadata, aes(x = month(date), fill = as.factor(cat))) + 
  facet_wrap(~year(date)) +
  geom_bar(width = 1, colour = "black") +
  scale_x_continuous(breaks = seq(1,12,1)) +
  labs(fill="Pixels\nin L2 img") 

metadata$dectime <- hour(metadata$date) + (minute(metadata$date)/60)
metadata %>% ggplot(aes(x = dectime, group = year(date))) + geom_density()

# 3 .Missing imgs ####
missing_imgs <- yeardata[!(yeardata$str %in% metadata$Imgname),]
missing_imgs$yr <- substr(missing_imgs$str, 2, 5)
print(paste(nrow(missing_imgs), "IMAGES MISSING, from:"))
print(cat(unique(missing_imgs$yr)))

# Save missing imgs to file
# misyr <- unique(missing_imgs$yr)
# for (iyr in 1:length(misyr)) {
#   sub <- missing_imgs %>% filter(yr == misyr[iyr])
#   sub <- sub %>% select(V1)
#   write.table(sub, file = paste0("AO_",misyr[iyr],"_download_MISSED2.csv"), quote = F, row.names = F, col.names = F)
# }
