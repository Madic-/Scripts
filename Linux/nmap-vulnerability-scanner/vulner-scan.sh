#!/usr/bin/env bash
#
# This script scans multiple ip-ranges after known cves with nmap and the nmap vulners script
# and converts via nmap-parse-output the nmap xml outputs to html reports.
#
# nmap-parse-output can be downloaded from:
# https://github.com/ernw/nmap-parse-output
# TODO:
# [ ] Make REPORT_PATH configurable
# [ ] Write README.md

AUTHOR="Michael Neese <madic@geekbundle.org>"
REPORT_PATH="$HOME/Documents/CVEScan/$(date +%Y.%m.%d-%H.%m)"
BINARIES=(
  nmap
  nmap-parse-output
)

USAGE() {
  echo "Usage: ${0##*/} [OPTION]
This script scans multiple ip-ranges after known cves with nmap and the nmap vulners script
and converts via nmap-parse-output the nmap xml outputs to html reports.

Options:
  -f File with ip-ranges per line
  -h Show help message

Examples:
  ${0##*/} -f /etc/scan.conf

File example:
192.168.1.0/24
192.168.2.0/24
172.16.0.130/32

Report bugs to: $AUTHOR
Homepage: <https://www.geekbundle.org>"
  exit 1
}

while getopts ":f:h" opt; do
  case "$opt" in
  f)
    CONFIG_FILE="$OPTARG"
    ;;
  h)
    USAGE
    ;;
  *)
    USAGE
    ;;
  esac
done

# Check if all required binaries exist and are executable
for i in "${BINARIES[@]}"; do
  if ! [ -x "$(command -v "$i")" ]; then
    echo "$i not found."
    exit 1
  fi
done

# Read ip-ranges from file
if [ -n "$CONFIG_FILE" ]; then
  readarray -t NETWORKS <"$CONFIG_FILE"
else
  echo "File with ip-ranges missing. See -h for more information."
  exit 1
fi

# Check if $REPORT_PATH exist and if not, create it
if [ ! -d "$REPORT_PATH" ]; then
  mkdir -p "$REPORT_PATH"
fi

# Scan $NETWORKS and create xml and html reports in $REPORT_PATH
for i in "${NETWORKS[@]}"; do
  echo -e "======\nScanning $i and writing report to $REPORT_PATH...\n======"

  # Convert / to - for report file name
  REPORT_FILE=$(sed "s/\//\-/" <<<"$i")
  # Scanning network and writing xml report
  nmap --stats-every 10s -sV -oX "$REPORT_PATH/$REPORT_FILE.xml" --script vulners "$i"
  # Converting xml to fancy html
  nmap-parse-output "$REPORT_PATH/$REPORT_FILE.xml" html-bootstrap >"$REPORT_PATH/$REPORT_FILE.html"
  echo -e "\n"
done

echo "Report(s) saved to $REPORT_PATH."
