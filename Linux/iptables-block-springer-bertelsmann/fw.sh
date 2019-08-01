#!/bin/bash

# Übernommen und angepasst von:
# https://www.heise.de/forum/heise-online/News-Kommentare/Schon-wieder-Axel-Springer-verklagt-Adblock-Plus/gibt-es-eine-Moeglichkeit-Axel-Springer-anhand-der-IPs-zu-blocken/thread-5948658/#posting_34287392

# Springer Verlag
# AS200757
# AS8792

# Bertelsmann AG
# AS1663
# AS24501

declare -a ASN=(AS200757 AS8792 AS1663 AS24501)
BLOCKLIST=""
BLOCKLIST6=""

#For IPv4 Blocking
for AS in ${ASN[@]}; do
    SNET=$(whois -h whois.radb.net -- -i origin "$AS" | awk '/^route:/ {print $2;}' | sort | uniq)
    BLOCKLIST="${BLOCKLIST} $SNET"
done

echo "IPv4 blocklist:"
for SUBNET in $BLOCKLIST; do
    echo "iptables -I OUTPUT -d $SUBNET -j REJECT"
    iptables -I OUTPUT -d $SUBNET -j REJECT
done

#For IPv6 Blocking
for AS in ${ASN[@]};  do
    SNET=$(whois -h whois.radb.net -- -i origin "$AS" | awk '/^route6:/ {print $2;}' | sort | uniq)
    BLOCKLIST6="${BLOCKLIST6} $SNET"
done

echo -e "\nIPv6 blocklist:"
for SUBNET in $BLOCKLIST6; do
    echo "ip6tables -A OUTPUT -d $SUBNET -j REJECT"
    ip6tables -I OUTPUT -d $SUBNET -j REJECT
done
