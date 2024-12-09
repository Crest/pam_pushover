#!/bin/sh
set -Cefu

# Read configuration
read API_TOKEN < /etc/pushover/token
read API_USER  < /etc/pushover/user
read PRIORITY  < /etc/pushover/priority

# Import pam_exec environment variables.
   TYPE="${PAM_TYPE:-Unknown Type}"
SERVICE="${PAM_SERVICE:-Unknown Service}"
    TTY="${PAM_TTY:-Unknown TTY}"
  RHOST="${PAM_RHOST:-Unknown Host}"
   USER="${PAM_USER:-Unknown User}"

# Record hostname and time
DATE="$(date -u +'%F %T')"
HOST="$(hostname)"

TITLE="${SERVICE:?}: ${USER:?}@${HOST:?} on $TTY from $RHOST"
TEXT="${DATE:?}: $TYPE"

[ "${TYPE:?}" = 'close_session' ] || curl -s \
	-F "token=${API_TOKEN:?}" \
	-F "user=${API_USER:?}" \
	-F "title=${TITLE:?}" \
	-F "message=${TEXT:?}" \
	-F "priority=${PRIORITY:?}" \
		https://api.pushover.net/1/messages.json >/dev/null 2>&1
