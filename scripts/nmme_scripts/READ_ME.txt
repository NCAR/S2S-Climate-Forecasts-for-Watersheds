Download NMME data from IRI in real-time

# download nmme for current month (after the 8th)
dwnld_nmme_fcsts_iri.csh

# process and average to HUCs
process_nmme_fcst_iri.csh

# process for shiny app and copies over to web server
process_nmme_realtime_iri.Rscr
