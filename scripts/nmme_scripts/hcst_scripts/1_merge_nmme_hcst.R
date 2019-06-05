# ================================================
# Step 1 - 
# merge nmme data and create usable files
# S. Baker, July 2017
# ================================================
rm(list=ls())

## Load libraries
library(ncdf4)
library(dplyr)

## Directories
dir_in = '/home/sabaker/s2s/nmme/files/HUC_hcst/'
#dir_out = '/home/sabaker/s2s/nmme/files/R_output/'
dir_out = '/d2/hydrofcst/s2s/nmme_processing/R_output/'

## Input data
var = c('prate', 'tmp2m')
fcsts = c('01','02','03','04','05','06','07','08','09','10','11','12')
models = c('CFSv2', 'CMC1', 'CMC2', 'GFDL', 'GFDL_FLOR', 'NASA', 'NCAR_CCSM4')

### Read and save data (takes ~8-9 minutes)
beg_time = Sys.time()
# variable loop
for (i in 1:2) {
  print(var[i])
  df_all = NULL
  
  # model loop
  for (k in 1:length(models)) {
    print(models[k])
    df_model = NULL
    setwd(paste0(dir_in, var[i]))
    
    # month loop
    for (j in 1:12) {

      # year loop
      for (m in 0:34) {
        
        
        # read netcdf
        file = paste0(var[i],'.',fcsts[j],'0100.ensmean.',models[k],'.fcst.198201-201612.1x1.ITDIM-',m,'.nc')
        nc_temp = nc_open(file) 
        
        ## read variables & combine
        var_raw = ncvar_get(nc_temp, var[i]) # [hru (x), timestep (y)]
        hru_vec = ncvar_get(nc_temp, 'hru') # ncvar_get works on dimensions as well as variables
        yr = 1982 + m
        df = cbind(var[i], models[k], yr, j, hru_vec, var_raw)
        
        ## merge with previous data
        df_model = rbind(df_model, df)
        
        ## print errors with files - (makes script slower!)
        #r = range(df[,6])
        #if (var[i] == 'prate' & (max(as.numeric(r)) > 50 | min(as.numeric(r)) < 0)) { print(paste(r,file)) }
        #if (var[i] == 'tmp2m' & (max(as.numeric(r)) > 400 | min(as.numeric(r)) < 200)) { print(paste(r,file)) }
        
      }
      ## print max and min in model/var combo
      r = range(df_model[,6])
      if (var[i] == 'prate' & (max(as.numeric(r)) > 50 | min(as.numeric(r)) < 0)) { print(r) }
      if (var[i] == 'tmp2m' & (max(as.numeric(r)) > 400 | min(as.numeric(r)) < 200)) { print(r) }
    }
    setwd(dir_out)
    colnames(df_model) <- c('var', 'mdl', 'yr', 'mon', 'hru', 'lead 0', 'lead 1', 'lead 2', 'lead 3', 'lead 4', 'lead 5', 'lead 6', 'lead 7')
    saveRDS(df_model, file = paste0(var[i],'_',models[k],'_ensmean.rds'))
    df_all = rbind(df_all, df_model)
  }
  saveRDS(df_all, file = paste0(var[i],'_NMME_ensmean_198201-201612.rds'))
}
Sys.time() - beg_time # total time to run

# save entire data set
#saveRDS(df_all, file = 'NMME_ensmean_198201-201612.rds')