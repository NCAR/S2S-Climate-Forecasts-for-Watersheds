# S2S Climate Outlooks for Watersheds web-app
This web-app is built with R Shiny and can be found at [http://hydro.rap.ucar.edu/s2s/](http://hydro.rap.ucar.edu/s2s/). The data files referenced in the ui, server, and global files are not added to GitHub because of size. The data files for the real-time part of the web-app are produced using scripts found in the scripts/ directory.

### Notes for website
1. Log into directory of site.
   - `ssh -X userXXX@hydro-c1-web.rap.ucar.edu`
   - Note - This might only work on my account. I'm not sure if others can do these steps with current permissions
   - Navigate to : `/opt/srv/shiny-server/S2S-app/`

2. The shiny server now needs to be restarted so that the server can read the new file. Tor made it so we can restart on our account.
   - `sudo /bin/systemctl restart shiny-server.service`
   - You can use the following commands for systemctl: start stop restart status
   - Note the "sudo /bin/systemctl" part is important syntax.
   - Contact Tor with any problems here

