# ===========================================
# ui.r - process data, figures
# S. Baker, April 2017
# ===========================================

library(shiny)
library(leaflet)
library(shinyBS)

shinyUI(navbarPage(theme = "styles.css", # from www/ (shorter css file)
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
                   )),		   

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
                                              draggable = TRUE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              radioButtons('var_real_sel', 
                                                           label = h4('Variable'), 
                                                           choices = list('Temperature Anomaly' = 'tmp2m', 
                                                                          'Precipitation Rate Anomaly' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              radioButtons('lead_real_sel', 
                                                           label = h4('Bi-weekly Forecast Period'), 
                                                           choices = list('1-2 Week Forecast' = '1_2',
                                                                          '2-3 Week Forecast' = '2_3',
                                                                          '3-4 Week Forecast' = '3_4'), 
                                                           selected = '1_2'
                                              ),
                                              uiOutput('ui_fcst_dates')
                                              
                                ) #close abs panel
                            )
                   ),
                   
                   ### === NMME Realtime Forecasts
                   tabPanel('NMME Forecasts',
                            div(class = 'outer',
                                # tags$head(    
                                #   includeCSS('styles.css')
                                # ),
                                leafletOutput('realtime_nmme_output', width = '100%', height = '100%'),
                                absolutePanel(id = 'controls', 
                                              class = 'panel panel-default', 
                                              fixed = TRUE, 
                                              draggable = TRUE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              radioButtons('var_nmme_real_sel', 
                                                           label = h4('Variable'), 
                                                           choices = list('Temperature Anomaly' = 'tmp2m', 
                                                                          'Precipitation Rate Anomaly' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              radioButtons('lead_nmme_real_sel', 
                                                           label = h4('Forecast Lead'), 
                                                           choices = list('Month 1 Forecast' = '1',
                                                                          'Month 2 Forecast' = '2',
                                                                          'Month 3 Forecast' = '3',
                                                                          'Season 1 Forecast' = 'season'), 
                                                           selected = '1'
                                              ),
                                              selectInput('mdl_nmme_real_sel', 
                                                          label = h4('Model(s)'), 
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
                                              draggable = TRUE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, 
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              radioButtons('var_sel', 
                                                           label = h4('Variable'), 
                                                           choices = list('Temperature (C)' = 'tmp2m', 
                                                                          'Precipitation Rate (mm/d)' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              radioButtons('lead_sel', 
                                                           label = h4('Bi-weekly Forecast Period'), 
                                                           choices = list('1-2 Week Forecast' = '1_2wk',
                                                                          '2-3 Week Forecast' = '2_3wk',
                                                                          '3-4 Week Forecast' = '3_4wk'), 
                                                           selected = '1_2wk'
                                              ),
                                              selectInput('stat_sel', 
                                                          label = h4('Statistic'), 
                                                          choices = list('Anomaly Correlation' = 'acc',
                                                                         'Bias' = 'meanErr',
                                                                         'Percent Bias' = 'pbias'), 
                                                          selected = 'acc'
                                              ),
                                              selectInput('season_sel', 
                                                          label = h4('Time Period: Annual or Seasonal'), 
                                                          choices = list('Annual' = '0',
                                                                         'JFM' = '1',
                                                                         'FMA' = '2',
                                                                         'MAM' = '3',
                                                                         'AMJ' = '4',
                                                                         'MJJ' = '5',
                                                                         'JJA' = '6',
                                                                         'JAS' = '7',
                                                                         'ASO' = '8',
                                                                         'SON' = '9',
                                                                         'OND' = '10',
                                                                         'NDJ' = '11',
                                                                         'DJF' = '12'), 
                                                          selected = '0'
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
                                              draggable = TRUE, 
                                              top = 60, 
                                              left = 'auto', 
                                              right = 3, #move panel to right (otherwise 'auto')
                                              bottom = 'auto',  
                                              width  =  330, 
                                              height = 'auto',
                                              radioButtons('var_nmme_sel', 
                                                           label = h4('Variable'), 
                                                           choices = list('Temperature (C)' = 'tmp2m', 
                                                                          'Precipitation Rate (mm/d)' = 'prate'), 
                                                           selected = 'tmp2m'
                                              ),
                                              radioButtons('lead_nmme_sel', 
                                                           label = h4('Forecast Lead'), 
                                                           choices = list('Month 0 Forecast' = '0',
                                                                          'Month 1 Forecast' = '1',
                                                                          'Month 2 Forecast' = '2',
                                                                          'Season 0 Forecast' = 'season0',
                                                                          'Season 1 Forecast' = 'season1'), 
                                                           selected = '0'
                                              ),
                                              selectInput('stat_nmme_sel', 
                                                          label = h4('Statistic'), 
                                                          choices = list('Anomaly Correlation' = 'acc',
                                                                         'Bias' = 'bias',
                                                                         'Percent Bias' = 'pbias'), 
                                                          selected = 'acc'
                                              ),
                                              selectInput('season_nmme_sel', 
                                                          label = h4('Forecast Dates: All or Seasonal'), 
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
                                              selectInput('mdl_nmme_sel', 
                                                          label = h4('Model(s)'), 
                                                          choices = list('NMME Average' = 'nmme',
                                                                         'CFSv2' = 'CFSv2',
                                                                         'CMC1' = 'CMC1',
                                                                         'CMC2' = 'CMC2',
                                                                         'GFDL' = 'GFDL',
                                                                         'GFDL_FLOR' = 'GFDL_FLOR',
                                                                         'NASA' = 'NASA',
                                                                         'NCAR_CCSM4' = 'NCAR_CCSM4'), 
                                                          selected = 'nmme'
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
