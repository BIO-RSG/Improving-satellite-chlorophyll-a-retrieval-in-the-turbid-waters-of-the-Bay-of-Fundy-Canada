#!/bin/bash

# Sequence:

# 1. Use NASA l2 files as a proxy for coverage 
Rscript 01a_GetL2Filenames_MODISA.R
bash 01b_DownloadL2.sh # Will work without this but will be slower

# 2. Download L1A images
bash 02_DownloadL1A.sh

# 3. Process to daily composites of SPM and Chl-a
bash 03_L1A_to_L3.sh
