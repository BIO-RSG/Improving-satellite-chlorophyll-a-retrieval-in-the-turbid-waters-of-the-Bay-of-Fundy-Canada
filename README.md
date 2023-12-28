## Improving satellite chlorophyll-a retrieval in the turbid waters of the Bay of Fundy, Canada

Wilson KL, Hilborn A, Clay S, Devred E (2023) Improving satellite chlorophyll-a retrieval in the turbid waters of the Bay of Fundy, Canada (In prep) Estuaries and Coasts

This project focused on improving chl-a and SPM retrieval in the Bay of Fundy.

The yearly and seasonal climatology layers are hosted on Open Data at:

Please contact for daily composites

### MODIS-Aqua Image Processing Steps:

MODIS-Aqua [L1A images](https://oceancolor.gsfc.nasa.gov/resources/docs/product-levels/) are downloaded from the NASA [Ocean Biology Processing Group](https://oceancolor.gsfc.nasa.gov/) and processed with [SeaDAS](https://seadas.gsfc.nasa.gov/) `l2gen`. Using this level and program the atmospheric correction and resolution details can be customized. Once the images are atmospherically corrected, further products are calculated from the Remote-sensing reflectance (*R<sub>rs</sub>*), regridded onto a common grid, and merged into daily composites. All further analysis occured using the regridded daily composites at 300 m spatial resolution.

#### Level-2 file pre-filtering
`01_get_l2_file_names_modisa.R`: Get filenames
`02_download_L2.sh`: Download L2 files and check spatial coverage. Remove if less than 5% of data available (using 555 nm band). Uses `00_Check_nb_pixel_in_image.R`
`03_L1A_filenames_to_download.sh` and `04_download_L1A.sh`: gets L1A filenames from L2 filenames and downloads.
`05_L1A_to_L3.sh`: Processes images in SeaDAS with `l2gen_swir_mumm.sh`. Uses `02_filter_computespm_v3.py` to apply masks and do further filtering. Includes new chl-a algorithm and other output products written to ASCII. Then uses GMT to grid to NetCDF in a given bounding box, and `Make_daily_composites_modisa_v3.R` to grid to daily composites.


### References for in situ data used in this study:

1. [BIOCHEM](https://www.dfo-mpo.gc.ca/science/data-donnees/biochem/index-eng.html): Devine, L., M. K. Kennedy, I. St-Pierre, C. Lafleur, M. Ouellet, and S. Bond. 2014. BioChem: the Fisheries and Oceans Canada database for biological and chemical data. Can. Tech. Rep. Fish. Aquat. Sci. 3073: iv + 40 p.
2. Western Isles phytoplankton monitoring program: Martin, J. L., M. M. Legresley, and M. E. Gidney. 2014. [Phytoplankton monitoring in the Western Isles region of the Bay of Fundy during 2007-2013.](https://publications.gc.ca/collections/collection_2014/mpo-dfo/Fs97-6-3105-eng.pdf) Can. Tech. Rep. Fish. Aquat. Sci. 3105: v + 262 p.
3. Zions, V. S., B. A. Law, C. O. Laughlin, K. J. Morrison, A. Drozdowski, G. L. Bugden, and S. Roach. 2017. [Spatial and temporal characteristics of water column and seabed sediment samples from Minas Basin, Bay of Fundy.](https://publications.gc.ca/collections/collection_2018/mpo-dfo/Fs97-6-3233-eng.pdf) Can. Tech. Rep. Fish. Aquat. Sci. 3233: vi + 95.
4. Horne, E., and B. Law. 2013. [Cruise report Hudson 2013013 Minas Basin June 4 - 16, 2013.](https://fern.acadiau.ca/tl_files/sites/fern/Files%202013/Hudson%202013-013%20Crusie%20Report_BayofFundy_Final.pdf)
