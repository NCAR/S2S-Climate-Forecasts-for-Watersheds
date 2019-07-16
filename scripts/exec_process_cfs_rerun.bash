#!/bin/bash
# S. Baker, June 2017
# process cfsv2 forecasts and copy to hydro-c1-web

# get date
day=201907011
date=`date +%Y%m%d --date "${day} +1 day"`

script_dir=/home/hydrofcst/s2s/scripts

# process cfs fcsts
for date in 20190710 20190711 20190712 20190713 20190714
do

for init_hr in 00 06 12 18
do
    ${script_dir}/process_cfs_realtime.csh ${date}${init_hr}
done
done

# process for shiny app and copy
#${script_dir}/process_cfs_4Shiny.Rscr
