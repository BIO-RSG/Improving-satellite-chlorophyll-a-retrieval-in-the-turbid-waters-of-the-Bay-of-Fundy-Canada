# Get lists of files by searching the NASA earthdata site in a bounding box and over a time period
# LOOP 1: Scrape files in a bounding box and metadata (no coverage meta yet)
# LOOP 2: Filter files to daytime, sun above horizon, other time filt if wanted.
# Andrea Hilborn 2021

library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(lubridate)
library(oce)

###### BOUNDING BOX & YEARS ######
minlat=43.1
maxlat=46.2
minlon=-68.8
maxlon=-63.1

minyear = 2003
maxyear = 2021

dataset = "MODISA_L1" # Other options are here https://cmr.earthdata.nasa.gov/search/site/collections/directory/OB_DAAC/gov.nasa.eosdis
# NOTE! We downloaded MODISA_L2_OC first, and filtered out images with zero coverage. However the R2018 data is no longer available in CMR search. R2022 is available, but with the new filenaming convention that no longer matches the L1A convention.

#########

# Query CMR Search for files in each year ####
for (i in minyear:maxyear) {
  pagenum = 1
  mindate = paste0(i,"-01-01")
  maxdate = paste0(i,"-12-31")
  message(paste(mindate, maxdate))
  # Loop through all pages available
  while(pagenum > 0) {
    # Get files in date range and bounding box
    url = paste0("https://cmr.earthdata.nasa.gov/search/granules.csv?provider=OB_DAAC&short_name=",dataset,
                 "&bounding_box=",
                 minlon,",",minlat,",",maxlon,",",maxlat,
                 "&temporal=",mindate,",",maxdate,
                 "&page_size=2000&page_num=", pagenum)
    #print(url)
    res = GET(url)
    data = (rawToChar(res$content))
    data <- unlist(str_split(data,pattern = "\n"))
    # If there are results on the page, save to file
    if (nchar(data[[2]]) > 1) {
      # Save to file
      filename=paste0("BF","_",i,"_",minlon,"_",maxlon,"_",minlat,"_",maxlat,"_page",pagenum,"_raw.csv")
      message(filename)
      write.csv(x = data, file = paste0("./",filename), quote = F, row.names = F)
      pagenum = pagenum+1
    } else {
      pagenum = 0
    }
    # cat(pagenum)
    cat("...")
  }
}

# Once files downloaded, read in and check time, sun angle ####
yearfilelist <- list.files("./", "raw.csv", full.names = T)
for (i in minyear:maxyear) {
  yearlist <- yearfilelist[grep(i,yearfilelist)]
  yearfiles <- list()
  for (j in 1:length(yearlist)) {
    yearfiles[[j]] <- read.csv(yearlist[j], skip=1)
  }
  yearfiles <- do.call(rbind, yearfiles)
  message(paste(nrow(yearfiles),"files found in year",i))
  yearfiles$Start.Time <- ymd_hms(yearfiles$Start.Time, tz = "UTC")
  yearfiles$time <- format(yearfiles$Start.Time, format="%H:%M:%S")
  # Calculating rough sun angle, remove img if below threshold
  yearfiles$altitude <- sunAngle(yearfiles$Start.Time, 
                                      longitude = mean(c(minlon, maxlon)), #at center longitude
                                      latitude = mean(c(minlat, maxlat)) )$altitude # at center latitude
  yearfiles <- yearfiles %>% filter(altitude > 0)
  # Filtering only to day files - might be redundant / not necessary after altitude filter if altitude not > 0
  yearfiles <- yearfiles %>% filter(Day.Night == "DAY")
  # Day of year/month of year constraints (if wanted):
  # yearfiles <- yearfiles %>% filter(month(Start.Time) > 2, month(Start.Time)<11)
  
  img_urls <- yearfiles$Online.Access.URLs
  
  # Print out list of L2 files to download
  filename=paste0("BF","_",i,"_download_L1A.csv")
  message(filename)
  message(paste(nrow(yearfiles), "files remaining"))
  write.table(img_urls, file = paste0("./",filename), quote = F, row.names = F, col.names = F)
}
