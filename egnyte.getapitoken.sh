#!/bin/bash
#       Tamir Scheinok 2019-01-17
#       v1.0
#       Request API Token

# 	Replace the following
#	<yourusername>	Your egnyte username
#	<yourpassword>	Your egnyte password
#	<egnytedomain> 	Your Egnyte domain
#	<yourclientID>. Get this here https://developers.egnyte.com/member/register .  It take a few hours for Egnyte to approve for internal use.

curl -v --data-urlencode 'grant_type=password' --data-urlencode 'username=<yourusername>' --data-urlencode 'password=<yourpassword>' --data-urlencode 'client_id=<yourclientID>' https://<egnytedomain>.egnyte.com/puboauth/token
