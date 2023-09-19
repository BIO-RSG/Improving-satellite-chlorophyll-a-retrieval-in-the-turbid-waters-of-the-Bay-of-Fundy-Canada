# Emmanuel Devred Nov 2019
# Modified Feb 2020 Andrea
# Modified Sept 2021 Andrea

# Pass arguments to define box area in image to check

library(ncdf4)

##First read in the arguments listed at the command line
args=(commandArgs(TRUE))
print(args)
#print(length(args))
##args is now a list of character vectors
## First check to see if arguments are passed.
## Then cycle through each element of the list and evaluate the expressions.
if(length(args) <= 4){
  print("Not enough arguments supplied.")
} else if (length(args) == 5) {
  for (i in 1:length(args)) {
    l2 = as.character(args[1])
    lonmax = as.numeric(args[2])
    lonmin = as.numeric(args[3])
    latmax = as.numeric(args[4])
    latmin = as.numeric(args[5])
  }
}

ncfile <- nc_open(l2)
latitude <- ncvar_get(ncfile,"navigation_data/latitude")
longitude <- ncvar_get(ncfile,"navigation_data/longitude")
Rrs555 <- ncvar_get(ncfile, "geophysical_data/Rrs_555")
#tilt <- ncvar_get(ncfile, "navigation_data/tilt")
nc_close(ncfile)

nbvalpxl = sum(is.finite(Rrs555) & longitude > lonmin & longitude < lonmax &
                 latitude > latmin & latitude < latmax, na.rm=T)
nbpxltot = sum(longitude > lonmin & longitude < lonmax &
                 latitude > latmin & latitude < latmax, na.rm=T)
perccov = nbvalpxl/nbpxltot*100

write.table(c(nbvalpxl,nbpxltot,perccov),"nbvalpxl.asc",col.names = F,row.names = F,quote = F)
