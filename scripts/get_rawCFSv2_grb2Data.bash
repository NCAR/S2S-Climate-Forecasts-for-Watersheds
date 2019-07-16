#!/bin/bash

# CFSv2 daily download from A. Newman - copied to our dir 

#change these to be command line options?
#init_date=20150704
#init_hr=00
fdays=31

out_dir=/d2/hydrofcst/s2s/rawGrb2_dwnld


#don't change data site
site=http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs

#don't change
#ntimes=$(($fdays*4))
#buffer=$(($ntimes*2+70))

#setup date to grab
#grab yesterdays data
#grab today's date
today=`date +%Y%m%d`
grab_date=`date +%Y%m%d --date "${today} -1 day"`

#for init_date in 20150925 20150926 20150927 20150928 20150929 20150930 20151001
for init_date in ${grab_date}
do
  for init_hr in 00 06 12 18
  do

    #start of script work
    if [ ! -d ${out_dir}/${init_date}${init_hr} ]; then
      mkdir ${out_dir}/${init_date}${inipt_hr}
    fi

    for ens in 01 02 03 04
    do
      if [ ! -d ${out_dir}/${init_date}${init_hr}/${ens} ]; then
        mkdir ${out_dir}/${init_date}${init_hr}/${ens}
      fi

      #get date info
      yr="${init_date:0:4}"
      mn="${init_date:4:2}"
      day="${init_date:6:2}"
      hr=$init_hr

      for var in tmp2m prate
      do

        #get data and place in --directory-prefix
        # -nc no clobber so if file is there, don't redownload

        wget --directory-prefix=${out_dir}/${init_date}${init_hr}/${ens}/ -nc ${site}/cfs.${init_date}/${init_hr}/time_grib_${ens}/${var}.${ens}.${yr}${mn}${day}${hr}.daily.grb2

        done #end of variable loop
    done #end of ensemble loop
  done #end of init_hr loop
done  #end of init_date loop

