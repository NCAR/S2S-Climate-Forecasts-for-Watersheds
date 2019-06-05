#!/bin/bash
# S. Baker, Aug 2017
# process nmme forecasts and copy to hydro-c1-web

# get date
yyyy=`date +%Y`
mm=`date +%m`

# calculate months since 1960
yrs=$((yyyy - 1960))
let months=$yrs\*12
Fcst=$((months + ${mm#0} - 1))
echo $Fcst

script_dir=/home/hydrofcst/s2s/scripts/nmme_scripts

# download nmme for current month (after the 8th)
${script_dir}/dwnld_nmme_fcsts_iri.csh ${Fcst}

# process and average to HUCs
${script_dir}/process_nmme_fcst_iri.csh ${Fcst}

# process for shiny app and copy
${script_dir}/process_nmme_realtime_iri.Rscr
