#!/bin/bash
#       Tamir Scheinok 2019-01-17
#       v1.0
#       Set Permissions on a series of folders in Egnyte
# 		Include the notest flag if you want to run this in production mode (make actual changes to folder permissions)

# 	Replace <CLIENTID> with what is returned by the egnyte.getapitoken.sh script.  The token doesnt expire unless the associated user's credentials are modified.
# 	https://developers.egnyte.com/docs/read/Public_API_Authentication
CLIENT_ID="<CLIENTID>;


# 	This file contains two columns in TSV format. The first column is the directory (encoded - use the provided excel file to do this) to be operated on. The second a JSON snippet for the desired permissions:
# 	Column 1 example: 	/Shared/Account%5FManagement
# 	Column 2 example: 	{"groupPerms":{"Staff":"Owner","Egnyte-Users":"None"},"inheritsPermissions":"false","keepParentPermissions":"false"}
MAPFILE="egynte.perms.txt";


# 	reference curl commands that work
#	curl -v  POST -H "Authorization: Bearer $CLIENT_ID" -H "Content-Type: application/json" -d '{"groupPerms":{"Egnyte-Users":"Full"},"inheritsPermissions":"false","keepParentPermissions":"false"}' https://acmecorporation.egnyte.com/pubapi/v2/perms/Shared/Test
#	curl -v  POST -H "Authorization: Bearer asdfasyqtadsdfdfasmkkww" -d https://acmecorporation.egnyte.com/pubapi/v1/fs/Shared/Clients/AstoundCommerce
# 	remove the -v and add --silent for clean output

# 	Output operation mode. Testing or Production
echo -e "--------------------------------------------"
if [[ $1 == notest ]]; then
    echo "Running for Realz";
else
    echo "Running in Testing Mode";  
fi
echo -e "--------------------------------------------\n\n"


# this function parses json variables for different permission options into global variables
# we strip out "null" where appropriate for cleaner output
JSON_VARS(){
	JSON=$1
	#echo $API_PERMS_POST | jq '.';
	#echo ${API_PERMS_POST} | jq '.groupPerms';
	#echo ${API_PERMS_POST} | jq '.inheritsPermissions';
	PERM_STAFF=`echo ${1} | jq '.groupPerms."Staff"'`;
	if [ $PERM_STAFF = "null" ];
	 then PERM_STAFF="";
	fi
	PERM_CLIENT=`echo ${1} | jq '.groupPerms."Client Admin"'`;
	if [ $PERM_CLIENT = "null" ];
	 then PERM_CLIENT="";
	fi
	PERM_DIR=`echo ${1} | jq '.groupPerms."Directors"'`;
	if [ $PERM_DIR = "null" ];
	 then PERM_DIR="";
	fi
	PERM_FIN=`echo ${1} | jq '.groupPerms."Finance"'`;
	if [ $PERM_FIN = "null" ];
	 then PERM_FIN="";
	fi
	PERM_HR=`echo ${1} | jq '.groupPerms."HumanResources"'`;
	if [ $PERM_HR = "null" ];
	 then PERM_HR="";
	fi
	PERM_EGNYTE=`echo ${1} | jq '.groupPerms."Staff"'`;
	if [ $PERM_EGNYTE = "null" ];
	 then PERM_EGNYTE="";
	fi
	PERM_INHERIT=`echo ${1} | jq '.inheritsPermissions'`;
}

# read in configuration file
OLDIFS=$IFS
IFS=$'\t'
[ ! -f $MAPFILE ] && { echo "$MAPFILE file not found"; exit 99; }

# loop on each line in configuration file
while read DIR PERMS_TO BLANK
	do
 		# Cleanup Quotes from Excel (ugliness)
		PERMS_TO=`echo $PERMS_TO | sed "s/\"\"/|/g"`
 		PERMS_TO=`echo $PERMS_TO | sed "s/\"//g"`
 		PERMS_TO=`echo $PERMS_TO | sed "s/|/\"/g"`

		# Print Directory Path and intended permissions
		printf "%-53s %s \n" "$DIR" "$PERMS_TO"

		# Determine permissions before we attempt the change
		API_PERMS_PRE=$(curl  --silent --request GET -H "Authorization: Bearer $CLIENT_ID" https://acmecorporation.egnyte.com/pubapi/v2/perms/$DIR)

		if [[ $1 == notest ]]; then
			sleep 1.1;  # need to rate limit to 2 API calls per second
			# If we are in production mode (notest flag) attempt the change
			API_PERMS_CHANGE=$(curl -silent POST -H "Authorization: Bearer $CLIENT_ID" -H "Content-Type: application/json" -d "$PERMS_TO" https://acmecorporation.egnyte.com/pubapi/v2/perms$DIR);
		fi
		
		sleep 1.1;  # need to rate limit to 2 API calls per second
		API_PERMS_POST=$(curl --silent --request GET -H "Authorization: Bearer $CLIENT_ID" https://acmecorporation.egnyte.com/pubapi/v2/perms/$DIR)
		
		printf "%-15s | %-15s | %-15s | %-15s | %-15s| %-15s | %-15s | %-15s \n" "      " "STAFF"       "CLIENT ADMIN" "DIRECTORS" "FINANCE"   "HR"       "EGNYTE"       "INHERIT"
		JSON_VARS $API_PERMS_PRE
		printf "%-15s | %-15s | %-15s | %-15s | %-15s| %-15s | %-15s | %-15s \n" "PRE   " "$PERM_STAFF" "$PERM_CLIENT" "$PERM_DIR" "$PERM_FIN" "$PERM_HR" "$PERM_EGNYTE" "$PERM_INHERIT"
		JSON_VARS $PERMS_TO
		printf "%-15s | %-15s | %-15s | %-15s | %-15s| %-15s | %-15s | %-15s \n" "CHANGE" "$PERM_STAFF" "$PERM_CLIENT" "$PERM_DIR" "$PERM_FIN" "$PERM_HR" "$PERM_EGNYTE" "$PERM_INHERIT"
		JSON_VARS $API_PERMS_POST
		printf "%-15s | %-15s | %-15s | %-15s | %-15s| %-15s | %-15s | %-15s \n" "POST  " "$PERM_STAFF" "$PERM_CLIENT" "$PERM_DIR" "$PERM_FIN" "$PERM_HR" "$PERM_EGNYTE" "$PERM_INHERIT"
		echo -e "\n\n";
		
	done < $MAPFILE

# Restore File Separators
IFS=$OLDIFS

echo -e "\n\n-----------------------------------------------\nAll Directories Processed.  Done\n\n\n";
exit 0
