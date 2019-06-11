# ===========================================
# global.r
# S. Baker, June 2017
# /opt/srv/shiny-server/S2S-app/
# ===========================================

## load libraries
library(data.table)
library(dplyr)
library(rgdal)
library(shinythemes)
library(shiny)
library(leaflet)
library(plotly)
library(ggplot2)
library(RColorBrewer)
library(stringi)

### ===  read in data

## read skill statistics
t.p_stats = readRDS('t.p_stats.rds')
t.p_stats = t.p_stats[order(t.p_stats$hru),]
nmme_stats = readRDS('nmme_nldas_stats.rds')

## read simplified R spatial file
# huc4 = readOGR(dsn = '.', layer = 'NHDPlusv2_HUC4') ### could probably do simplified version of this
load('HUC4_SPdf.RData')

# ### === simplifying the shape file (produce 'HUC4_SPdf.RData')
# #https://water.usgs.gov/wsc/map_index.html
# setwd('C:/Users/sabaker/Documents/3.PhD project/Rshiny_apps/S2S-app-new/HUC4')
# huc4 = readOGR(dsn = '.', layer = 'NHDPlusv2_HUC4')
# huc4_id = read.table('huc4_id.txt', header = T,
#                      colClasses=c('character','character'))
# library(rgeos)
# # creates a 'id' column in the data attribute table
# huc4@data$id = rownames(huc4@data)
# # pulls out the attribute table into a data frame
# huc4_attr = huc4@data
# huc4_attr$HUC4 = as.character(huc4_attr$HUC4)
# huc4_attr = left_join(huc4_attr, huc4_id, by = 'HUC4')
# # simplifies the shapefile to speed up plotting
# huc4_simp = gSimplify(huc4, tol = .065, topologyPreserve = F) #.1 F
# # convert class and add attributes back in
# huc4 <- as(huc4_simp, "SpatialPolygonsDataFrame")
# huc4@data$HUC4 = huc4_attr
# # # turns R spatial object into a data frame for plotting - not for Shiny!!!
# # huc4 = fortify(huc4_simp, polyid = 'id')
# # # adds attributes to the data_frame
# # huc4 = left_join(huc4, huc4_attr)
# # 
# # ## Save huc4_dt
# setwd('C:/Users/sabaker/Documents/3.PhD project/Rshiny_apps/S2S-app-new/')
# save(huc4, file = 'HUC4_SPdf.RData')
