# ================================================
# Step 2 - 
# NMME & NLDAS monthly (& 3 month) climatology 
# and anomalies
# S. Baker, July 2017
# ================================================
rm(list=ls())

## Load libraries
library(ncdf4)
library(dplyr)
library(reshape2) # melt()
library(zoo)
library(lubridate)
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/hru4dig.R')
options(stringsAsFactors=FALSE)

## Directories
dir_nmme = '/d2/hydrofcst/s2s/nmme_processing/R_output/'
dir_nldas = '/home/sabaker/s2s/nldas/files/'
dir_nldas_out = '/d2/hydrofcst/s2s/nmme_processing/R_output/nldas_output/'

##### ===== NMME ===== ##### (could make more efficient with variable loop like NLDAS...)
setwd(dir_nmme)

for (var in c('prate', 'tmp2m')) {
  
  ## read data
  nmme_var = as.data.frame(readRDS(paste0(var,'_NMME_ensmean_198201-201612.rds')))

  ## organize
  colnames(nmme_var) <- c('var', 'mdl', 'yr', 'mon', 'hru', 'lead_0', 'lead_1', 'lead_2', 'lead_3', 
                          'lead_4', 'lead_5', 'lead_6', 'lead_7')
  nmme_df = data.frame(mdl = nmme_var$mdl, mon = as.numeric(nmme_var$mon), yr = as.numeric(nmme_var$yr), hru = as.numeric(nmme_var$hru), 
                       lead_0 = as.numeric(nmme_var$lead_0), lead_1 = as.numeric(nmme_var$lead_1), lead_2 = as.numeric(nmme_var$lead_2), 
                       lead_3 = as.numeric(nmme_var$lead_3), lead_4 = as.numeric(nmme_var$lead_4), lead_5 = as.numeric(nmme_var$lead_5), 
                       lead_6 = as.numeric(nmme_var$lead_6), lead_7 = as.numeric(nmme_var$lead_7))
  colnames(nmme_df) <- c('mdl', 'mon', 'yr', 'hru', '0', '1', '2', '3', '4', '5', '6', '7')
  
  # convert units - K to C
  if (var == 'tmp2m') { nmme_df[,5:12] = nmme_df[,5:12] - 273.15  }

  ## reshape & calculate forecasted month
  nmme_df = melt(nmme_df, id.vars = c('mdl', 'mon', 'yr', 'hru'))
  nmme_df$fcst_date = as.Date(paste(nmme_df$yr, nmme_df$mon, '01'), '%Y %m %d')
  nmme_df$variable = as.numeric(as.character(nmme_df$variable))
  nmme_df$fcsted_date = nmme_df$fcst_date %m+% months(nmme_df$variable)
  nmme_df$fcsted_mon = nmme_df$mon + nmme_df$variable
  nmme_df$fcsted_mon = ifelse(nmme_df$fcsted_mon > 12, nmme_df$fcsted_mon - 12, nmme_df$fcsted_mon)
  
  ## calculate climatologies for each model, hru, forecast month
  nmme_var = nmme_df
  nmme_df$mon <- nmme_df$variable <- nmme_df$fcsted_date <- nmme_df$yr <- nmme_df$fcst_date <- NULL
  nmme_clim = nmme_df %>% group_by(mdl, fcsted_mon, hru) %>% summarise_all(funs(mean))
  colnames(nmme_clim) <- c('mdl', 'fcsted_mon', 'hru', 'clim_val')
  
  ## subtract out climatology 
  nmme_anom = left_join(nmme_var, nmme_clim, by = c('mdl', 'hru', 'fcsted_mon'))
  nmme_anom$mon <- nmme_anom$yr <- NULL
  nmme_anom$yr = year(nmme_anom$fcsted_date) # fcsted year
  nmme_anom$anom = nmme_anom$value - nmme_anom$clim_val
  nmme_anom = data.frame(mdl = nmme_anom$mdl, mon_fcsted = nmme_anom$fcsted_mon, yr_fcsted = nmme_anom$yr, hru = nmme_anom$hru, 
                    lead = nmme_anom$variable, var = nmme_anom$value, fcst_date = nmme_anom$fcst_date, 
                    fcsted_date = nmme_anom$fcsted_date, clim_val = nmme_anom$clim_val, anom = nmme_anom$anom)
  #colnames(nmme_anom) <- c('mdl', 'mon', 'yr', 'hru', 'lead', 'var', 'fcst_date', 'fcsted_date', 'clim_val', 'anom')
  
  ## save rds
  saveRDS(nmme_anom, file = paste0('nmme_',var,'_anomalies.rds'))

  ### === 3 month average anomalies (leads 0-2,1-3)
  nmme_3mon_0 = nmme_anom[nmme_anom$lead <= 2, ] ## used to be just <= 2; changed to match forecasts
  nmme_3mon_1 = nmme_anom[nmme_anom$lead <= 3 & nmme_anom$lead > 0, ] ## used to be just <= 2; changed to match forecasts
  nmme_3mon_0$mon_fcsted <- nmme_3mon_0$yr_fcsted <- nmme_3mon_0$fcsted_date <-
    nmme_3mon_1$mon_fcsted <- nmme_3mon_1$yr_fcsted <- nmme_3mon_1$fcsted_date <-NULL
  nmme_3mon_0 = nmme_3mon_0 %>% group_by(mdl, hru, fcst_date) %>% summarise_all(funs(mean))
  nmme_3mon_1 = nmme_3mon_1 %>% group_by(mdl, hru, fcst_date) %>% summarise_all(funs(mean))
  nmme_3mon_0$lead = 'season0'
  nmme_3mon_1$lead = 'season1'
  nmme_3mon_0$fcsted_mon = ifelse(month(nmme_3mon_0$fcst_date) + 1.5 > 12.5, month(nmme_3mon_0$fcst_date) + 1.5 - 12,
                                     month(nmme_3mon_0$fcst_date) + 1.5)
  nmme_3mon_1$fcsted_mon = ifelse(month(nmme_3mon_1$fcst_date) + 2.5 > 12.5, month(nmme_3mon_1$fcst_date) + 2.5 - 12, 
                                  month(nmme_3mon_1$fcst_date) + 2.5)
  
  nmme_3mon = rbind(nmme_3mon_0, nmme_3mon_1)

  ## calculate climatology
  nmme_3mon_clim = nmme_3mon[,c(1,2,4,6,8)]
  nmme_3mon_clim = unique(nmme_3mon_clim) # keep one value for each mon/hru/mdl combo
  
  ## save 3 month anomalies
  saveRDS(nmme_3mon, file = paste0('nmme_',var,'_3mon_anomalies.rds'))
  
  ### === combine climatologies and save
  nmme_clim$lead = NA
  clim_df = rbind.data.frame(nmme_clim, nmme_3mon_clim)
  saveRDS(clim_df, file = paste0('nmme_',var,'_climatology.rds'))
}


