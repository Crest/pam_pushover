# pam_pushover
A little FreeBSD specific helper script to send [Pushover](https://pushover.net) notifications on login via [pam_exec(8)](https://man.freebsd.org/pam_exec).

Inspired by this [blog post](https://medium.com/privacyguides/enabling-pushover-notifications-on-successful-ssh-logins-a0f984cfbd9d).

## Setup
* Install curl: `pkg install curl`
* Install script: `install -v -S -m 755 -o root -g wheel notify_pushover.sh /sbin`
* Create config directory: `mkdir -v -p -m 750 /etc/pushover`
* Create group: `pw groupadd pushover`
* Create user: `pw useradd pushover -g pushover -c 'Pushover user' -d /var/empty -s /bin/sh`
* Configure Pushover "client".
	* Configure user: `echo $API_USER > /etc/pushover/user` (shown on [Start page](https://pushover.net/) when logged in).
	* Configure token: `echo $API_TOKEN > /etc/pushover/token` (register on [Create New Application](https://pushover.net/apps/build)).
	* Configure priority: `echo $PRIORITY > /etc/pushover/priority` (use `0` unless you need a higher priority).
* Configure PAM:
	* Add line to PAM configuration (e.g. `/etc/pam.d/sshd`): `session         optional        pam_exec.so             /sbin/notify_pushover.sh`

## Limitations
* Undelivered notifications aren't persisted to disk.
