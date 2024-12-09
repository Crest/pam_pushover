# Setup

* Install script: `install -v -S -m 755 -o root -g wheel notify_pushover.sh /sbin`
* Create config directory: `mkdir -v -p -m 750 /etc/pushover`
* Configure system.
	* Configure user: `echo $API_USER > /etc/pushover/user` (shown on [Start page](https://pushover.net/) when logged in).
	* Configure token: `echo $API_TOKEN > /etc/pushover/token` (register on [Create New Application](https://pushover.net/apps/build)).
	* Configure priority: `echo $PRIORITY > /etc/pushover/priority` (use `0` unless you need a higher priority).
