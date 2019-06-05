#!/bin/csh
# S. Baker, March 2019 (edited version Jan2018)
# script to download NMME hindcasts
# Updating since need a new hindcast record for NASA model
# The full hindcast time range isnt available for all models on IRI
#   may still need to go to NOAA website for some model hindcasts


# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set OutDir = $baseDir/rawNetCDF
#set TmpDir = $baseDir/rawGRB
set NMMEarchive = "http://iridl.ldeo.columbia.edu/SOURCES/.Models/.NMME" 

## download grb file and convert to netCDF
foreach Fcst ( `seq 253 684` )
  foreach Var (tref prec)
    foreach model (NASA-GEOSS2S)  #(NCEP-CFSv2 CMC1-CanCM3 CMC2-CanCM4 COLA-RSMAS-CCSM4 NASA-GEOSS2S GFDL-CM2p5-FLOR-B01 GFDL-CM2p1-aer04)
      echo $model $Var
      if ($model == COLA-RSMAS-CCSM4 || $model == GFDL-CM2p5-FLOR-B01 || $model == GFDL-CM2p1-aer04) then
        wget -O $OutDir/$model.$Var.$Fcst.nc $NMMEarchive/.$model/.MONTHLY/$Var/'[M]'average/S/$Fcst'.0'/VALUE/data.nc
      else
        wget -O $OutDir/$model.$Var.$Fcst.nc $NMMEarchive/.$model/.HINDCAST/.MONTHLY/$Var/'[M]'average/S/$Fcst'.0'/VALUE/data.nc
      endif
    end
  end
end
