#!/bin/bash
# Name : my-functions.sh
# Autor: Carsten Söhrens

##############################################################################
# Echo date/time plus optional additional information
# Globals:
#   None
# Arguments:
#   Optional, multiple aruguments are processed in one line
# Returns:
#   None
##############################################################################
echolog(){
if [[ $1 ]] ; then
	echo "$(date +"%F %T"), $*"
else
	echo "$(date +"%F %T")"
fi
}
