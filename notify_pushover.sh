#!/bin/sh

# Catch common bugs.
set -Cefu

# Read configuration.
load_config() {
	readonly CONFIG_DIR='/etc/pushover'
	readonly API_TOKEN_FILE="${CONFIG_DIR:?}/token"
	readonly API_USER_FILE="${CONFIG_DIR:?}/user"
	readonly PRIORITY_FILE="${CONFIG_DIR:?}/priority"

	if read -r API_TOKEN < "${API_TOKEN_FILE:?}"; then
		readonly API_TOKEN
	else
		STATUS=$?
		echo "Failed to read API_TOKEN from '${API_TOKEN_FILE:?}'." >&2
		exit $STATUS
	fi

	if read -r API_USER  < "${API_USER_FILE:?}"; then
		readonly API_USER
	else
		STATUS=$?
		echo "Failed to read API_USER from '${API_USER_FILE:?}'." >&2
		exit $STATUS
	fi

	if [ -s "${PRIORITY_FILE:?}" ]; then
		if read -r PRIORITY < "${PRIORITY_FILE:?}"; then
			readonly PRIORITY
		else
			STATUS=$?
			echo "Failed to read priority from '${PRIORITY_FILE:?}'." >&2
			exit $STATUS
		fi
	else
		readonly PRIORITY='0'
	fi
}

# Import pam_exec environment variables.
import_env() {
	readonly SERVICE="${PAM_SERVICE:-"!!! Unknown service !!!"}"
	readonly   LUSER="${PAM_USER:-"!!! Unknown local user !!!"}"
	readonly   RUSER="${PAM_RUSER:-"!!! Unknown remote user !!!"}"
	readonly   RHOST="${PAM_RHOST:-"!!! Unknown remote host !!!"}"
}

# Record hostname and time,
# set title and message text.
capture_state() {
	LHOST="$(hostname)"         && readonly LHOST
	 DATE="$(date -u +'%F %T')" && readonly DATE
	readonly TITLE="${SERVICE:?}: ${LUSER:?}@${LHOST:?} from $RUSER@$RHOST"
	readonly TEXT="${DATE:?}"
}

# Run daemonized curl with retries.
notify() {
	readonly API_URL='https://api.pushover.net/1/messages.json'
	readonly RETRIES='10000'         # Try up to 10,000 times.
	readonly MAX_TIME='10'           # Limit each attempt to 10 seconds.
	readonly RETRY_DELAY='0'         # Use exponentional backoff up to 10 minutes.
	readonly RETRY_MAX_TIME='604800' # Give up after one week.
	readonly CURL_USER='pushover'    # Run cron as dedicated user.

	daemon  --change-dir                                   \
		--close-fds                                    \
		--title "${TITLE:?}"                           \
		--user "${CURL_USER:?}"                        \
		--                                             \
		curl    --silent                               \
			--retry-connrefused                    \
			--retry-all-errors                     \
			--retry          "${RETRIES:?}"        \
			--max-time       "${MAX_TIME:?}"       \
			--retry-delay    "${RETRY_DELAY:?}"    \
			--retry-max-time "${RETRY_MAX_TIME:?}" \
			--form    "token=${API_TOKEN:?}"       \
			--form     "user=${API_USER:?}"        \
			--form    "title=${TITLE:?}"           \
			--form  "message=${TEXT:?}"            \
			--form "priority=${PRIORITY:?}"        \
			--                                     \
			"${API_URL:?}"
}

# Pretend shell is saner language than it really is.
main() {
	load_config   &&
	import_env    &&
	capture_state &&
	silence       &&
	notify
}

main "$@"
