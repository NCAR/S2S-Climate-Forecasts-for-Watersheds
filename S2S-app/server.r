# ===========================================
# server.r - process data, figures
# S. Baker, June 2017
# ===========================================

## load libraries
library(leaflet)
library(shiny)
library(ggplot2)
library(dplyr)
library(data.table)
library(RColorBrewer)
library(rgdal)
library(plotly)
library(shinythemes)


## function for reading in rds for reactiveFileReader
LoadToEnvironment <- function(rds) {
  df = readRDS(rds)
  return(df)
}



## shiny server
server = function(input, output, session) {

  ### === CFSv2 reactive file reader (in milliseconds)
  realtime <- reactiveFileReader(100000, session, 'realtime/realtimeCFS_anom_QM.rds', LoadToEnvironment)

  ## for ui real time tab
  output$ui_cfsv2_fcst_dates = renderUI({
    selectInput('fcst_real_sel',
                label = h4('Forecast Date'),
                choices = rev(levels(realtime()$fcst_date)),
                selected = rev(levels(realtime()$fcst_date))[1]
    )
  })
  
  ### === NMME - reactive file reader (in milliseconds)
  realtime_nmme <- reactiveFileReader(100000, session, 'realtime/nmme_realtime_fcsts.rds', LoadToEnvironment)
  
  ## for ui real time tab
  output$ui_nmme_fcst_dates = renderUI({
    selectInput('fcst_nmme_real_sel',
                label = h4('Forecast Date'),
                choices = rev(levels(realtime_nmme()$fcst_date)),
                selected = rev(levels(realtime_nmme()$fcst_date))[1]
    )
    
  })
  
  
  
  
  
  ##### ============ Real-time CFSv2 Map ============ #####
  output$realtime_output = renderLeaflet({
    
    req(input$fcst_real_sel) # required while launching app to not crash

    ## get desired variable based on inputs in 'ui.r'
    var_val = filter(realtime(), 
                     fcst_type == input$fcsttype_cfsv2_real_sel,
                     var_name == input$var_cfsv2_real_sel, 
                     lead == input$lead_cfsv2_real_sel, 
                     fcst_date == input$fcst_real_sel)$anom
    
    ## add variable to shape file data frame
    huc4@data$var = var_val
    
    ## change legend title and palette based on variable
    if(input$var_cfsv2_real_sel == 'prate') {
      leg_title = 'Anomaly (in/2wks)'
      bins_vec = c(60,10,5,2,1,0.5,0.2,0.1,0,-0.1,-0.2,-0.5,-1,-2,-5,-10,-60)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.1f", bins_vec[(k+1)]),"\u2013",sprintf("%.1f", bins_vec[k])))
      }
      col_vec = c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#EC6145", "#DA464C", "#BE2449", "#9E0142")
      pal = colorBin(col_vec,
                     #domain = c(-60,60),
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
    } else {
      leg_title = sprintf("Anomaly (&deg;F)") %>% lapply(htmltools::HTML)
      bins_vec = c(25,10,5,3,1,0,-1,-3,-5,-10,-25)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(bins_vec[(k+1)],"\u2013",bins_vec[k]))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#59B4AA", "#CAE99D", "#F7FCB3",
                      "#FEF5AF", "#FDC877", "#EC6145", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     #domain = c(25,-25),
                     bins = bins_vec,
                     reverse = TRUE, na.color = "#808080", alpha = FALSE)
    }
    
    ## add hover over labels
    labels_basin <- sprintf(
      "<strong>%s</strong><br/>%.1f",
      huc4@data$HUC4$Label, huc4@data$var
    ) %>% lapply(htmltools::HTML)
    
    ## graph CONUS using leaflet
    leaflet(data = huc4) %>% 
      addProviderTiles('CartoDB.PositronNoLabels', 
                       group = 'Political (default)') %>%
      addProviderTiles('Stamen.TonerLines', 
                       group = 'Political (default)',
                       options = providerTileOptions(opacity = 0.4, dashArray = "3")) %>%
      addPolygons(fillColor = ~pal(var),
                  stroke = T,
                  fillOpacity = 0.5,
                  color = '#e0e0e0',
                  weight = 1.1,
                  opacity = 0.75,
                  # dashArray = "3",
                  layerId = huc4@data$HUC4$Label,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#969696",
                    dashArray = "",
                    fillOpacity = 0.85,
                    bringToFront = TRUE),
                  label = labels_basin,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(#pal = pal,
                values = ~var,
                title = leg_title,
                position = 'bottomleft',
                colors = col_vec,
                labels = label_vec) 
  }) 
  
  
  
  ##### ============ Real-time NMME Map ============ #####
  output$realtime_nmme_output = renderLeaflet({
    
    req(input$fcst_nmme_real_sel) # required while launching app to not crash
    
    ## get desired variable based on inputs in 'ui.r'
    var_val = filter(realtime_nmme(), 
                     var == input$var_nmme_real_sel, 
                     lead == input$lead_nmme_real_sel, 
                     mdl == input$mdl_nmme_real_sel,
                     fcst_date == input$fcst_nmme_real_sel)$anom
    
    ## add variable to shape file data frame
    huc4@data$var = var_val
    
    ## change legend title and palette based on variable
    if(input$var_nmme_real_sel == 'prate') {
      leg_title = 'Anomaly (in/wk)'
      bins_vec = c(3,1,0.5,0.2,0.1,0.05,0.02,0.01,0,-0.01,-0.02,-0.05,-0.1,-0.2,-0.5,-1,-3)
      dec_val = 2
      col_vec = (c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                   "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.2f", bins_vec[(k+1)]),"\u2013",sprintf("%.2f", bins_vec[k])))
      }
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
    } else {
      leg_title = sprintf("Anomaly (&deg;F)") %>% lapply(htmltools::HTML)
      col_vec = rev(c("#5E4FA2", "#4470B1", "#59B4AA", "#CAE99D", "#F7FCB3",
                      "#FEF5AF", "#FDC877", "#EC6145", "#BE2449", "#9E0142"))
      bins_vec = c(15,5,3,2,1,0,-1,-2,-3,-5,-15)
      dec_val = 1
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(bins_vec[(k+1)],"\u2013",bins_vec[k]))
      }
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = TRUE, na.color = "#808080", alpha = FALSE)
    }
    
    ## add hover over labels
    labels_basin <- sprintf(paste0("<strong>%s</strong><br/>%.",dec_val,"f"),
      huc4@data$HUC4$Label, huc4@data$var) %>% 
      lapply(htmltools::HTML)
    
    ## graph CONUS using leaflet
    leaflet(data = huc4) %>% 
      addProviderTiles('CartoDB.PositronNoLabels', 
                       group = 'Political (default)') %>%
      addProviderTiles('Stamen.TonerLines', 
                       group = 'Political (default)',
                       options = providerTileOptions(opacity = 0.4, dashArray = "3")) %>%
      addPolygons(fillColor = ~pal(var),
                  stroke = T,
                  fillOpacity = 0.5,
                  color = '#e0e0e0',
                  weight = 1.1,
                  opacity = 0.75,
                  # dashArray = "3",
                  layerId = huc4@data$HUC4$Label,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#969696",
                    dashArray = "",
                    fillOpacity = 0.85,
                    bringToFront = TRUE),
                  label = labels_basin,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(#pal = pal,
                values = ~var,
                title = leg_title,
                position = 'bottomleft',
                colors = col_vec,
                labels = label_vec) 
  }) 
  
  ##### ============ CFSv2 Skill Map ============ #####
  output$biwk_analysis = renderLeaflet({
    ## get desired variable based on inputs in 'ui.r'
    var_val = filter(cfsv2_qm_stats, 
                     fcst_type == input$fcsttype_cfsv2_sel,
                     var == input$var_cfsv2_sel, 
                     lead == input$lead_cfsv2_sel, 
                     stat == input$stat_cfsv2_sel,
                     time_per == input$season_cfsv2_sel)$val
    
    ## add variable to shape file data frame
    huc4@data$var = var_val

    ## change legend title
    if(input$stat_cfsv2_sel == 'acc') {
      leg_title = 'Anomaly Correlation'
    } else if (input$stat_cfsv2_sel == 'bias' & input$var_cfsv2_sel == 'tmp2m') {
      leg_title = 'Bias (&deg;C)'
    } else if (input$stat_cfsv2_sel == 'bias' & input$var_cfsv2_sel == 'prate') {
      leg_title = 'Bias (mm/d)'
    } else if (input$stat_cfsv2_sel == 'absbias' & input$var_cfsv2_sel == 'tmp2m') {
      leg_title = 'MAE (&deg;C)'
    } else if (input$stat_cfsv2_sel == 'absbias' & input$var_cfsv2_sel == 'prate') {
      leg_title = 'MAE (mm/d)'
    } else {
      leg_title = 'Percent Bias'
    }
    
    ## Change color palettes interactively
    # ACC
    if(input$stat_cfsv2_sel == 'acc') {
      bins_vec = c(1, 0.8, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0, -.05, -.1, -.2)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.2f", bins_vec[(k+1)]),"\u2013",sprintf("%.2f", bins_vec[k])))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C",
                  "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
      # Bias
      } else if (input$stat_cfsv2_sel == 'bias') {
      bins_vec = c(4.5, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.3, 0.0, -0.3, -0.5, -1, -1.5, -2, -2.5, -3, -3.5, -4.5)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.1f", bins_vec[(k+1)]),"\u2013",sprintf("%.1f", bins_vec[k])))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
      # MAE
      } else if (input$stat_cfsv2_sel == 'absbias') {
        bins_vec = c(4.5, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.3, 0.0)
        label_vec = NULL
        for (k in 1:(length(bins_vec)-1)) {
          label_vec = c(label_vec, paste(sprintf("%.1f", bins_vec[(k+1)]),"\u2013",sprintf("%.1f", bins_vec[k])))
        }
        col_vec = rev(c("#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
        pal = colorBin(col_vec,
                       bins = bins_vec,
                       reverse = T, na.color = "#808080", alpha = FALSE)
      # Percent Bias
      } else {
      bins_vec = c(Inf, 160, 140, 120, 100, 80, 60, 40, 20, 0, -20, -40, -60, -80, -100, -120, -140, -160, -Inf)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(bins_vec[(k+1)],"\u2013",bins_vec[k]))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
    }
    
    ## add hover over labels
    labels_basin <- sprintf(
      "<strong>%s</strong><br/>%.2f",
      huc4@data$HUC4$Label, huc4@data$var
    ) %>% lapply(htmltools::HTML)
    
    ## graph CONUS using leaflet
    leaflet(data = huc4) %>% 
      addProviderTiles('CartoDB.PositronNoLabels', 
                       group = 'Political (default)') %>%
      addProviderTiles('Stamen.TonerLines', 
                       group = 'Political (default)',
                       options = providerTileOptions(opacity = 0.4, dashArray = "3")) %>%
      addPolygons(fillColor = ~pal(var),
                  stroke = T,
                  fillOpacity = 0.5,
                  color = '#e0e0e0',
                  weight = 1.1,
                  opacity = 0.75,
                  # dashArray = "3",
                  layerId = huc4@data$HUC4$Label,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#969696",
                    dashArray = "",
                    fillOpacity = 0.85,
                    bringToFront = TRUE),
                  label = labels_basin,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(#pal = pal,
                values = ~var,
                title = leg_title,
                position = 'bottomleft',
                colors = col_vec,
                labels = label_vec)
  }) 
  
  

  
  ##### ============ NMME Skill Map ============ #####
  output$mon_analysis = renderLeaflet({
    # leafletProxy("mon_analysis") %>% fitBounds( 20, 70, 270, 340)
    
    ## get desired variable based on inputs in 'ui.r'
    var_val = filter(nmme_stats, 
                     var == input$var_nmme_sel, 
                     mdl == input$mdl_nmme_sel,
                     lead == input$lead_nmme_sel, 
                     stat == input$stat_nmme_sel,
                     time_per == input$season_nmme_sel)$val
    
    ## add variable to shape file data frame
    huc4@data$var = var_val
    
    
    ## change legend title
    if(input$stat_nmme_sel == 'acc') {
      leg_title = 'Anomaly Correlation'
    } else if (input$stat_nmme_sel == 'bias' & input$var_nmme_sel == 'tmp2m') {
      leg_title = 'Bias (&deg;C)'
    } else if (input$stat_nmme_sel == 'bias' & input$var_nmme_sel == 'prate') {
      leg_title = 'Bias (mm/d)'
    } else {
      leg_title = 'Percent Bias'
    }
    
    ## Change color palettes interactively
    # ACC
    if(input$stat_nmme_sel == 'acc') {
      bins_vec = c(1, 0.8, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0, -.1, -.2, -.3, -.5)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.2f", bins_vec[(k+1)]),"\u2013",sprintf("%.2f", bins_vec[k])))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
      # Bias
    } else if (input$stat_nmme_sel == 'bias') {

      bins_vec = c(13, 8, 4, 3, 2.0, 1.5, 1.0, 0.5, 0.3, 0.0, -0.3, -0.5, -1, -1.5, -2, -3, -4, -8, -12)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(sprintf("%.1f", bins_vec[(k+1)]),"\u2013",sprintf("%.1f", bins_vec[k])))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
      # Percent Bias
    } else {
      
      bins_vec = c(Inf, 160, 140, 120, 100, 80, 60, 40, 20, 0, -20, -40, -60, -80, -100, -120, -140, -160, -Inf)
      label_vec = NULL
      for (k in 1:(length(bins_vec)-1)) {
        label_vec = c(label_vec, paste(bins_vec[(k+1)],"\u2013",bins_vec[k]))
      }
      col_vec = rev(c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                  "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      pal = colorBin(col_vec,
                     bins = bins_vec,
                     reverse = T, na.color = "#808080", alpha = FALSE)
    }
    
    ## add hover over labels
    labels_basin <- sprintf(
      "<strong>%s</strong><br/>%.2f",
      huc4@data$HUC4$Label, huc4@data$var
    ) %>% lapply(htmltools::HTML)
    
    ## graph CONUS using leaflet
    leaflet(data = huc4) %>% #options = leafletOptions(zoomControl = FALSE)) # <- to set zoom
     
      addProviderTiles('CartoDB.PositronNoLabels', 
                       group = 'Political (default)') %>%
      addProviderTiles('Stamen.TonerLines', 
                       group = 'Political (default)',
                       options = providerTileOptions(opacity = 0.4, dashArray = "3")) %>%
      addPolygons(fillColor = ~pal(var),
                  stroke = T,
                  fillOpacity = 0.5,
                  color = '#e0e0e0',
                  weight = 1.1,
                  opacity = 0.75,
                  # dashArray = "3",
                  layerId = huc4@data$HUC4$Label,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#969696",
                    dashArray = "",
                    fillOpacity = 0.85,
                    bringToFront = TRUE),
                  label = labels_basin,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(#pal = pal,
                values = ~var,
                title = leg_title,
                position = 'bottomleft',
                colors = col_vec,
                labels = label_vec) 
    
    
    #%>% 
      #setView(lat = 35, lng = -102, zoom = 4)
  }) 
  
  # ## Set Zoom control - zoom out ##
  # observeEvent(input$mon_analysis_zoom_out ,{
  #   leafletProxy("mon_analysis") %>% 
  #     setView(lat  = (input$mon_analysis_bounds$north + input$mon_analysis_bounds$south) / 2,
  #             lng  = (input$mon_analysis_bounds$east + input$mon_analysis_bounds$west) / 2,
  #             zoom = input$mon_analysis_zoom - 1)
  # })
  # # Zoom control - zoom in
  # observeEvent(input$mon_analysis_zoom_in ,{
  #   leafletProxy("mon_analysis") %>% 
  #     setView(lat  = (input$mon_analysis_bounds$north + input$mon_analysis_bounds$south) / 2,
  #             lng  = (input$mon_analysis_bounds$east + input$mon_analysis_bounds$west) / 2,
  #             zoom = input$mon_analysis_zoom + 1)
  # })
  
  # observe({
  #   input$reset_button
  #   leafletProxy("mon_analysis") %>% setView(lat = -23, lng = 170, zoom = 4)
  # })
  
  output$about <- renderText({  
    includeMarkdown("about.md")  
  })
  
  output$analysis <- renderText({  
    includeMarkdown("DataMethods.md")  
  })
  
  ## select an individual HUC
  # output$text1 = renderText({
  #   basin_click = input$biwk_analysis_shape_click
  #   basin_click = basin_click$id
  #   paste("You have selected the", stri_trans_general(basin_click, id = 'Title'), 'Basin')
  # })
  
  
  # # pop-up timeseries plot - uses different data frame
  # output$ts_24hracc = renderPlotly({
  #   basin_click = input$biwk_analysis_shape_click
  #   basin_click = basin_click$id
  #   id_click = filter(id_name_tbl, NAME == basin_click)$hru
  #   var_val = filter(t.p_stats, 
  #                    var == input$var_cfsv2_sel, 
  #                    leads == input$lead_cfsv2_sel, 
  #                    stats == input$stat_cfsv2_sel, 
  #                    hru == id_click)
  #   source_lab = unique(var_val$source_name)
  #   fcst_var = ggplot(data = var_val) + 
  #     geom_ribbon(aes(x = date_end, ymin = rainfallmin, ymax = rainfallmax), 
  #                 alpha = 0.5, fill = '#990066', linetype = 2, size = 0.2, colour = '#7a0051') + 
  #     geom_line(aes(x = date_end, y = rainfall), linetype = 2, size = 0.2) + 
  #     theme_bw() + xlab('') + 
  #     ylab('Rainfall (mm/day)') + 
  #     scale_x_date(date_breaks = '1 day', date_labels = '%m-%d') + 
  #     ggtitle(paste(stri_trans_general(basin_click, id = 'Title'), 'Basin', source_lab, '24hr Accum.')) + 
  #     geom_point(aes(x = date_end, y = rainfall), shape = 20) + 
  #     geom_point(aes(x = date_end, y = rainfallmax), shape = 20, colour = '#7a0051') + 
  #     geom_point(aes(x = date_end, y = rainfallmin), shape = 20, colour = '#7a0051')
  #   #+ theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
  #   ggplotly(fcst_var)
  # })
}
