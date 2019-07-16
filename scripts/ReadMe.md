## Real-time Processing for S2S Website

### All scripts here are used to process CFSv2 & NMME forecasts in real-time
- NMME scripts are in nmme_scripts folder
- CFSv2 scripts are in base folder while nmme scripts are in subfolder
- NLDAS folder was for testing realtime verification
- There are some reprocessing scripts to re download data if error is found
- All scripts were created from scripts made by sabaker in '/home/sabaker/s2s/cfsv2/scripts'

### Real-time processing notes
   - crontab is used to run CFSv2 processing script daily and NMME script monthly (on the 9th day)
   - Access crontab with -l (for list) and -e (for editing)
   - CFSv2 master script: */home/hydrofcst/s2s/scripts/exec_process_cfs.bash*
   - NMME master script: */home/hydrofcst/s2s/scripts/nmme_scripts/exec_process_nmme_iri.bash*
   
### CFSv2 Processing 
- `exec_process_cfs.bash`: runs daily after all forecasts are produced and downloaded from /d2/anewman/wrf_hydro/cfsv2.
- `process_cfs_realtime.csh`: script converst grib2 to netcdfs, regrids, cuts domain, takes weighted average for HUC4s, averages to bi-weekly time periods, and takes ensemble averages for each initialization (every 6-hrs).
- `process_cfs_4Shiny_QM.Rscr`: analyzes real-time forecasts, calculates anomalies, QM fcst, saves old data once per month and reduces data displayed on site to keep site fast
- If there is an error that occurs and the site is not updating, start by looking at the raw processed CFSv2. Sometimes the forecasts produce bad files with the extention .pidxxxxxx.ncea.tmp. These need to be deleted to run the R script to completion. 

### NMME Processing
- `exec_process_nmme_iri.bash`: runs monthly to download, process, and update site.
- `dwnld_nmme_fcsts_iri.csh`: downloads the NMME ensemble average from the IRI website. Sometimes the naming conventions change and will need to be updated here. 
- `process_nmme_fcst_iri.csh`: processing NMME the same as CFSv2 (see above).
- `process_nmme_realtime_iri.Rscr`: ananlyze real-time NMME forecast, calculating anomalies, ensemble average, copying to website folder.
- `hcst_scripts/` used to reprocess hindcasts of NMME when necessary. See ReadMe in folder for information.

### Notes for S2S site:
Output from these scripts are referenced in the S2S-app folder which contains the files for the web-app.

### CFSv2 Rerun
- Rerun scripts if there is an error or processing didnt occur for a specific day
- `get_rawCFSv2_grb2Data_rerun.bash`: download raw data - need to update dates
- `exec_process_cfs_rerun.bash`: process raw data to watershed scale - need to update dates
- rerun Rscripts which will copy to S2S web-app
