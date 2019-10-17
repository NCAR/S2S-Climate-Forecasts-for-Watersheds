#!/bin/csh
# S. Baker, Aug 2017
# script to regrid NMME timeseries forecast
# file to 0.5x0.5 degree; rename dimensions
# and variables; cut to CONUS domain

set Fcst = $1 #201708

# source cdo since not in path currently
source /opt/etc/csh/opt.csh

# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set rawDir = $baseDir/rawNetCDF
set gridDir = $baseDir/regrid
set TmpDir = $baseDir/tmp
set renameDir = $baseDir/rename
set cutDir = $baseDir/nc_CONUS
set HucDir = $baseDir/HUC_fcst_iri
set scripts = /home/hydrofcst/s2s/scripts/nmme_scripts
set Python  = /d3/hydrofcst/miniconda3/envs/otl_env_py2/bin/python

# ------------------------

# loop through variables and get data for year supplied
foreach Var (tref prec)

  ## set new variable name for use below
  if ($Var == tref) then
    set NewV = tmp2m
  else
    set NewV = prate
  endif

  # rename and regrid with cdo
  foreach File ($rawDir/*.$Var.$Fcst.nc) 
        set output = $gridDir/$File:t:r.nc
        ncrename -O -d Y,lat -d X,lon -d L,time -v Y,lat -v X,lon -v L,time $File

        # average of S to remove dimension (fcst date)
        ncwa -O -C -v $Var,lon,lat,time -a S $File $TmpDir/$File:t:r.nc

        # regrid
        cdo remapbil,r720x360 $TmpDir/$File:t:r.nc $output
  end

  # rename files and cut
  foreach File ($gridDir/*.$Var.$Fcst.nc)
        set nm_out = $renameDir/$File:t:r.nc
        set output = $cutDir/$File:t:r.nc

        # rename variables and dimensions - need to check this works
        ncrename -O -d time,t -v $Var,$NewV -v time,fcst_time -v lat,latitude -v lon,longitude $File $nm_out

        # CONUS domain - 5,75N 185,305E
        ncea -O -d lat,190,329 -d lon,370,609 $nm_out $output
  end

  # loop over each file in the raw year directory
  foreach File ($cutDir/*.$Var.$Fcst.nc)
    $Python $scripts/poly2poly.map_timeseries_$NewV'_fcst.py' $scripts/mapping.nmme_to_NHDPlusHUC4.nc $File $HucDir/$File:t:r.nc
  end

end
