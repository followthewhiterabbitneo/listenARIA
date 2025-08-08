#!/bin/bash

# OrekX File Listing Script
# Lists all available files from the OrekX server

echo "Fetching file listing from OrekX server..."
echo "========================================="

# Credentials
USER="orecxaccess"
PASS="Tel3gr1861aph!"
URL="https://files.orecx.com"

# Create temp file for the listing
TMPFILE="/tmp/orecx_listing.html"

# Download the index page
wget --no-check-certificate \
     --http-user="$USER" \
     --http-password="$PASS" \
     -O "$TMPFILE" \
     "$URL" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Successfully connected to OrekX server"
    echo ""
    
    # Parse the HTML to extract file links
    # Looking for href links that point to files
    echo "Available files:"
    echo "----------------"
    
    # Extract all file links and parse them
    grep -oP 'href="[^"]*\.(war|rpm|tar|gz|sh|zip|exe|jar|deb)"' "$TMPFILE" | \
        sed 's/href="//g' | sed 's/"//g' | sort -u > /tmp/orecx_files.txt
    
    # Also try to get file info from standard Apache/nginx directory listing
    grep -oP '<a href="[^"]+">.*?</a>' "$TMPFILE" | \
        sed 's/<a href="//g' | sed 's/">/ /g' | sed 's/<\/a>//g' | \
        grep -E '\.(war|rpm|tar|gz|sh|zip|exe|jar|deb)' >> /tmp/orecx_files.txt 2>/dev/null
    
    # Display organized by type
    echo ""
    echo "=== WAR Files (Tomcat Web Applications) ==="
    grep '\.war' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== RPM Files (RedHat/CentOS/RHEL Packages) ==="
    grep '\.rpm' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== TAR Files (Archives) ==="
    grep '\.tar' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== Installer Scripts ==="
    grep '\.sh' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== Windows Executables ==="
    grep '\.exe' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== DEB Files (Debian/Ubuntu Packages) ==="
    grep '\.deb' /tmp/orecx_files.txt 2>/dev/null | sort
    
    echo ""
    echo "=== Other Files ==="
    grep -vE '\.(war|rpm|tar|sh|exe|deb)' /tmp/orecx_files.txt 2>/dev/null | sort
    
    # Try alternate parsing method if no files found
    if [ ! -s /tmp/orecx_files.txt ]; then
        echo "Trying alternate parsing method..."
        cat "$TMPFILE" | sed -n 's/.*href="\([^"]*\)".*/\1/p' | grep -v "^/" | grep -v "^?" | sort -u
    fi
    
    # Show raw HTML snippet for debugging
    echo ""
    echo "=== Raw HTML Preview (first 50 lines) ==="
    head -50 "$TMPFILE"
    
else
    echo "Failed to connect to OrekX server"
    echo "Please check credentials and network connection"
fi

# Cleanup
rm -f /tmp/orecx_files.txt