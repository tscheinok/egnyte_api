# egnyte_api

This project can be used to modify permissions for a large number of Egnyte folders.

  + The getapitoken.sh script is run to get the API Token required in the perms.sh script.

  + The permns.sh script is what is used to modify permissions on a list of Egnyte folders that is specified in the perm.txt file.

  + The perms.txt file is a tab separated value file that contains the list of folder paths and permissions in JSON format.

  + The perms.xlsx file is an option excel file used for encoding the path URLs.
  
This project is designed and built for OSX on running Mojave. Your mileage may vary on other xnix variants.  Requires jq JSON parser to be installed.
