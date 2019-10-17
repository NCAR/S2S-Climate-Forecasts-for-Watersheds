#!/bin/bash
# S. Baker, June 2017
# Rerun past dates - process cfsv2 forecasts and copy to hydro-c1-web


script_dir=/home/hydrofcst/s2s/scripts

# process cfs fcsts
for date in 20190712
do

for init_hr in 00 06 12 18
do
    ${script_dir}/process_cfs_realtime.csh ${date}${init_hr}
done
done

# process for shiny app and copy
#${script_dir}/process_cfs_4Shiny.Rscr
