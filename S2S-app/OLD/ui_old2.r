# ===========================================
# ui.r - process data, figures
# S. Baker, April 2017
# ===========================================

library(shiny)
library(leaflet)
library(shinyBS)

shinyUI(navbarPage(theme = "styles.css", # from www/ (shorter css file) ???
                   
                   ### google analytics set-up
                   # tags$head(includeScript("google-analytics.js")),
                   tags$head(HTML(
                     "<!-- Global site tag (gtag.js) - Google Analytics -->
                      <script async src='https://www.googletagmanager.com/gtag/js?id=UA-109233251-1'></script>
                      <script>
                        window.dataLayer = window.dataLayer || [];
                        function gtag(){dataLayer.push(arguments);}
                        gtag('js', new Date());

                        gtag('config', 'UA-108421993-2');
                    </script>"
                   )), #https://shiny.rstudio.com/articles/usage-metrics.html
                   
                   title = 'S2S Climate Outlooks for Watersheds', 
                   id = 'nav',
                   selected = 'CFSv2 Forecasts',
                   collapsible = TRUE,
                   position = "fixed-top",
                   
                   
                   ### === CFSv2 Realtime Forecasts
                   tabPanel('CFSv2 Forecasts',
                            div(class = 'outer',
                                tags$head(    
                                  includeCSS('styles.css') # from main folder, not www/
                                ),
                                leafletOutput('realtime_output', width = '100%', height = '100%'),
                                absolutePanel(id = 'controls', 
                                              class = 'panel', #changed
                                              fixed = T, 
                                              draggable = FALSE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              tags$style(".popover{ right: 300px !important;
                                                         max-width: 40% !important;}"), # could try 20em
                                              tags$style(".tooltip{ right: 300px !important;
                                                         max-width: 40% !important;}"), # could try 20em
                                              
                                              ## Forecast type description
                                              radioButtons('fcsttype_cfsv2_real_sel', 
                                                           # label = h4('Forecast Type'), 
                                                           h4('Forecast Type',
                                                              tags$style(type = "text/css", "#q1 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q1", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Raw Forecast' = 'Raw', 
                                                                          'Bias-Corrected (QM)' = 'QM'), 
                                                           selected = 'Raw'
                                              ),
                                              bsPopover(id = "q1", title = "Raw & Post-processed Forecast",
                                                        content = 'Raw forecasts are mapped directly from the climate forecast model outputs, without further adjustment. Bias-corrected forecasts are post-processed to remove systematic biases in mean and spread relative to the observations for the watershed areas. For more details, see the "Data & Methods" tab.',
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Forecast Variable description
                                              radioButtons('var_cfsv2_real_sel',
                                                           # label = h4('Variable'),
                                                           h4('Variable',
                                                              tags$style(type = "text/css", "#q2 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q2", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Temperature Anomaly' = 'tmp2m',
                                                                          'Precipitation Rate Anomaly' = 'prate'),
                                                           selected = 'tmp2m'
                                              ),
                                              bsPopover(id = "q2", title = "Variable Anomaly",
                                                        content = "A forecast anomaly is the deviation of the current forecast from climatological long-term averages for the prediction period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Lead period description
                                              radioButtons('lead_cfsv2_real_sel', 
                                                           #label = h4('Bi-weekly Forecast Period'), 
                                                           h4('Bi-weekly Forecast Period',
                                                              tags$style(type = "text/css", "#q3 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q3", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('1-2 Week Forecast' = '1_2',
                                                                          '2-3 Week Forecast' = '2_3',
                                                                          '3-4 Week Forecast' = '3_4'), 
                                                           selected = '1_2'
                                              ),
                                              bsPopover(id = "q3", title = "Forecast Period",
                                                        content = 'The forecast is displayed for bi-weekly (14 day) blocks.',
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              # bsTooltip(id = "q3", title = "test", placement = "left", trigger = "focus", options = list(container = "body")),
                                              
                                              uiOutput('ui_cfsv2_fcst_dates')
                                              
                                ) #close abs panel
                            )
                   ),
                   
                   ### === NMME Realtime Forecasts
                   tabPanel('NMME Forecasts',
                            div(class = 'outer',
                                leafletOutput('realtime_nmme_output', width = '100%', height = '100%'),
                                absolutePanel(id = 'controls', 
                                              class = 'panel panel-default', 
                                              fixed = TRUE, 
                                              draggable = FALSE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              tags$style(".popover{ right: 300px !important;
                                                         max-width: 40% !important;}"), # could try 20em
                                              tags$style(".tooltip{ right: 300px !important;
                                                         max-width: 40% !important;}"), # could try 20em
                                              
                                              ## Forecast Variable description
                                              radioButtons('var_nmme_real_sel', 
                                                           # label = h4('Variable'), 
                                                           h4('Variable',
                                                              tags$style(type = "text/css", "#q4 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q4", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Temperature Anomaly' = 'tmp2m', 
                                                                          'Precipitation Rate Anomaly' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              bsPopover(id = "q4", title = "Variable Anomaly",
                                                        content = "A forecast anomaly is the deviation of the current forecast from climatological long-term averages for the prediction period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Lead description
                                              radioButtons('lead_nmme_real_sel', 
                                                           # label = h4('Forecast Lead'), 
                                                           h4('Forecast Lead',
                                                              tags$style(type = "text/css", "#q5 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q5", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Month 1 Forecast' = '1',
                                                                          'Month 2 Forecast' = '2',
                                                                          'Month 3 Forecast' = '3',
                                                                          'Season 1 Forecast' = 'season'), 
                                                           selected = '1'
                                              ),
                                              bsPopover(id = "q5", title = "Forecast Period",
                                                        content = "Monthly forecasts are displayed at leads 1, 2, 3, and Season 1. For example, for forecast produced in Oct, Month 1 = Nov, Month 2 = Dec, Month 3 = Jan, and Season 1 = Nov-Jan.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Model description
                                              selectInput('mdl_nmme_real_sel', 
                                                          # label = h4('Model(s)'), 
                                                          h4('Model(s)',
                                                             tags$style(type = "text/css", "#q6 {vertical-align: middle;}"), #changes position of '?'
                                                             bsButton("q6", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                          ),
                                                          choices = list('NMME Average' = 'nmme',
                                                                         'CFSv2' = 'CFSv2',
                                                                         'CMC1' = 'CMC1',
                                                                         'CMC2' = 'CMC2',
                                                                         'GFDL' = 'GFDL',
                                                                         'GFDL_FLOR' = 'GFDL_FLOR',
                                                                         'NASA' = 'NASA',
                                                                         'NCAR_CCSM4' = 'NCAR_CCSM4'), 
                                                          selected = 'nmme'
                                              ),
                                              bsPopover(id = "q6", title = "NMME Models",
                                                        content = paste0("The NMME Average is the equally-weighted average of the ensemble mean forecasts from 7 models. Individual model forecasts show the mean of each individual model forecast ensemble."),
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              uiOutput('ui_nmme_fcst_dates')
                                              
                                ) #close abs panel
                            )
                   ),
                   
                   
                   tabPanel('CFSv2 Skill',
                            div(class = 'outer',
                                leafletOutput('biwk_analysis', width = '100%', height = '100%'),
                                absolutePanel(id = 'controls', 
                                              class = 'panel panel-default',
                                              fixed = TRUE, 
                                              draggable = FALSE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              
                                            
                                              ## Forecast type description
                                              radioButtons('fcsttype_cfsv2_sel', 
                                                           # label = h4('Forecast Type'), 
                                                           h4('Forecast Type',
                                                              tags$style(type = "text/css", "#q7 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q7", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ), 
                                                           choices = list('Raw Forecast' = 'raw', 
                                                                          'Bias-Corrected (QM)' = 'qm'), 
                                                           selected = 'raw'
                                              ),
                                              bsPopover(id = "q7", title = "Raw & Post-processed Forecast",
                                                        content = 'Raw forecasts are mapped directly from the climate forecast model outputs, without further adjustment. Bias-corrected forecasts are post-processed to remove systematic biases in mean and spread relative to the observations for the watershed areas. For more details, see the "Data & Methods" tab.',
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Forecast Variable description
                                              radioButtons('var_cfsv2_sel', 
                                                           # label = h4('Variable'), 
                                                           h4('Variable',
                                                              tags$style(type = "text/css", "#q8 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q8", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Temperature (C)' = 'tmp2m', 
                                                                          'Precipitation Rate (mm/d)' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              bsPopover(id = "q8", title = "Variable Anomaly",
                                                        content = "A forecast anomaly is the deviation of the current forecast from climatological long-term averages for the prediction period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Lead period description
                                              radioButtons('lead_cfsv2_sel', 
                                                           #label = h4('Bi-weekly Forecast Period'), 
                                                           h4('Bi-weekly Forecast Period',
                                                              tags$style(type = "text/css", "#q9 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q9", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('1-2 Week Forecast' = '1.14',
                                                                          '2-3 Week Forecast' = '8.21',
                                                                          '3-4 Week Forecast' = '15.28'), 
                                                           selected = '1.14'
                                              ),
                                              bsPopover(id = "q9", title = "Forecast Period",
                                                        content = 'The forecast is displayed for bi-weekly (14 day) blocks.',
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              
                                              
                                              selectInput('stat_cfsv2_sel', 
                                                          label = h4('Statistic'), 
                                                          choices = list('Anomaly Correlation' = 'acc',
                                                                         'Mean Absolute Error' = 'absbias',
                                                                         'Bias' = 'bias',
                                                                         'Percent Bias' = 'pbias'), 
                                                          selected = 'acc'
                                              ),
                                              
                                              ## Time Period: annual vs seasonal
                                              selectInput('season_cfsv2_sel',
                                                          # label = h4('Time Period: Annual or Seasonal'),
                                                          h4('Time Period: Annual or Seasonal',
                                                             tags$style(type = "text/css", "#q10 {vertical-align: middle;}"), #changes position of '?'
                                                             bsButton("q10", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                          ),
                                                          choices = list('All Start Dates' = 'annual',
                                                                         'JFM' = 'JFM',
                                                                         'FMA' = 'FMA',
                                                                         'MAM' = 'MAM',
                                                                         'AMJ' = 'AMJ',
                                                                         'MJJ' = 'MJJ',
                                                                         'JJA' = 'JJA',
                                                                         'JAS' = 'JAS',
                                                                         'ASO' = 'ASO',
                                                                         'SON' = 'SON',
                                                                         'OND' = 'OND',
                                                                         'NDJ' = 'NDJ',
                                                                         'DJF' = 'DJF'),
                                                          selected = 'annual'
                                              ),
                                              bsPopover(id = "q10", title = "Time Period of Statistics",
                                                        content = "Statistics are averaged from the forecasts falling within the selected time period (3-month seasons).  Seasonal periods are denoted by the start of the forecast period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              )
                                ) #close abs panel
                            )
                   ),
                   tabPanel('NMME Skill',
                            div(class = 'outer',
                                leafletOutput('mon_analysis', width = '100%', height = '100%'),
                                absolutePanel(id = 'controls', 
                                              class = 'panel panel-default',
                                              fixed = TRUE, 
                                              draggable = FALSE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, #move panel to right (otherwise 'auto')
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              
                                              ## Forecast Variable description
                                              radioButtons('var_nmme_sel', 
                                                           # label = h4('Variable'), 
                                                           h4('Variable',
                                                              tags$style(type = "text/css", "#q11 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q11", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Temperature (C)' = 'tmp2m', 
                                                                          'Precipitation Rate (mm/d)' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              bsPopover(id = "q11", title = "Variable Anomaly",
                                                        content = "A forecast anomaly is the deviation of the current forecast from climatological long-term averages for the prediction period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Lead description
                                              radioButtons('lead_nmme_sel', 
                                                           # label = h4('Forecast Lead'), 
                                                           h4('Forecast Lead',
                                                              tags$style(type = "text/css", "#q12 {vertical-align: middle;}"), #changes position of '?'
                                                              bsButton("q12", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                           ),
                                                           choices = list('Month 0 Forecast' = '0',
                                                                          'Month 1 Forecast' = '1',
                                                                          'Month 2 Forecast' = '2',
                                                                          'Season 0 Forecast' = 'season0',
                                                                          'Season 1 Forecast' = 'season1'), 
                                                           selected = '0'
                                              ),
                                              bsPopover(id = "q12", title = "Forecast Period",
                                                        content = "Monthly forecasts are displayed at leads 1, 2, 3, and Season 1. For example, for forecast produced in Oct, Month 1 = Nov, Month 2 = Dec, Month 3 = Jan, and Season 1 = Nov-Jan.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              
                                              ## Statistic
                                              selectInput('stat_nmme_sel', 
                                                          label = h4('Statistic'), 
                                                          choices = list('Anomaly Correlation' = 'acc',
                                                                         'Bias' = 'bias',
                                                                         'Percent Bias' = 'pbias'), 
                                                          selected = 'acc'
                                              ),
                                             
                                              ## Time Period: annual vs seasonal
                                              selectInput('season_nmme_sel',
                                                          # label = h4('Time Period: Annual or Seasonal'),
                                                          h4('Time Period: Annual or Seasonal',
                                                             tags$style(type = "text/css", "#q13 {vertical-align: middle;}"), #changes position of '?'
                                                             bsButton("q13", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                          ),
                                                          choices = list('All Start Dates' = 'annual',
                                                                         'JFM' = 'JFM',
                                                                         'FMA' = 'FMA',
                                                                         'MAM' = 'MAM',
                                                                         'AMJ' = 'AMJ',
                                                                         'MJJ' = 'MJJ',
                                                                         'JJA' = 'JJA',
                                                                         'JAS' = 'JAS',
                                                                         'ASO' = 'ASO',
                                                                         'SON' = 'SON',
                                                                         'OND' = 'OND',
                                                                         'NDJ' = 'NDJ',
                                                                         'DJF' = 'DJF'),
                                                          selected = 'annual'
                                              ), 
                                              bsPopover(id = "q13", title = "Time Period of Statistics",
                                                        content = "Statistics are averaged from the forecasts falling within the selected time period (3-month seasons).  Seasonal periods are denoted by the start of the forecast period.",
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              ),
                                              # sliderTextInput(
                                              #   inputId = 'season_nmme_sel', 
                                              #   label = h4('Forecast Dates: All or Seasonal'),
                                              #   choices = list('All Start Dates' = 'annual',
                                              #                              'JFM' = 'JFM',
                                              #                              'FMA' = 'FMA',
                                              #                              'MAM' = 'MAM',
                                              #                              'AMJ' = 'AMJ',
                                              #                              'MJJ' = 'MJJ',
                                              #                              'JJA' = 'JJA',
                                              #                              'JAS' = 'JAS',
                                              #                              'ASO' = 'ASO',
                                              #                              'SON' = 'SON',
                                              #                              'OND' = 'OND',
                                              #                              'NDJ' = 'NDJ',
                                              #                              'DJF' = 'DJF'),
                                              #               selected = 'annual',
                                              #   animate = TRUE,
                                              #   grid = TRUE,
                                              #   dragRange = TRUE
                                              # ),
                                              
                                              ## Model description
                                              selectInput('mdl_nmme_sel', 
                                                          # label = h4('Model(s)'), 
                                                          h4('Model(s)',
                                                             tags$style(type = "text/css", "#q14 {vertical-align: middle;}"), #changes position of '?'
                                                             bsButton("q14", label = "", icon = icon("question"), style = "default", size = "extra-small")
                                                          ),
                                                          choices = list('NMME Average' = 'nmme',
                                                                         'CFSv2' = 'CFSv2',
                                                                         'CMC1' = 'CMC1',
                                                                         'CMC2' = 'CMC2',
                                                                         'GFDL' = 'GFDL',
                                                                         'GFDL_FLOR' = 'GFDL_FLOR',
                                                                         'NASA' = 'NASA',
                                                                         'NCAR_CCSM4' = 'NCAR_CCSM4'), 
                                                          selected = 'nmme'
                                              ),
                                              bsPopover(id = "q14", title = "NMME Models",
                                                        content = paste0("The NMME Average is the equally-weighted average of the ensemble mean forecasts from 7 models. Individual model forecasts show the mean of each individual model forecast ensemble."),
                                                        placement = "left",
                                                        trigger = "focus",
                                                        options = list(container = "body")
                                              )
                                              
                                ) #close abs panel
                                
                                # ## set zoom - 
                                # #https://stackoverflow.com/questions/35543814/change-the-default-position-of-zoom-control-in-leaflet-map-of-shiny-app
                                # absolutePanel(
                                #   top = "auto", left = 20, right = 'auto', bottom = 20,
                                #   width = "auto", height = "auto",
                                #   actionButton("map_zoom_in", "+"),
                                #   actionButton("map_zoom_out", "-")
                                # )
                                
                            )
                   ),
                   
                   tabPanel('About',  
                            fluidPage(
                              htmlOutput('about', style = "width: 97%; max-width: 70em")
                            )
                   ), #font-size: 1.1em
                   tabPanel('Data & Methods',  
                            fluidPage(
                              htmlOutput('analysis', style="width: 97%; max-width: 70em")
                            )
                   )
))
