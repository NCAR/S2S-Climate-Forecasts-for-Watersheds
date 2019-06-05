# ================================================
# Step 3 - 
# NMME & NLDAS monthly (& 3 month) statistics
# S. Baker, August 2017
# ================================================
rm(list=ls())

library(hydroGOF) #pbias
library(dplyr)
library(lubridate)
library(reshape2)
options(stringsAsFactors=FALSE)

## Directories
dir_nmme = '/d2/hydrofcst/s2s/nmme_processing/R_output/'
dir_nldas = '/d2/hydrofcst/s2s/nmme_processing/R_output/nldas_output/'

df_stats = NULL
for (var in c('prate', 'tmp2m')) {
  
  ## read in data & organize
  
  ## NLDAS - seasonal
  setwd(dir_nldas)
  nld_3mo_anom = readRDS(paste0('NLDAS_', var, '_3mon_anomalies.rds'))
  nld_3mo_anom$fcsted_date = nld_3mo_anom$date_season0
  #colnames(nld_3mo_anom) <- c('season0', 'season1', 'hru', 'var', 'clim_val', 'anom') #fcsted date is really forecast date (lead 0)
  #nld_3mo_anom = melt(nld_3mo_anom, id = c('hru' ,'var', 'clim_val', 'anom'), value.name = 'fcsted_date', variable.name = 'lead')
  nld_3mo_anom$mon = ifelse((as.numeric(format(nld_3mo_anom$fcsted_date, '%m')) + 1.5) > 12.5, 
                            (as.numeric(format(nld_3mo_anom$fcsted_date, '%m')) + 1.5) - 12,
                            (as.numeric(format(nld_3mo_anom$fcsted_date, '%m')) + 1.5))# middle month (forecasted)
  nld_3mo_anom$date_season0 <- nld_3mo_anom$date_season1 <- NULL
  colnames(nld_3mo_anom) <- c('hru', 'var', 'clim_val', 'anom', 'fcsted_date', 'mon')

  ## NLDAS - monthly
  nld_anom = readRDS(paste0('NLDAS_', var, '_anomalies.rds'))
  nld_anom$fcsted_date = as.Date(paste(nld_anom$yr, nld_anom$mon, '01'), '%Y %m %d')
  nld_anom$yr <- NULL
  
  ## NMME - seasonal
  setwd(dir_nmme)
  nmme_3mo_anom = readRDS(paste0('nmme_', var, '_3mon_anomalies.rds'))
  nmme_3mo_anom$fcsted_date = as.Date(ifelse(nmme_3mo_anom$lead == 'season0', 
                                             nmme_3mo_anom$fcst_date, as.Date(nmme_3mo_anom$fcst_date %m+% months(1))), 
                                      origin = '1970-01-01')
  colnames(nmme_3mo_anom)[8] <- 'mon'
  nmme_3mo_anom$mdl = ifelse(nmme_3mo_anom$mdl == 'NASA-GEOSS2S', 'NASA', nmme_3mo_anom$mdl)
  
  ## NMME - monthly
  nmme_anom = readRDS(paste0('nmme_', var, '_anomalies.rds'))
  nmme_anom$lead = as.character(nmme_anom$lead)
  nmme_anom$yr_fcsted <- nmme_anom$mon_fcsted <- NULL
  nmme_anom$mdl = ifelse(nmme_anom$mdl == 'NASA-GEOSS2S', 'NASA', nmme_anom$mdl)
  #nmme_3mo_anom$mon_fcsted <-NULL
  
  ## join and rearrange nmme & nldas data
  anom = inner_join(nmme_anom, nld_anom, by = c('fcsted_date', 'hru'), suffix = c('_nmme', '_nld'))
  anom = anom[c('mdl', 'hru', 'fcst_date', 'fcsted_date', 'mon','lead', 'var_nmme', 'anom_nmme', 
                'var_nld', 'anom_nld')]
  
  ## graph an hru to test - looks best with temperature
  library(ggplot2)
  library(tidyr)
  filter(anom, mdl == 'CFSv2', hru == 1301, lead == '0') %>%
    gather(key,value, var_nmme, var_nld) %>%
    ggplot(aes(x=fcst_date, y=value, colour=key)) +
    geom_line()
  
  ## join and rearrange nmme & nldas data
  anom_3mon = inner_join(nmme_3mo_anom, nld_3mo_anom, by = c('fcsted_date','mon', 'hru'), suffix = c('_nmme', '_nld'))
  anom_3mon = anom_3mon[c('mdl', 'hru', 'fcst_date', 'fcsted_date', 'mon','lead', 'var_nmme', 'anom_nmme', 
                          'var_nld', 'anom_nld')]
  
  # ## graph an hru to test - looks best with temperature
  # filter(anom_3mon, mdl == 'CFSv2', hru == 1301, lead == 'season0') %>%
  #   gather(key,value, var_nmme, var_nld) %>%
  #   ggplot(aes(x=fcst_date, y=value, colour=key)) +
  #   geom_line()
  
  ## calc error
  anom$error = anom$var_nmme - anom$var_nld
  anom_3mon$error = anom_3mon$var_nmme - anom_3mon$var_nld
  
  ## combine 0-7 month lead and seasonal lead
  anom = rbind(anom, as.data.frame(anom_3mon))
  anom$mon = month(anom$fcst_date) #forecast month - means seasonal stats are based on forecast month not forecasted month
  
  
  #### ===== STATS - Calc Bias (mean error), anomaly correlation (ACC), percent bias ===== ####
  
  ## 1 - nmme, each lead, annual
  df = anom %>% group_by(hru, lead) %>% 
    summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
  df_stats = rbind(df_stats,
                   cbind.data.frame(var = var, mdl = 'nmme', hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'bias', val = df$bias),
                   cbind.data.frame(var = var, mdl = 'nmme', hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'acc', val = df$acc),
                   cbind.data.frame(var = var, mdl = 'nmme', hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'pbias', val = df$pbias))
  
  ## 2 - each model, each leads, annual
  df = anom %>% group_by(hru, mdl, lead) %>% 
    summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
  df_stats = rbind(df_stats,
                   cbind.data.frame(var = var, mdl = df$mdl, hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'bias', val = df$bias),
                   cbind.data.frame(var = var, mdl = df$mdl, hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'acc', val = df$acc),
                   cbind.data.frame(var = var, mdl = df$mdl, hru = df$hru, lead = df$lead, 
                                    time_per = 'annual', stat = 'pbias', val = df$pbias))
  
  ## 3/4 - nmme & each model, each lead, each season(12 total)
  df_nmme_3mon <- df_mdls_3mon <- NULL
  seas = c('JFM', 'FMA', 'MAM', 'AMJ', 'MJJ', 'JJA', 'JAS', 'ASO', 'SON', 'OND', 'NDJ', 'DJF')
  
  # stats for each 3 month period
  for (k in 1:12) {
    if ( k <= 10 ) {
      seas_df = anom %>% filter(mon >= k  & mon <= (k + 2))
      df_nmme = seas_df %>% group_by(hru, lead) %>% 
        summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
      df_mdls = seas_df %>% group_by(hru, mdl, lead) %>% 
        summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
    } else {
      seas_df = anom %>% filter(mon >= k  | mon <= (k - 10))
      df_nmme = seas_df %>% group_by(hru, lead) %>% 
        summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
      df_mdls = seas_df %>% group_by(hru, mdl, lead) %>% 
        summarise(bias = mean(error), acc = cor(anom_nmme, anom_nld), pbias = pbias(var_nmme, var_nld))
    }
    
    # create data frame
    df_nmme_3mon = rbind(df_nmme_3mon,
                         cbind.data.frame(var = var, mdl = 'nmme', hru = df_nmme$hru, lead = df_nmme$lead, 
                                          time_per = seas[k], stat = 'bias', val = df_nmme$bias),
                         cbind.data.frame(var = var, mdl = 'nmme', hru = df_nmme$hru, lead = df_nmme$lead, 
                                          time_per = seas[k], stat = 'acc', val = df_nmme$acc),
                         cbind.data.frame(var = var, mdl = 'nmme', hru = df_nmme$hru, lead = df_nmme$lead, 
                                          time_per = seas[k], stat = 'pbias', val = df_nmme$pbias))
    df_mdls_3mon = rbind(df_mdls_3mon,
                         cbind.data.frame(var = var, mdl = df_mdls$mdl, hru = df_mdls$hru, lead = df_mdls$lead, 
                                          time_per = seas[k], stat = 'bias', val = df_mdls$bias),
                         cbind.data.frame(var = var, mdl = df_mdls$mdl, hru = df_mdls$hru, lead = df_mdls$lead, 
                                          time_per = seas[k], stat = 'acc', val = df_mdls$acc),
                         cbind.data.frame(var = var, mdl = df_mdls$mdl, hru = df_mdls$hru, lead = df_mdls$lead, 
                                          time_per = seas[k], stat = 'pbias', val = df_mdls$pbias))
  }
  # combine with previous df
  df_stats = rbind(df_stats, df_nmme_3mon, df_mdls_3mon)
}

## save stats
setwd(dir_nmme)
df_stats$lead = as.character(df_stats$lead)
df_stats$time_per = as.character(df_stats$time_per)
df_stats$stat = as.character(df_stats$stat)
saveRDS(df_stats, file = 'nmme_nldas_stats.rds')


## copy to s2s app
# message("copying to web")
# system('echo "put /d2/hydrofcst/s2s/nmme_processing/R_output/nmme_nldas_stats.rds /opt/srv/shiny-server/S2S-app/" | sftp -i /home/hydrofcst/.ssh/hydrotxfr hydrofcst@hydro-c1-web')
# NOTE: The above wont work because of permissions. Could copy to /d1/www/html/s2s/S2S-app/ with the above line, then go in and 
#       manually copy to /opt/srv/shiny-server/S2S-app/ while logged in with ssh -X sabaker@hydro-c1-web.rap.ucar.edu
# may need to restart shiny server to see difference online...

## copy to s2s app
# message("copying to web")
# system('echo "put /d2/hydrofcst/s2s/nmme_processing/R_output/nmme_nldas_stats.rds /d1/www/html/s2s/S2S-app/realtime/" | sftp -i /home/hydrofcst/.ssh/hydrotxfr hydrofcst@hydro-c1-web')

