#!/bin/csh
# S. Baker, Aug 2017
# script to regrid NMME timeseries forecast
# file to 0.5x0.5 degree; rename dimensions
# and variables; cut to CONUS domain

# load modules
module load nco
module load cdo
module load python
module load netcdf4python
module load numpy

# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set rawDir = $baseDir/rawNetCDF
set gridDir = $baseDir/regrid
set TmpDir = $baseDir/tmp
set renameDir = $baseDir/rename
set cutDir = $baseDir/nc_CONUS
set HucDir = $baseDir/HUC_fcst
set scripts = /home/hydrofcst/s2s/scripts/nmme_scripts

# ------------------------

# loop through variables and get data for year supplied
foreach Var (tmp2m prate)

  # rename GFDL and GFDL_FLOR files to regrid with cdo
  foreach File ($rawDir/$Var.*1x1.nc) 
        set output = $gridDir/$File:t:r.nc
        ncrename -d lat_3,lat -d lon_3,lon -d forecast_time0,time -v lat_3,lat -v lon_3,lon -v forecast_time0,time $File $TmpDir/$File:t:r.nc
        cdo remapbil,r720x360 $TmpDir/$File:t:r.nc $output
  end

  # rename files and cut
  foreach File ($gridDir/$Var.*1x1.nc)
        set nm_out = $renameDir/$File:t:r.nc
        set output = $cutDir/$File:t:r.nc

        # rename variables and dimensions - need to check this works
        if ($Var == tmp2m) then
          ncrename -d time,t -v TMP_3_HTGL_ave1m,tmp2m -v time,fcst_time -v lat,latitude -v lon,longitude $File $nm_out
        else
          ncrename -d time,t -v PRATE_3_SFC_ave1m,prate -v time,fcst_time -v lat,latitude -v lon,longitude $File $nm_out
        endif

        # CONUS domain - 5,75N 185,305E
        ncea -d lat,190,329 -d lon,370,609 $nm_out $output
  end

  # loop over each file in the raw year directory
  foreach File ($cutDir/$Var.*1x1.nc)
    python $scripts/poly2poly.map_timeseries_$Var'_fcst.py' $scripts/mapping.nmme_to_NHDPlusHUC4.nc $File $HucDir/$File:t:r.nc
  end

end
