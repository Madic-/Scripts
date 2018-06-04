#!/usr/bin/env bash

SERVICESTATE="$1"
SERVICESTATETYPE="$2"
HOSTADDRESS="$3"
LOG=~/var/log/eventhandler.log

exec &>"$LOG"

echo -e "\n$(date +"%Y-%m-%d %H:%M:%S") Running ${0##*/}"
echo "$(date +"%Y-%m-%d %H:%M:%S") SERVICESTATE=$SERVICESTATE"
echo "$(date +"%Y-%m-%d %H:%M:%S") SERVICESTATETYPE=$SERVICESTATETYPE"
echo "$(date +"%Y-%m-%d %H:%M:%S") HOSTADDRESS=$HOSTADDRESS"

if ([ "$SERVICESTATE" == WARNING ] || [ "$SERVICESTATE" == CRITICAL ]) && [ "$SERVICESTATETYPE" == HARD ]; then
echo "$(date +"%Y-%m-%d %H:%M:%S") Running ssh command..."
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user@"$HOSTADDRESS" sudo /usr/local/sbin/cleanup.sh
fi