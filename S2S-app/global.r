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
library(RColorBrewer)
library(stringi)
#library(shinyWidgets)

### ===  read in data
#setwd("~/3.PhD project/Rshiny_apps/S2S-app_9.17")

## read skill statistics
nmme_stats = readRDS('nmme_nldas_stats.rds')
cfsv2_qm_stats = readRDS('QM_cfsv2.nldas_Stats.rds')
cfsv2_qm_stats = cfsv2_qm_stats[order(cfsv2_qm_stats$hru),]

## read simplified R spatial file
load('HUC4_SPdf.RData')

