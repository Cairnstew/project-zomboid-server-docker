#!/bin/bash
# debug_env.sh - debugging helper script for Project Zomboid server container

echo "===== DEBUG BLOCK START ====="

# Print current working directory
echo "Working directory: $(pwd)"

# List files and permissions in the relevant directory
DIR="/home/steam/pz-dedicated"
echo "Listing files in $DIR:"
ls -al "$DIR"

# If you want to check Zomboid Server folder specifically, uncomment:
# echo "Listing files in $DIR/Zomboid/Server:"
# ls -al "$DIR/Zomboid/Server"

# Check if the config file exists and show first 20 lines
CONFIG_FILE="$DIR/ProjectZomboid64.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE found. Contents:"
    head -n 20 "$CONFIG_FILE"
else
    echo "Config file $CONFIG_FILE NOT found!"
fi

# Show environment variables containing relevant keywords
echo "Environment variables (filtered):"
env | grep -E 'IP|PORT|JAVA|STEAM|PWD|USER|HOME'

# Show free memory and disk space info
echo "Memory info:"
free -h
echo "Disk space info:"
df -h

echo "===== DEBUG BLOCK END ====="
