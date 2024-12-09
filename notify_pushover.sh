#!/bin/sh
set -Cefu

# Change these variables
API_TOKEN='<<TOKEN>>'
API_USER='<<USER>>'
PRIORITY=0

TYPE="${PAM_TYPE:-Unknown Type}"
SERVICE="${PAM_SERVICE:-Unknown Service}"
TTY="${PAM_TTY:-Unknown TTY}"
HOST="$(hostname)"
RHOST="${PAM_RHOST:-Unknown Host}"
USER="${PAM_USER:-Unknown User}"

DATE="$(date -u +'%F %T')"

TITLE="${SERVICE:?}: ${USER:?}@${HOST:?} on $TTY from $RHOST"
TEXT="${DATE:?}: $TYPE"

if [ "$PAM_TYPE" != "close_session" ]; then
	echo curl -s \
		-F "token=${API_TOKEN:?}" \
		-F "user=${API_USER:?}" \
		-F "title=${TITLE:?}" \
		-F "message=${TEXT:?}" \
		-F "priority=${PRIORITY:?}" \
		https://api.pushover.net/1/messages.json # >/dev/null 2>&1
fi
