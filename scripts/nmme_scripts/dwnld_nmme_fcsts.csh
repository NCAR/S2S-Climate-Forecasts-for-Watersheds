#!/bin/csh
# S. Baker, Aug 2017
# script to download NMME forecats

set yyyymm = $1 #201708

# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set OutDir = $baseDir/rawNetCDF
set TmpDir = $baseDir/rawGRB
set NMMEarchive = "ftp://ftp.cpc.ncep.noaa.gov/NMME/realtime_anom/ENSMEAN" 

#module load ncl

## download grb file and convert to netCDF
foreach Var (tmp2m prate)
  foreach model (CFSv2 CMC1 CMC2 GFDL GFDL_FLOR NASA NCAR_CCSM4)
    wget --directory-prefix=$TmpDir/ -nc $NMMEarchive/$yyyymm'0800'/$Var.$yyyymm'0800'.$model.ensmean.fcst.1x1.grb
    ncl_convert2nc $TmpDir/$Var.$yyyymm'0800'.$model.ensmean.fcst.1x1.grb -o $OutDir/
  end
end
