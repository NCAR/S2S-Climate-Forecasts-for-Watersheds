#!/bin/bash
# S. Baker, Aug 2017
# process nmme forecasts and copy to hydro-c1-web

# get date
yyyymm=`date +%Y%m`
#grab_date=`date +%Y%m%d --date "${today} -1 day"`

script_dir=/home/hydrofcst/s2s/scripts/nmme_scripts

# download nmme for current month (after the 8th)
${script_dir}/dwnld_nmme_fcsts.csh ${yyyymm}

# process and average to HUCs
${script_dir}/process_nmme_fcst.csh ${yyyymm}

# process for shiny app and copy
${script_dir}/process_nmme_realtime.Rscr
