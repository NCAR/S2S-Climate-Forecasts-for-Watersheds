#!/bin/bash
# S. Baker, June 2017
# Rerun past dates - process cfsv2 forecasts and copy to hydro-c1-web


script_dir=/d2/hydrofcst/s2s/huc_2wk_EnsMean
goodData=20190611

# process cfs fcsts
for date in 20190712 20190716 #20190711 20190712 20190713 20190714 20190715 20190716 20190717 20190718 20190719 20190720 20190721 20190722 20190723 20190724 
do

for init_hr in 00 #06 12 18
do

for var in prate #tmp2m
do
    # wk 1-2
    hruFile=${script_dir}/${goodData}${init_hr}.${var}.1_2wk_EnsAvg.nc
    nohruFile=${script_dir}/${date}${init_hr}.${var}.1_2wk_EnsAvg.nc
    echo adding hru dim to ${nohruFile}
    ncks -A -M -v hru ${hruFile} ${nohruFile}

    # wk 2-3
    hruFile=${script_dir}/${goodData}${init_hr}.${var}.2_3wk_EnsAvg.nc
    nohruFile=${script_dir}/${date}${init_hr}.${var}.2_3wk_EnsAvg.nc
    echo adding hru dim to ${nohruFile}
    ncks -A -M -v hru ${hruFile} ${nohruFile}
 
    # wk 3-4
    hruFile=${script_dir}/${goodData}${init_hr}.${var}.3_4wk_EnsAvg.nc
    nohruFile=${script_dir}/${date}${init_hr}.${var}.3_4wk_EnsAvg.nc
    echo adding hru dim to ${nohruFile}
    ncks -A -M -v hru ${hruFile} ${nohruFile}

done
done
done

# process for shiny app and copy
#${script_dir}/process_cfs_4Shiny.Rscr
