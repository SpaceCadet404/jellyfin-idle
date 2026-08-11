# jellyfin-idle
Checks if jellyfin is currently in use.

Script will exit 0 if server is idle.
Script will exit 1 if server is NOT idle.

Designed for use on Linux machines, and may need `date` called differently if running Jellyfin on macOS.

## How to Use
Run your maintenance scripts by using `&&` after jellyfin-idle.sh

Example usage
`/home/jellyfin/jellyfin-idle.sh && $YOUR-MAINTENANCE-SCRIPT`
