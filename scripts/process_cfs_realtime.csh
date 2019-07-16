#!/bin/csh
# S. Baker, June 2017
# Input Fcst date eg. 2017053000
# script to convert raw CFSv2 timeseries forecast files from grib2 to ncdf,
# regrid the file to 0.5x0.5 degree; cut domain to CONUS; take weighted avg
# for hucs; take bi-weekly average; take ensemble average for 6hr fcst

set input_date = $1 # 2017053000

# ------ settings --------
#set GribDir = /d2/anewman/wrf_hydro/cfsv2 # old dir
set GribDir = /d2/hydrofcst/s2s/rawGrb2_dwnld
set DataDir = /d2/hydrofcst/s2s
set TmpDir = $DataDir/tmpdir
set HUCdir_day = $DataDir/huc_daily
set HUCdir_2wk_ens = $DataDir/huc_2wk_Ens
set HUCdir_2wk_ensMean = $DataDir/huc_2wk_EnsMean
set dailyDir = $DataDir/cut_daily
set scripts = /home/hydrofcst/s2s/scripts
# use python v. 2.7 environment that contains netcdf
set Python  = /d3/hydrofcst/miniconda3/envs/otl_env_py2/bin/python

# ------ loop over fcst date, variable, ensemble -------
foreach fcst_date ($input_date)
  foreach var (prate tmp2m)
    foreach ens (01 02 03 04)
      
      # convert to netcdf
      set File = $var.$ens.$fcst_date.daily.grb2
      set temp_out = $TmpDir/$File:t:r.nc
      wgrib2 $GribDir/$fcst_date/$ens/$File -netcdf $temp_out

      # regrid data
      ncl 'in_file="'${temp_out}'"' 'var_in="'${var}'"' 'out_file="'${temp_out}'"' $scripts/cfsv2_regrid.ncl

      # rename attributes
      ncrename -d LAT,y -d LON,x -d time,t -v PRC,$var -v LAT,latitude -v LON,longitude $temp_out

      # cut to CONUS domain - 5,75N 185,305E
      ncea -O -d y,190,329 -d x,370,609 $temp_out $temp_out

      # Average to daily
      set daily_out = $dailyDir/$File:t:r.nc
      cdo daymean $temp_out $daily_out     

      # HUC average data
      set hucDay_out = $HUCdir_day/$File:t:r.nc
      if ($var == prate) then
        $Python $scripts/poly2poly.map_timeseries_prate.py $scripts/mapping.cfsv2_to_NHDPlusHUC4.nc $daily_out $hucDay_out
      else
        $Python $scripts/poly2poly.map_timeseries_tmp_2m.py $scripts/mapping.cfsv2_to_NHDPlusHUC4.nc $daily_out $hucDay_out
      endif
      \rm $temp_out

      ## Average to 2wk time periods (1-2 wk, 2-3 wk, 3-4 wk)
      set out_file = $HUCdir_2wk_ens/$fcst_date.$var.$ens
      # 1-2 wks
      ncks -O -d time,0,13 $hucDay_out $HUCdir_2wk_ens/$File:t:r.1_2wk.nc
      cdo timselmean,14 $HUCdir_2wk_ens/$File:t:r.1_2wk.nc $out_file.1_2wkAvg.nc
      # add back in hru variable
      ncks -A -M -v hru $HUCdir_2wk_ens/$File:t:r.1_2wk.nc  $out_file.1_2wkAvg.nc
      \rm $HUCdir_2wk_ens/$File:t:r.1_2wk.nc

      # 2-3 wks
      ncks -O -d time,7,20 $hucDay_out $HUCdir_2wk_ens/$File:t:r.2_3wk.nc
      cdo timselmean,14 $HUCdir_2wk_ens/$File:t:r.2_3wk.nc $out_file.2_3wkAvg.nc
      # add back in hru variable
      ncks -A -M -v hru $HUCdir_2wk_ens/$File:t:r.2_3wk.nc $out_file.2_3wkAvg.nc
      \rm $HUCdir_2wk_ens/$File:t:r.2_3wk.nc 

      # 3-4 wks
      ncks -O -d time,14,27 $hucDay_out $HUCdir_2wk_ens/$File:t:r.3_4wk.nc
      cdo timselmean,14 $HUCdir_2wk_ens/$File:t:r.3_4wk.nc $out_file.3_4wkAvg.nc
      # add back in hru variable
      ncks -A -M -v hru $HUCdir_2wk_ens/$File:t:r.3_4wk.nc  $out_file.3_4wkAvg.nc
      \rm $HUCdir_2wk_ens/$File:t:r.3_4wk.nc  
      \rm $hucDay_out
    end

    # average the ensembles for each 6 hr fcst
    ncea $HUCdir_2wk_ens/$fcst_date.$var.01.1_2wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.02.1_2wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.03.1_2wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.04.1_2wkAvg.nc $HUCdir_2wk_ensMean/$fcst_date.$var.1_2wk_EnsAvg.nc
    ncea $HUCdir_2wk_ens/$fcst_date.$var.01.2_3wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.02.2_3wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.03.2_3wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.04.2_3wkAvg.nc $HUCdir_2wk_ensMean/$fcst_date.$var.2_3wk_EnsAvg.nc
    ncea $HUCdir_2wk_ens/$fcst_date.$var.01.3_4wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.02.3_4wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.03.3_4wkAvg.nc $HUCdir_2wk_ens/$fcst_date.$var.04.3_4wkAvg.nc $HUCdir_2wk_ensMean/$fcst_date.$var.3_4wk_EnsAvg.nc

  end
end
