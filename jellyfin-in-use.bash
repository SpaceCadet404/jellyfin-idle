#!/bin/bash
source ./jellyfin-in-use.conf

# main
main() {
	RESPONSE=$(curl -s -X GET "$SERVER/Devices" \
		-H "Authorization: MediaBrowser Token=\"$APIKEY\"" \
		-H "Accept: application/json")

	latest_ts=$(echo "$RESPONSE" \
		| jq -r '.Items[] | .DateLastActivity' \
		| sort -r \
		| head -n1)

	now_ts=$(date -u +%s)
	latest_epoch=$(date -d "$latest_ts" +%s)

	if [ $(( now_ts - latest_epoch )) -gt "$IDLETIME" ]; then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

# config checks
export ERROR=0
if test -z "$APIKEY"; then
	echo "API key missing from jellyfin-in-use.conf"
	export ERROR=1
fi

if test -z "$SERVER"; then
	echo "Jellyfin server address missing from jellyfin-in-use.conf"
	export ERROR=1
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "curl is required but not installed."
	export ERROR=1
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "jq is required but not installed."
	export ERROR=1
fi

if [ "$ERROR" -eq 1 ]; then
	echo "Config failure. Exiting."
	exit 1
else
	main
fi