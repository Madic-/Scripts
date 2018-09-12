#!/usr/bin/env bash
### This script will either extract all certificates from a java keystore to the folder ./cacerts_export
### or import all certificates from the folder ./cacerts_export into the supplied keystore.
###
### Import
### cacerts_build.sh IMPORT ./cacerts
###
### Export
### cacerts_build.sh EXPORT ./cacerts
###
### Written by Michael Neese <madic@geekbundle.org>

DEST=./cacerts_export
STOREPASS=changeit
KEYSTORE="$2"

USAGE() {
    echo -e "Usage: ${0##*/} [EXPORT|IMPORT] KEYSTORE"
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then USAGE; fi
if [ ! -d "$DEST" ]; then mkdir -p "$DEST"; fi

if [ "$1" = "EXPORT" ]; then
for CERT in $(keytool -list -keystore $KEYSTORE -storepass "$STOREPASS" | grep trustedCertEntry | grep -Eo "^[^,]*"); do
    echo -e "\nExtracting $CERT.crt..."
    keytool -exportcert -storepass "$STOREPASS" -keystore "$KEYSTORE" -rfc -alias "$CERT" -file "$DEST"/"$CERT".crt
	if [ ! -s "$DEST"/"$CERT".crt ]; then echo "Deleting $DEST/$CERT.crt because it's empty..."; rm "$DEST"/"$CERT".crt; fi
done
fi

if [ "$1" = "IMPORT" ]; then
for CERT in $(ls "$DEST"); do
    CERT=$(basename $CERT .crt)
    echo -e "\nImporting $CERT.crt..."
	keytool -importcert -noprompt -trustcacerts -storepass "$STOREPASS" -keystore "$KEYSTORE" -alias "$CERT" -file "$DEST"/"$CERT".crt
done
fi