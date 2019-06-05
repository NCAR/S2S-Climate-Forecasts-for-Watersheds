#!/bin/csh
# S. Baker, Jan 2018
# script to download NMME forecats

set Fcst = $1 #696 is Jan 2018

# ------ settings --------
set baseDir = /d2/hydrofcst/s2s/nmme_processing
set OutDir = $baseDir/rawNetCDF
#set TmpDir = $baseDir/rawGRB
set NMMEarchive = "http://iridl.ldeo.columbia.edu/SOURCES/.Models/.NMME" 

## download grb file and convert to netCDF
foreach Var (tref prec)
  foreach model (NCEP-CFSv2 CMC1-CanCM3 CMC2-CanCM4 COLA-RSMAS-CCSM4 NASA-GEOSS2S GFDL-CM2p5-FLOR-B01 GFDL-CM2p1-aer04)
    echo $model $Var
    if ($model == CMC1-CanCM3 || $model == CMC2-CanCM4 || $model == NASA-GEOSS2S) then
      wget -O $OutDir/$model.$Var.$Fcst.nc $NMMEarchive/.$model/.FORECAST/.MONTHLY/$Var/'[M]'average/S/$Fcst'.0'/VALUE/data.nc
    else if ($model == NCEP-CFSv2) then
      wget -O $OutDir/$model.$Var.$Fcst.nc $NMMEarchive/.$model/.FORECAST/.PENTAD_SAMPLES/.MONTHLY/$Var/'[M]'average/S/$Fcst'.0'/VALUE/data.nc
    else
      wget -O $OutDir/$model.$Var.$Fcst.nc $NMMEarchive/.$model/.MONTHLY/$Var/'[M]'average/S/$Fcst'.0'/VALUE/data.nc
    endif
  end
end