##### ===== NLDAS ===== #####
for (var in c('prate', 'tmp_2m')) {
  var_nm = ifelse(var == 'prate', 'prate', 'tmp2m')
  setwd(dir_nldas)
  
  ## read netcdfs
  nc_temp = nc_open(paste0('NLDAS_', var_nm, '_1980-2016.nc'))
  var_raw = t(ncvar_get(nc_temp, var)) # [hru (x), timestep (y)]
  hru_vec = ncvar_get(nc_temp, 'hru') # ncvar_get works on dimensions as well as variables
  fcst_date_vec = ncvar_get(nc_temp, 'time')
  fcst_date = as.POSIXct(fcst_date_vec*86400, origin = '1980-01-01', tz = 'utc') #timeseries of forecast date
  
  ## organize data
  nld_df = data.frame(date = fcst_date, var = var_raw) # varaibles are 202xdate <-need to change this
  colnames(nld_df) <- c('date', hru_vec)
  nld_df$mon = as.numeric(strftime(nld_df$date, format = '%m'))
  nld_df$yr = as.numeric(strftime(nld_df$date, format = '%Y'))
  
  ## remove 1980-1981
  nld_df = nld_df[nld_df$date >= as.POSIXct('1982-01-01'),]
  
  ## aggregate to monthly for both climatology and observation data
  nld_data = aggregate(. ~ yr + mon, nld_df, FUN = 'mean') # get monthly data
  nld_df$yr <- NULL
  nld_clim = aggregate(. ~ mon, nld_df, FUN = 'mean') # calc climatology for each month and hru
  nld_clim$date <- nld_data$date <-NULL
  nld_clim = melt(nld_clim, id.vars = c('mon')) # reshape
  nld_data = melt(nld_data, id.vars = c('yr','mon')) # reshape
  nld_data$variable = as.numeric(as.character(nld_data$variable)) #change factor to numeric
  nld_clim$variable = as.numeric(as.character(nld_clim$variable)) #change factor to numeric
  
  ## convert units
  if (var == 'prate') {
    nld_data$value = nld_data$value  * 24
    nld_clim$value = nld_clim$value  * 24
  } else {
    nld_data$value = nld_data$value - 273.15
    nld_clim$value = nld_clim$value - 273.15
  }
  
  ## calcuate anomalies
  nld_anom = left_join(nld_data, nld_clim, by = c('mon','variable'), suffix = c('_var', '_clim'))
  nld_anom$anom = nld_anom$value_var - nld_anom$value_clim
  colnames(nld_anom) <- c('yr', 'mon', 'hru', 'var', 'clim_val', 'anom')
  
  ## save data frames
  setwd(dir_nldas_out)
  saveRDS(nld_clim, file = paste0('NLDAS_', var_nm, '_climatology.rds'))
  saveRDS(nld_anom, file = paste0('NLDAS_', var_nm, '_anomalies.rds'))
  
  ### === 3 month average === ###
  
  ## calc var 3 month average
  nld_anom$date = as.Date(paste(nld_anom$yr, nld_anom$mon, '01'), '%Y %m %d')
  var_3avg = data.frame(date = nld_anom$date, var = nld_anom$var, hru = nld_anom$hru)
  var_3avg = var_3avg[with(var_3avg, order(hru, date)), ]
  var_3avg$avg = ave(var_3avg$var, var_3avg$hru, FUN = function(x) rollmean(x, k=3, align="right", na.pad=T))
  var_3avg$var <- NULL
  
  ## calc climate 3 month average
  clim_3avg = data.frame(date = nld_anom$date, var = nld_anom$clim_val, hru = nld_anom$hru)
  clim_3avg = clim_3avg[with(clim_3avg, order(hru, date)), ]
  clim_3avg$avg = ave(clim_3avg$var, clim_3avg$hru, FUN = function(x) rollmean(x, k=3, align="right", na.pad=T))
  clim_3avg$var <- NULL
  
  ## join and calc anomalies
  anom_3avg = left_join(var_3avg, clim_3avg, by = c('date', 'hru'), suffix = c('_var', '_clim'))
  anom_3avg$anom = anom_3avg$avg_var - anom_3avg$avg_clim
  
  
  ## edit date and save
  anom_3avg$date_season0 = anom_3avg$date %m+% months(-2)
  anom_3avg$date_season1 = anom_3avg$date_season0 %m+% months(-1)
  anom_3avg = na.omit(anom_3avg)
  anom_3avg$date <- NULL
  
  anom_3avg = anom_3avg[c(5,6,1:4)]
  saveRDS(anom_3avg, file = paste0('NLDAS_', var_nm, '_3mon_anomalies.rds'))
}