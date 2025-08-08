#!/bin/bash
# Extract embedded files from OrekX installer

cd /home/ecsti/listenARIA/downloads

echo "Attempting to extract orkwebapps installer contents..."

# Method 1: Look for self-extracting archive markers
SKIP=$(awk '/^__ARCHIVE_FOLLOWS__/ { print NR + 1; exit 0; }' orkwebapps-6.00-17473-x64-linux-installer.sh)
if [ -n "$SKIP" ]; then
    echo "Found archive marker at line $SKIP"
    tail -n +$SKIP orkwebapps-6.00-17473-x64-linux-installer.sh | tar -xzv
fi

# Method 2: Search for tar header
OFFSET=$(grep -abo $'\x1f\x8b\x08' orkwebapps-6.00-17473-x64-linux-installer.sh | head -1 | cut -d: -f1)
if [ -n "$OFFSET" ]; then
    echo "Found gzip header at offset $OFFSET"
    dd if=orkwebapps-6.00-17473-x64-linux-installer.sh bs=1 skip=$OFFSET 2>/dev/null | tar -xzv
fi

# Method 3: Try common self-extracting script patterns
for MARKER in "__DATA__" "__ARCHIVE__" "__PAYLOAD__" "PAYLOAD:" ; do
    SKIP=$(grep -n "^${MARKER}" orkwebapps-6.00-17473-x64-linux-installer.sh | head -1 | cut -d: -f1)
    if [ -n "$SKIP" ]; then
        echo "Found $MARKER at line $SKIP"
        tail -n +$((SKIP+1)) orkwebapps-6.00-17473-x64-linux-installer.sh | tar -xzv 2>/dev/null && break
    fi
done

echo "Extracted files:"
ls -la *.war *.zip *.jar 2>/dev/null || echo "No WAR/JAR/ZIP files found"