# ===========================================
# Plot bi-weekly time periods
# S. Baker, April 2017
# ===========================================
rm(list=ls())

## Load libraries
library(dplyr)
library(RColorBrewer)
library(gridExtra)

## Directories
dir_nmme = '/home/sabaker/s2s/analysis/files/nmme_files/'
dir_plots = '/home/sabaker/s2s/analysis/files/plots/'

## Load function
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/plot_function.r')

##### ===== Load statistics ===== #####
setwd(dir_nmme)
df = readRDS('new_nmme_stats.rds')
df$hru = as.numeric(df$hru)

#####  ============== Graph Seasonal Statistics ==============  #####
setwd(dir_plots)
seas = cbind(c('JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ','DJF','annual'), 
             c('JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ','DJF','Annual'))
lead_v = cbind(c('0', '1', '2'), c('Month 1', 'Month 2', 'Month 3'))
var_v = cbind(c('tmp2m', 'prate'), c('Temperature', 'Precipitation Rate'))

## custom palletes
#cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))
cust_pal = (c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C",
              "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))


for (v in 1:2) {
  p_v = list()
  for (j in 1:3) {
    pl = list()
    for (i in 1:12) {
      df_plot = dplyr::filter(df, var == var_v[v,1], stat == 'acc', lead == lead_v[j,1], time_per == seas[i,1], mdl == 'nmme')
      
      ## plot
      df_plot$bins = cut(df_plot$val, breaks = (c(1, 0.8, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0, -.1, -.2, -.3, -.5)))
      lab = levels(df_plot$bins)
      p = plot_map(var_v[v,1], df_plot, 7, type = 'discrete', lab = lab,  cust_pal = cust_pal, legend_title = 'Anomaly Correlation')
      pl[[i]] = p + guides(fill=FALSE)
    }
    
    ## arrange on same page and save
    g = arrangeGrob(grobs = pl, ncol = 3, top = paste0('Anomaly Correlation - NMME ', 
                                                    lead_v[j,2],' ', var_v[v,2],' (1982-2016)'))
    ggsave(paste0('NMME_seasons_AnomCor_', var_v[v,1],'_',lead_v[j,2],'.png'), g, height = 5*4/2.2, width = 6*3/1.5, dpi = 300)
    
    
    ## plot annual 
    i = 13
    df_plot = dplyr::filter(df, var == var_v[v,1], stat == 'acc', lead == lead_v[j,1], time_per == seas[i,1], mdl == 'nmme')
    
    ## plot
    df_plot$bins = cut(df_plot$val, breaks = rev(c(1, 0.8, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0, -.1, -.2, -.3, -.5)))
    lab = levels(df_plot$bins)
    p2 = plot_map(var_v[v,1], df_plot, 7, type = 'discrete', lab = lab,  cust_pal = cust_pal, legend_title = 'Anomaly Correlation')
    p_v[[j]] = p2 + guides(fill=FALSE)
    ggsave(paste0('NMME_annual_AnomCor_', var_v[v,1],'_',lead_v[j,2],'.png'), p2, height = 10/2.2, width = 10/1.2, dpi = 300)
  }
  g_v = arrangeGrob(grobs = p_v, ncol = 3, top = paste0('Anomaly Correlation - NMME ', var_v[v,2],' (1982-2016)'))
  ggsave(paste0('NMME_annual_AnomCor_', var_v[v,1],'.png'), g_v, height = 5/2.2, width = 6*3/1.5, dpi = 300)
}