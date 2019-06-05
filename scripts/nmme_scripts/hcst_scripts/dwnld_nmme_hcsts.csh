#!/bin/csh
# S. Baker, Aug 2017
# script to download NMME forecats

# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set OutDir = $baseDir/rawNetCDF
set TmpDir = $baseDir/rawGRB
set NMMEarchive = "ftp://ftp.cpc.ncep.noaa.gov/NMME/realtime_anom/ENSMEAN" 

#module load ncl

## download grb file
foreach Year (2017)
  foreach Var (tmp2m prate)
    foreach Mon (01 02 03 04 05 06 07 08)
      foreach model (CFSv2 CMC1 CMC2 GFDL GFDL_FLOR NASA NCAR_CCSM4)
        wget --directory-prefix=$TmpDir/ -nc $NMMEarchive/$Year$Mon'0800'/$Var.$Year$Mon'0800'.$model.ensmean.fcst.1x1.grb
      end
    end
  end
end

## convert to netcdf
foreach File ($TmpDir/*)
  ncl_convert2nc $File -o $OutDir/
end
