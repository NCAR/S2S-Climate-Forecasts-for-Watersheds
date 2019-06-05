#!/bin/bash

grab_date=20170502

script_dir=/home/hydrofcst/s2s/scripts

for init_hr in 12
do
    ${script_dir}/process_cfs_realtime.csh ${grab_date}${init_hr}
done
