#library(rnaturalearthhires)
library(rnaturalearth)
#library(rnaturalearthdata)
library(sf)
library(ggplot2)
library(ggspatial)
library(cowplot)
library(terra)
library(pals)
library(gridGraphics)
library(ggplotify)
library(patchwork)
options(scipen=5)

setwd("")
world = ne_countries(scale = 10, returnclass = "sf")
# Bathy map ####
bathycpt <- c(cptcity::cpt("esri_hypsometry_bath_bath_113")[20:100], "#e0f4ff", "#edf9ff")
coast = readRDS("./Data/box_coast_50k.rds")
lonlim <- c(-69.5, -62.5)
latlim <- c(42.75, 46.75)
b <- readRDS("./Data/F_bathymetry_backup.rds")
bathyLon = as.numeric(rownames(b))
bathyLat = as.numeric(colnames(b))
bathyZ = as.numeric(b)
bathyZ[bathyZ>0] <- 0
dim(bathyZ) = dim(b)
bathy <- expand.grid(bathyLon, bathyLat, KEEP.OUT.ATTRS = F, stringsAsFactors = F)
bathy$depth = as.vector(bathyZ)
colnames(bathy) <- c("lon","lat","depth")

bp <- ggplot() +
  geom_tile(data = bathy, aes(x = lon, y = lat, fill = depth)) +
  scale_fill_gradientn("Depth (m)", colours = (bathycpt), limits = c(-1500,0)) +
  geom_sf(data = coast, size = 0.5) +
  # coord_sf(crs = "+proj=lcc +lat_1=62 +lat_2=70 +lat_0=0 +lon_0=-112 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ") #, xlim = lonlim, 
  # ylim = latlim)
  # crs = "+proj=stere +lat_0=62 +lon_0=-112 +datum=NAD83")
  # xlim = lonlim, 
  # ylim = latlim)
  coord_sf(xlim = lonlim, ylim = latlim, expand = F) +
  xlab(NULL) + ylab(NULL) +
  guides(fill = guide_colorbar(barheight =1., barwidth = 13,
                               frame.colour = "black",frame.linewidth = 0.5,
                               ticks.colour = "black")) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         height = unit(0.5, "cm"),
                         width = unit(0.5, "cm"),
                         style = north_arrow_orienteering(text_family = "serif", text_size = 6)) +
  scale_y_continuous(breaks = seq(42.,47,0.5)) +
  scale_x_continuous(breaks = seq(-70, -60,1)) +
  # Labels!
  geom_text(aes(label = "Bay of Fundy", x = -65.7, y = 45.05), colour = "grey20", size = 6, fontface = 3, angle = 33, family = "serif") +# 1 + default, 2 bold, 3 italic, 4 bold italic
  geom_text(aes(label = "Gulf of Maine", x = -68.3, y = 43.25), colour = "grey30", size = 6, fontface = 3, family = "serif") +
  geom_text(aes(label = "Scotian Shelf", x = -63.5, y = 43.75), colour = "grey30", size = 6, fontface = 3, family = "serif") +
  ggrepel::geom_text_repel(aes(label = "Chignecto Bay", x = -64.596, y = 45.671), colour = "grey30", size = 3, fontface = 3, min.segment.length = 0.25, nudge_x = -0.7, nudge_y = 0.05, family = "serif") +
  ggrepel::geom_text_repel(aes(label = "Passamaquoddy\nBay",x = -67.,y = 45), colour = "grey30", size = 3, fontface = 3, min.segment.length = 0.25, nudge_x = -0.7, nudge_y = 0.05, family = "serif") +
  geom_text(aes(label = "Minas Basin", x = -64., y = 45.5), colour = "grey30", size = 3, fontface = 3, family = "serif") +
  geom_text(aes(label = "Northumberland Strait", x = -63.50, y = 46.1), colour = "grey30", size = 3, fontface = 3, angle = -29, family = "serif") +
  # Provinces/States/Etc
  geom_text(aes(label = "Nova Scotia", x = -63.5, y = 45), colour = "grey50", size = 4, family = "serif") +
  geom_text(aes(label = "New Brunswick", x = -66.25, y = 46), colour = "grey50", size = 4, family = "serif") +
  ggrepel::geom_text_repel(aes(label = "Prince Edward\nIsland", x = -63.3511, y = 46.309), colour = "grey50", size = 3, family = "serif", min.segment.length = 0.25, nudge_x = 0.4, nudge_y = 0.3) +
  geom_text(aes(label = "U.S.A", x = -68.75, y = 44.9), colour = "grey50", size = 4, family = "serif") +
  # Islands
  ggrepel::geom_text_repel(aes(label = "Grand Manan\nIsland", x = -66.803,y = 44.708), colour = "grey40", size = 3, min.segment.length = 0.5, nudge_x = -0.1, nudge_y = -0.4, family = "serif") +
  # Cities
  ggrepel::geom_text_repel(aes(label = "Saint John", x = -66.0617,y = 45.27648), colour = "black", size = 3, min.segment.length = 0.5, nudge_x = -0.5, nudge_y = 0.1, family = "serif") +
  geom_point(aes(x = -66.0617,y = 45.27648), colour = "black", size = 2) +
  #theme
  theme(text = element_text(family = "serif"),
        legend.position = "bottom", legend.direction = "horizontal",
        legend.text = element_text(color = "black", size = 8, family = "serif"),
        legend.title = element_text(color = "black", size = 8, family = "serif"),
        axis.text.x = element_text(color = "black", size = 8, family = "serif"),
        axis.text.y = element_text(color = "black", size = 8, family = "serif"),
        axis.title.x = element_text(color = "black", size = 8, family = "serif"),
        axis.title.y = element_text(color = "black", size = 8, family = "serif"),
        panel.border = element_rect(color = "black", fill = NA))  # panel.background = element_rect(fill = NA), # panel.ontop = TRUE) +

#st john river
#bp+geom_curve(aes(x = -66.2, y = 44.5, xend = -65, yend = 45.2),curvature=0,colour = "black",
 #             arrow = arrow(length = unit(0.01, "npc")))
  

save_plot("./Figures//MapLabels.png", plot=bp, base_height = 5.5, base_width =6.5, dpi = 300)
