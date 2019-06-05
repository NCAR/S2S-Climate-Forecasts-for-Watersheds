Scripts for processing NMME hindcasts (runas hydrofcst)
- NOTE: edited process to allow for downloading files from IRI (mainly so we could get new NASA hindcasts). This process hasnt been tested with other NMME models.

1. Preliminary download and data aggregation
  - dwnld_nmme_hcsts_iri.csh 
  - process_nmme_fcst_iri.csh

2. Process hindcasts in R
  - 1_merge_nmme_hcst_iri.R
  - 2_calcAnom_hcst.R
  - 3_calc_statistics_hcst.R

3. Copy 'nmme_nldas_stats.rds' to hydro-c1-web
  - In R, run the following line of code. This is also located at the bottom of the script 3_calc_statistics_hcst.R:
     system('echo "put /d2/hydrofcst/s2s/nmme_processing/R_output/nmme_nldas_stats.rds /d1/www/html/s2s/S2S-app/realtime/" | sftp -i /home/hydrofcst/.ssh/hydrotxfr hydrofcst@hydro-c1-web')

4. Once the file is copied to hydro-c1-web, it needs to be copied to the correct folder to be displayed online. 
   - ssh -X sabaker@hydro-c1-web.rap.ucar.edu 
   - note - I'm not sure if others can do these steps with current permissions
   - Navigate to : /opt/srv/shiny-server/S2S-app/
   - copy file to web app folder: nmme_nldas_stats.rds
       cp /d1/www/html/s2s/S2S-app/realtime/nmme_nldas_stats.rds nmme_nldas_stats.rds

5. The shiny server now needs to be restarted so that the server can read the new file. Tor made it so we can restart on our accoutn
   - tor@hydro-c1-web:~$ sudo /bin/systemctl restart shiny-server.service
   - You can use the following commands for systemctl: start stop restart status
   - Note the "sudo /bin/systemctl" part is important syntax.

Contact Tor with any problems here

- Note: copied files from sabaker
