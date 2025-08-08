#!/bin/bash

# OrekX/Oreka Download Script
# Downloads all required components from OrekX file server

echo "Starting OrekX components download..."
cd /home/ecsti/listenARIA/downloads

# Base URL and credentials
BASE_URL="https://files.orecx.com"
USER="orecxaccess"
PASS="Tel3gr1861aph!"

# Files to download
FILES=(
    "orkui-6.50-17994.war"
    "orktrack-6.50-17994.war"
    "orkwebapps-6.00-17473-x64-linux-installer.sh.tar"
    "orkaudio-commercial-5.50-2479.x12325.x86_64.rhel9.gcc11-installer.tar"
    "orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm"
)

# Download each file
for FILE in "${FILES[@]}"; do
    echo "Downloading: $FILE"
    wget --no-check-certificate \
         --http-user="$USER" \
         --http-password="$PASS" \
         "$BASE_URL/$FILE"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully downloaded: $FILE"
    else
        echo "✗ Failed to download: $FILE"
    fi
    echo "---"
done

echo "Download complete. Files saved to: $(pwd)"
ls -lh