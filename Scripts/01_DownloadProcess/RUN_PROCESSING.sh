#!/bin/bash

# Sequence:

# 1. Use NASA l2 files as a proxy for coverage 
Rscript 01_GetL2Filenames_MODISA.R
bash 01_DownloadL2.sh # Will work without this but will be slower

# 2. 
bash 02_DownloadL1A.sh
