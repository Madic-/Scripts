#!/usr/bin/env bash
### Use with nagios event handler.
### Based on https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/eventhandlers.html
### Written for check_mk and https://www.geekbundle.org/selbstheilung-mit-check_mk-event-handler
###
### Written by Madic - madic@geekbundle.org 2018-06

SERVICESTATE="$1"
SERVICESTATETYPE="$2"
HOSTADDRESS="$3"
LOG=~/var/log/eventhandler.log

exec &>"$LOG"

CLEANUP() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") Doing cleanup on $HOSTADDRESS through ${0##*/} Script..."
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user@"$HOSTADDRESS" sudo /usr/local/sbin/cleanup.sh
}

case "$SERVICESTATE" in
OK)
	;;
WARNING)
    case "$SERVICESTATETYPE" in
    SOFT)
        ;;
    HARD)
        CLEANUP
        ;;
    esac
	;;
UNKNOWN)
	;;
CRITICAL)
	case "$SERVICESTATETYPE" in
	SOFT)
        ;;
	HARD)
        CLEANUP
		;;
	esac
	;;
esac
exit 0