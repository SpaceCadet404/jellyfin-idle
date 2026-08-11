#!/bin/bash
source ./jellyfin-in-use.conf

# flags
DEBUG=0
while getopts "d" opt; do
	case $opt in
		d) DEBUG=1 ;;
		*) echo "Usage: $0 [-d]"; exit 1 ;;
	esac
done

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

        #debug
        if [ $DEBUG -eq 1 ]; then
                echo "now_ts: $now_ts"
                echo "latest_epoch: $latest_epoch"
                echo "delta: $(( $now_ts - $latest_epoch ))s"
                echo "latest_timestamp: $latest_ts"
				echo ""
                echo "RESPONSE: $(echo $RESPONSE \
                        | jq -r '.Items[] | "\(.DateLastActivity)\t\(.Name)\t\(.LastUserName)"' \
                        | sort -r)"
				echo ""
#               Raw resposne
#               echo $RESPONSE | jq -r '.Items[]'
        fi
        #------

        if [ $(( $now_ts - $latest_epoch )) -gt "$IDLETIME" ]; then
                [ "$DEBUG" -eq 1 ] && echo "Jellyfin server is IDLE"
                exit 0
        else
                [ "$DEBUG" -eq 1 ] && echo "Jellyfin server is NOT IDLE"
                exit 1
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