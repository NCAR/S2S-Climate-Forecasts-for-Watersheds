#!/bin/bash
# S. Baker, June 2017
# process cfsv2 forecasts and copy to hydro-c1-web

# get date
today=`date +%Y%m%d`
grab_date=`date +%Y%m%d --date "${today} -1 day"`

script_dir=/home/hydrofcst/s2s/scripts

# process cfs fcsts
for init_hr in 00 06 12 18
do
    ${script_dir}/process_cfs_realtime.csh ${grab_date}${init_hr}
done

# process for shiny app and copy
#${script_dir}/process_cfs_4Shiny.Rscr
${script_dir}/process_cfs_4Shiny_QM.Rscr
