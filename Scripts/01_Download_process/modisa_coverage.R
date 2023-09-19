library(ggplot2)
library(dplyr)
library(stringr)

files <- list.files("./scripts./MODISA/01_Download_process/02_l2_file_coverage/", pattern = "Img_coverage.csv", full.names = T)
csvdata <- list()
for(i in 1:length(files)) {
  d = read.csv(files[i])
  URL = d$URL 
  URL = URL[str_detect(URL,boundary("character"))]
  d$URL <- NULL
  d <- d[str_detect(d$Imgname, boundary("character")),]
  if (nrow(d) != length(URL)) {
    print("LENGTH PROBLEM")
    break
  } else {
    d$URL <- URL
    d <- d %>% distinct() # Added as there were some duplicates sneaking through
    csvdata[[i]] <- d
  }
}
csvdata <- do.call("rbind",csvdata)
csvdata$Npixltot = as.numeric(csvdata$Npixltot)
csvdata$Perccov = as.numeric(csvdata$Perccov)
csvdata$time <- as.POSIXct(str_extract(csvdata$Imgname, pattern = "[0-9]{13}"), format = "%Y%j%H%M%S", tz = "UTC")

csvdata %>% 
  filter(Perccov > 5) %>% 
  mutate(group = round(Perccov,-1)) %>% 
  ggplot(aes(x = group, group = month(time))) +
  geom_bar(aes(fill = as.factor(month(time))))
