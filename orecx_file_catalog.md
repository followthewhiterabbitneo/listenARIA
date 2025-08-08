# OrekX/Oreka File Catalog

## Successfully Downloaded Files
- ✅ `orkaudio-commercial-5.50-2479.x12325.x86_64.rhel9.gcc11-installer.tar` (68MB) - June 6, 2024
- ✅ `orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm` (59MB) - July 23, 2024  
- ✅ `orkwebapps-6.00-17473-x64-linux-installer.sh.tar` (94MB) - Nov 12, 2024

## Files That Failed (404 - May need different paths or versions)
- ❌ `orkui-6.50-17994.war`
- ❌ `orktrack-6.50-17994.war`

## Common OrekX File Patterns to Try

### WAR Files (Tomcat Applications)
```bash
# Version 6.50
wget --no-check-certificate --http-user=orecxaccess --http-password='Tel3gr1861aph!' \
  https://files.orecx.com/orkui-6.50-17994.war

wget --no-check-certificate --http-user=orecxaccess --http-password='Tel3gr1861aph!' \
  https://files.orecx.com/orktrack-6.50-17994.war

# Version 6.00  
wget --no-check-certificate --http-user=orecxaccess --http-password='Tel3gr1861aph!' \
  https://files.orecx.com/orkui-6.00-17473.war

wget --no-check-certificate --http-user=orecxaccess --http-password='Tel3gr1861aph!' \
  https://files.orecx.com/orktrack-6.00-17473.war
```

### Linux Packages by Distribution

#### RHEL/CentOS 9
- `orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm` ✅
- `orkaudio-commercial-5.50-2479.x12325.x86_64.rhel9.gcc11-installer.tar` ✅

#### RHEL/CentOS 8
- `orkaudio-commercial-6.50-xxxx.x86_64.rhel8.gcc8.rpm`
- `orkaudio-commercial-6.00-xxxx.x86_64.rhel8.gcc8.rpm`

#### RHEL/CentOS 7
- `orkaudio-commercial-6.50-xxxx.x86_64.rhel7.gcc4.rpm`
- `orkaudio-commercial-6.00-xxxx.x86_64.rhel7.gcc4.rpm`

#### Ubuntu/Debian
- `orkaudio-commercial-6.50-xxxx.amd64.ubuntu20.deb`
- `orkaudio-commercial-6.50-xxxx.amd64.ubuntu22.deb`
- `orkaudio-commercial-6.00-xxxx.amd64.debian10.deb`

### Windows Installers
- `orkwebapps-6.50-xxxxx-x64-windows-installer.exe`
- `orkaudio-commercial-6.50-xxxx-x64-windows.exe`

### Docker Images
- `orkaudio-docker-6.50.tar.gz`
- `orkwebapps-docker-6.00.tar.gz`

## Version History (Typical)
- **6.50** - Latest stable (2024)
- **6.00** - Previous stable (2023-2024)
- **5.50** - Legacy stable (2022-2023)
- **5.00** - Older legacy

## Component Breakdown

### OrkAudio
- Core recording service
- Captures VoIP/TDM audio
- Available as: RPM, DEB, TAR installer, Windows EXE

### OrkUI (Web Interface)
- Web-based user interface
- Call playback and search
- Deployed as WAR file in Tomcat

### OrkTrack
- Call tracking and metadata
- CDR processing
- Deployed as WAR file in Tomcat

### OrkWebApps Installer
- Combined installer for UI components
- Includes OrkUI + OrkTrack
- May bundle Tomcat

## Next Steps

1. **Check orkwebapps installer contents**:
```bash
./orkwebapps-6.00-17473-x64-linux-installer.sh --help
```

2. **Extract RPM contents without installing**:
```bash
rpm2cpio orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm | cpio -idmv
```

3. **Try alternative download paths**:
```bash
# Try with version subdirectories
wget ... https://files.orecx.com/6.50/orkui-6.50-17994.war
wget ... https://files.orecx.com/6.00/orkui-6.00-17473.war

# Try without build numbers
wget ... https://files.orecx.com/orkui-6.50.war
wget ... https://files.orecx.com/orktrack-6.50.war
```

## Installation Order
1. Database setup/upgrade
2. OrkAudio service installation
3. Tomcat installation/upgrade
4. Deploy WAR files (OrkUI, OrkTrack)
5. Configuration migration
6. Testing and validation