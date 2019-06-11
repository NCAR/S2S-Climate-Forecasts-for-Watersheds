## Bi-weekly CFSv2 Data Processing & Analysis

### Preliminary Data Processing

Reforecasts for Climate Forecast System version 2 (CFSv2; Saha et al., 2013) have been downloaded and analyzed for skill for different time period averages. Reforecasts of temperature and precipitation rate have 100 km (0.93 degree) grid spacing at a 6-hour timestep from 1999 through 2010 and are available [here](https://nomads.ncdc.noaa.gov/data/cfsr-hpr-ts45/). The reforecasts were initialized each day at four synoptic times:  0000 UTC, 0006 UTC, 0012 UTC, and 0018 UTC. The 0000 UTC forecast extends to the end of a full season (end of the fourth month), while the 0006, 0012, and 0018 UTC forecasts extend for 45 days. 

The raw CFSv2 temperature and precipitation reforecasts were reprojected from a native Gaussian grid to a 1/2th-degree grid, temporally averaged to a daily timestep, and then aerially averaged to USGS HUC4 spatial units using a spatially conservative remapping script. The reforecasts were then temporally averaged to bi-weekly time periods (e.g. 1-2 week, 2-3 week, 3-4 week) to support a skill analysis at the sub-seasonal HUC resolution. 

The forcing data is from Phase 2 of the North American Land Data Assimilation System (NLDAS-2; Xia et al, 2012). NLDAS-2 is available at 1/8th-degree grid spacing and ranges from 1979 to present at an hourly temporal resolution. Similar to the CFSv2 reforecasts, NLDAS-2 precipitation and temperature were spatially and temporally aggregated to a daily 1/2th-degree grid (common to both datasets) before further aggregation to the sub-seasonal HUC4 space-time resolution. All datasets are stored in NetCDF format. 

### CFSv2 Skill Analysis

The pre-processing steps created 12 years of daily-updated 4-member ensemble forecasts and matching observations of mean precipitation and temperature for 2-week predictand periods at lead times of 0, 1, and 2 week, for the 202 HUC4 units covering CONUS.  

From these datasets, day-of-year (DOY) climatologies for the forecasts and observations were calculated, using all forecasts and observations within a moving 11-day window (+/- 5 days from the forecast and observation period start DOY).  

The DOY climatologies were then used to convert the forecast and observation time series to anomalies (additive for temperature and precipitation, and also multiplicative for precipitation).

The following statistics were then calculated on the average of the 4 daily forecast ensemble members: bias, mean absolute error, percent bias, correlation, and anomaly correlation. The results for selected statistics are shown on the 'CFSv2 Skill' tab. 

### Raw Real-time CFSv2 Forecasts

Similar to the CFSv2 reforecasts, real-time forecasts are initialized each day at the four synoptic times, but in contrast to the retrospective runs, each initialization produces 4 ensemble members for a total of 16 forecasts each day of various lengths:  four extend out to 9 months, three to 1 season, and nine to 45 days. 

The CFSv2 operational 16-member ensemble is downloaded each day and processed as described above. Once the HUC4 average bi-weekly temperature and precipitation fields are processed, the mean of each field is subtracted from the CFSv2 DOY forecast climatologies to produce anomalies. The results are presented in the 'CFSv2 Forecasts' tab. 

### Bias-Corrected Real-time CFSv2 Forecasts

The raw CFSv2 forecasts are bias-corrected using the Quantile Mapping (QM) method, also called CDF-matching. QM replaces the CFSv2 forecast value with a value from the observed climatology (NLDAS) that has the same quantile. This is done by estimating a pair of cumulative distribution functions (CDFs) for CFSv2 and NLDAS for each variable, lead time (bi-weekly forecast period), watershed, and DOY. The DOY climatologies are based on a 15-day window (+/- 7 days) from the forecasted date.  Empirical CDFs are used, and when forecasted values lie outside the quantile range, the two closest quantiles are used linearly extrapolation the new value. 

QM removes the systematic bias between the forecasted and observed climatologies, but does not further calibrate the forecasts to account for their skill.   QM is a general method that has long been applied to weather forecasts (Panofsky and Brier, 1968) and later to climate forecasts, as demonstrated in [Wood et al, 2002]( http://onlinelibrary.wiley.com/doi/10.1029/2001JD000659/abstract).

The distinction between bias correction and forecast calibration, and the QM method, are further described in [Wood and Schaake, 2008](http://journals.ametsoc.org/doi/full/10.1175/2007JHM862.1), and [Zhao et al, 2017](http://journals.ametsoc.org/doi/abs/10.1175/JCLI-D-16-0652.1).  The method is also discussed [here](https://www.esrl.noaa.gov/psd/people/michael.scheuerer/CSGD-AppendixA.pdf). 

The results are available on the 'CFSv2 Forecasts' tab by choosing the 'Bias-Corrected (QM)' forecast type. 

At present only the raw and bias-corrected CFSv2 anomaly forecasts are displayed. Additional post-processing approaches and forecast products are in development and will be added to the real-time display after product validation. 

## Monthly NMME Data Processing & Analysis

### Preliminary Data Processing

The North American Multimodel Ensemble Phase 2 ([NMME-2](http://www.cpc.ncep.noaa.gov/products/NMME/about.html); Kirtman et al., 2014) is a combination of seven global climate models which predict precipitation and temperature (along with other variables) at a monthly timestep for leads up to 7 months. Hindcasts are available for 1982-2010 and real-time model forecasts are available for 2011-present. The models included in NMME-2 are: 
-	CFSv2 -  NOAA NCEP Climate Forecast System version 2
-	NASA - Goddard Space Flight Center (GSFC) GEOS5
-	NCAR_CCSM4 - NCAR/University of Miami CCSM4.0
-	GFDL - CM2.1
-	GFDL_FLOR - CM2.5 [FLORa06 and FLORb01]
-	CMC3 - Environment Canada CanCM3
-	CMC4 - Environment Canada CanCM4

Raw temperature and precipitation hindcasts are reprojected from a 1-degree grid onto a 1/2th-degree grid and spatially averaged to USGS HUC4 spatial units using a spatially conservative remapping script. Climatologies are calculated for each NMME model, watershed, and forecasted month or season. NMME climatologies and NLDAS-2 climatologies are used to calculate forecast anomalies.  In general, the processing approach is similar to the steps used for CFSv2 forecasts. 

Bias, percent bias, and anomaly correlation are calculated from the ensemble-mean anomalies and climatologies for 0, 1 and 2-month forecast lead times for monthly predictands, and for the 0-month lead time for the seasonal (months 0-2) lead times.  These verification statistics are displayed for each NMME model, forecast lead, season, and variable in the 'NMME Skill' tab.

### Real-time NMME Forecasts

NMME forecasts are updated monthly by the 8th day of each month. The ensemble means for each of the 7 models listed above are downloaded and processed to watershed scale. The real-time data shows the forecast for the 1, 2, and 3-month forecast lead time (ie. not including the first or forecast month). The 1-month seasonal lead (months 1-3) is also displayed. 

The ensemble means from the 7 models are averaged to calculate the NMME average forecast.  At present only these raw NMME anomaly forecasts are displayed, as well as their associated skill.  More NMME related products will be added as their validation is complete.

#### References

Kirtman, B. P., et al. (2014). The North American Multimodel Ensemble: Phase-1 Seasonal-to-Interannual Prediction; Phase-2 toward Developing Intraseasonal Prediction. Bulletin of the American Meteorological Society, 95(4), 585-601. doi:10.1175/BAMS-D-12-00050.1

Panofsky, H.A. and Brier, G.W. (1968). Some Applications of Statistics to Meteorology. Earth and Mineral Sciences Continuing Education, College of Earth and Mineral Sciences, Penn. State University. 

Saha, S., et al. (2013). The NCEP Climate Forecast System Version 2. Journal of Climate, 27(6), 2185-2208. doi:10.1175/JCLI-D-12-00823.1.

Wood, AW and JC Schaake (2008). Correcting errors in streamflow forecast ensemble mean and spread, J. Hydromet. 9:1, 132-148.

Wood, AW, EP Maurer, A Kumar and DP Lettenmaier (2002).  Long Range Experimental Hydrologic Forecasting for the Eastern U.S., J. Geophys. Res., 107(D20), doi:10.1029/2001JD000659.

Xia, Y., et al. (2012), Continental-scale water and energy flux analysis and validation for the North American Land Data Assimilation System project phase 2 (NLDAS-2): 1. Intercomparison and application of model products, J. Geophys. Res., 117, D03109, doi:10.1029/2011JD016048.

Zhao, T, JC Bennett, QJ Wang, A Schepen, AW Wood, DE Robertson, and M Ramos (2017). How Suitable is Quantile Mapping For Postprocessing GCM Precipitation Forecasts?. J. Climate, 30, 3185-3196, https://doi.org/10.1175/JCLI-D-16-0652.1
