## Improving satellite chlorophyll-a retrieval in the turbid waters of the Bay of Fundy, Canada

Wilson KL, Hilborn A, Clay S, Devred E (2023) Improving satellite chlorophyll-a retrieval in the turbid waters of the Bay of Fundy, Canada (In prep) Estuaries and Coasts

This project focused on improving chl-a and SPM retrieval in the Bay of Fundy.

The yearly and seasonal climatology layers are hosted on Open Data at:

Please contact for daily composites

## MODIS-Aqua Processing Steps

There are a bunch of scripts here for the MODISA processing. Rather than having one script that downloads and processes all the images in one go, I've found it a bit easier to troubleshoot by breaking it into separate scripts (and you can run multiple steps simultaneously to save time).

There are a lot of details to keep track of though, so here is a general workflow:

1. We download [L1A images](https://oceancolor.gsfc.nasa.gov/products/) in order to control details like atmospheric correction and spatial resolution. These are processed in SeaDAS using the "l2gen" program
2. Downloading and processing the L1A files is slow, and many end up having no "good" data after they're processed (from clouds, to a lesser degree sun glint, etc.), so we check the images already processed by NASA first. We assume that if their image has no data (even though it was processed a bit differently and at 1km resolution), it's safe to assume we shouldn't bother spending time processing it
3. So once we have a list of images where we know at least a small area of the ocean surface is visible, we download and process them. You may ask *"Isn't this a bunch of work to essentially make a "cloud coverage" value like what Sentinel-2 has?"*, and the answer is *"Yes"*
4. Once the images are processed, some further products are calculated from the Rrs, and they're all regridded onto a common grid and merged into a daily composite
5. All further processing occured using the regridded daily composites at 300 m spatial resolution

References for in situ data used in this study:
1. [BIOCHEM](https://www.dfo-mpo.gc.ca/science/data-donnees/biochem/index-eng.html): Devine, L., M. K. Kennedy, I. St-Pierre, C. Lafleur, M. Ouellet, and S. Bond. 2014. BioChem: the Fisheries and Oceans Canada database for biological and chemical data. Can. Tech. Rep. Fish. Aquat. Sci. 3073: iv + 40 p.
2. Western Isles phytoplankton monitoring program: Martin, J. L., M. M. Legresley, and M. E. Gidney. 2014. Phytoplankton monitoring in the Western Isles region of the Bay of Fundy during 2007-2013. Can. Tech. Rep. Fish. Aquat. Sci. 3105: v + 262 p.
3. Zions, V. S., B. A. Law, C. O. Laughlin, K. J. Morrison, A. Drozdowski, G. L. Bugden, and S. Roach. 2017. Spatial and temporal characteristics of water column and seabed sediment samples from Minas Basin, Bay of Fundy. Can. Tech. Rep. Fish. Aquat. Sci. 3233: vi + 95.
4. Horne, E., and B. Law. 2013. Cruise report Hudson 2013013 Minas Basin June 4 - 16, 2013.
