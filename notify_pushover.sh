#!/bin/sh
set -Cefu

# Read configuration.
read API_TOKEN < /etc/pushover/token
read API_USER  < /etc/pushover/user
read PRIORITY  < /etc/pushover/priority

# Import pam_exec environment variables.
SERVICE="${PAM_SERVICE:-Unknown Service}"
  RUSER="${PAM_RUSER:-Unknown remote user}"
  RHOST="${PAM_RHOST:-Unknown Host}"
   USER="${PAM_USER:-Unknown User}"

# Record hostname and time.
DATE="$(date -u +'%F %T')"
HOST="$(hostname)"

# Set title and message text.
TITLE="${SERVICE:?}: ${USER:?}@${HOST:?} from $USER@$RHOST"
TEXT="${DATE:?}"

# Discard output.
exec >/dev/null 2>&1

# Become curl.
exec curl -s \
	-F "token=${API_TOKEN:?}" \
	-F "user=${API_USER:?}" \
	-F "title=${TITLE:?}" \
	-F "message=${TEXT:?}" \
	-F "priority=${PRIORITY:?}" \
		https://api.pushover.net/1/messages.json
