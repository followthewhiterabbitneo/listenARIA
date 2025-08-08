# listenARIA - OrekX/Oreka Upgrade Plan

## Current Assets
We have successfully downloaded 219MB of OrekX software:

### Downloaded Files
| File | Size | Date | Type | Purpose |
|------|------|------|------|---------|
| orkwebapps-6.00-17473-x64-linux-installer.sh | 94MB | Nov 2024 | Shell Script | Contains OrkUI & OrkTrack WAR files |
| orkaudio-commercial-5.50-2479.x86_64.rhel9.gcc11-installer.sh | 68MB | Jun 2024 | Shell Script | OrkAudio 5.50 installer |
| orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm | 59MB | Jul 2024 | RPM | OrkAudio 6.50 for RHEL9 |

### Missing Components
- Individual WAR files (orkui-6.50.war, orktrack-6.50.war) - but these appear to be bundled in orkwebapps installer

## Upgrade Path

### Phase 1: Discovery & Assessment
- [ ] Identify current OrekX version: `rpm -qa | grep -i ork`
- [ ] Check Tomcat version: `$CATALINA_HOME/bin/version.sh`
- [ ] Database version: `mysql --version` or `mariadb --version`
- [ ] Document current configuration locations
- [ ] List active recordings and storage paths
- [ ] Check disk space: `df -h`

### Phase 2: Pre-Upgrade Preparation
- [ ] Create full system backup
- [ ] Backup database: `mysqldump -u root -p oreka > oreka_backup_$(date +%Y%m%d).sql`
- [ ] Backup Tomcat webapps: `tar -czf tomcat_webapps_backup.tar.gz $CATALINA_HOME/webapps/`
- [ ] Backup OrkAudio config: `tar -czf orkaudio_config_backup.tar.gz /etc/orkaudio/`
- [ ] Document current network ports and services
- [ ] Create rollback plan

### Phase 3: Component Upgrade Order

#### 3.1 Database Upgrade
- [ ] Backup existing database
- [ ] Review schema changes between versions
- [ ] Apply migration scripts if needed
- [ ] Test database connectivity

#### 3.2 OrkAudio Upgrade (5.50 → 6.50)
```bash
# Stop current service
systemctl stop orkaudio

# Install new version (RHEL9)
rpm -Uvh orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm

# Or use installer for custom path
./orkaudio-commercial-6.50-installer.sh

# Update configuration
vi /etc/orkaudio/config.xml

# Start service
systemctl start orkaudio
systemctl status orkaudio
```

#### 3.3 Tomcat & Web Apps Upgrade
```bash
# Stop Tomcat
systemctl stop tomcat

# Run orkwebapps installer
./orkwebapps-6.00-17473-x64-linux-installer.sh

# Follow prompts for:
# - Tomcat location
# - Database connection
# - Admin credentials

# Start Tomcat
systemctl start tomcat
```

### Phase 4: Post-Upgrade Validation
- [ ] Verify all services are running
- [ ] Test login to OrkUI web interface
- [ ] Verify recordings are accessible
- [ ] Create test recording
- [ ] Check logs for errors
- [ ] Monitor performance metrics
- [ ] Validate integrations

## Environment Questions to Answer

### System Information Needed
1. **Operating System**
   ```bash
   cat /etc/os-release
   uname -a
   ```

2. **Current OrekX Components**
   ```bash
   rpm -qa | grep -i ork
   ps aux | grep -i ork
   ```

3. **Tomcat Details**
   ```bash
   echo $CATALINA_HOME
   $CATALINA_HOME/bin/version.sh
   ls -la $CATALINA_HOME/webapps/
   ```

4. **Database Info**
   ```bash
   mysql -u root -p -e "SELECT VERSION();"
   mysql -u root -p oreka -e "SHOW TABLES;"
   ```

5. **Storage & Recordings**
   ```bash
   df -h /var/spool/orkaudio/
   ls -la /var/spool/orkaudio/
   du -sh /var/spool/orkaudio/*
   ```

## Risk Mitigation

### High Priority Risks
1. **Data Loss** - Mitigate with comprehensive backups
2. **Service Downtime** - Schedule maintenance window
3. **Compatibility Issues** - Test in non-production first
4. **Configuration Loss** - Document all settings beforehand

### Rollback Strategy
1. Stop all services
2. Restore database from backup
3. Restore Tomcat webapps
4. Restore OrkAudio binaries and config
5. Restart services
6. Verify functionality

## Success Criteria
- ✅ All services start without errors
- ✅ Web interface accessible
- ✅ Historical recordings playable
- ✅ New recordings captured successfully
- ✅ Performance equal or better than before
- ✅ All integrations functional

## Notes
- OrekX has evolved through multiple names/brands since 2008
- Bruno Haas was the original creator
- The orkwebapps installer includes both OrkUI and OrkTrack
- RHEL9 packages require GCC 11 compatibility
- Always test upgrades in non-production environment first