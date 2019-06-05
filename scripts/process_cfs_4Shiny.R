# ===========================================
# Analyze Real-time CFSv2 forecasts &
# Process forecasts for Rshiny
# S. Baker, June 2017
# ===========================================
rm(list=ls())

## Load libraries
library(dplyr)
library(ncdf4)
source('/home/sabaker/s2s/analysis/scripts/hru4dig.R')

## Directories
dir_doyAvg = '/d1/sabaker/s2s/s2s_website/doyAVG/'
dir_in = '/home/sabaker/s2s/s2s_website/files/huc_2wk_EnsMean/'
dir_out = '/home/sabaker/s2s/s2s_website/files/Rshiny_input/'

## load cfsv2 doy avg data
setwd(dir_doyAvg)
doy_avg = readRDS('cfsv2_doyAVG.rds')

## load & process forecast file names
setwd(dir_in)
fcst_files = list.files()
temp_fil = t(as.data.frame(strsplit(fcst_files, '\\.')))
file_df = cbind(fcst_files, substr(fcst_files,1,8), temp_fil[,2], substr(temp_fil[,3],1,3))

## Create df of daily forecast means
for (i in 1:nrow(file_df)) {
  nc_temp = nc_open(file_df[i,1]) 
  
  # read variables
  if (file_df[i,3] == 'prate') {
    var_raw = ncvar_get(nc_temp, file_df[i,3]) * 86400 # convert /hr to /day
  } else {
    var_raw = ncvar_get(nc_temp, file_df[i,3]) - 273.15 # K to C
  }
  
  # combine to data frame and bind with other fcsts
  df = cbind.data.frame(fcst_date = file_df[i,2], var_name = file_df[i,3], lead = file_df[i,4], 
                        var_value = var_raw, hru = ncvar_get(nc_temp, 'hru'))
 
   # combine with previous dataframe
  if (i == 1) {
    df_fcst = df
  } else {
    df_fcst = rbind.data.frame(df_fcst, df)
  }
}

# average by forecast date
df_avg = df_fcst %>% group_by(fcst_date, var_name, lead, hru) %>% summarise_each(funs(mean))
df_avg$hru = hru4dig(as.matrix(df_avg$hru)) # make hru code 4 digits
df_avg$fcst_date = as.Date(df_avg$fcst_date, '%Y%m%d')
df_avg$doy = as.numeric(strftime(df_avg$fcst_date, format = '%j'))

# merge and calculate anomalies
df_anom = left_join(df_avg, doy_avg, by = c('hru', 'lead', 'doy', 'var_name'))
df_anom$anom = df_anom$var_value - df_anom$var
df_anom$var_value <- df_anom$var <- df_anom$doy <- NULL

## save df
setwd(dir_out)
saveRDS(df_anom, 'realtimeCFS_anom.rds')